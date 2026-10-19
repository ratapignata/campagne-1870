extends RefCounted
var path: String
var fingerprint: String
var recovered: bool=false
var migrations: Dictionary={}
func _init(location: String,pack_hash: String,compatible: Dictionary={}) -> void:path=location;fingerprint=pack_hash;migrations=compatible
func read_slot(location: String) -> Dictionary:
	if not FileAccess.file_exists(location):return {}
	var parser=JSON.new()
	if parser.parse(FileAccess.get_file_as_string(location))!=OK:return {}
	var raw=parser.data
	if not raw is Dictionary or int(raw.get("schema",-1))!=1 or (raw.get("pack_hash","")!=fingerprint and not migrations.has(raw.get("pack_hash",""))):return {}
	if not raw.get("payload",null) is String or str(raw.payload).sha256_text()!=raw.get("checksum",""):return {}
	if parser.parse(raw.payload)!=OK:return {}
	if not parser.data is Dictionary:return {}
	var data=parser.data
	if raw.pack_hash!=fingerprint and data.get("state",{}).get("finished",false):
		# A completed V38 result retains its original duration denominator.
		data.state.completed_turn_limit=int(migrations[raw.pack_hash].turns)
	return data
func load_game(e) -> bool:
	recovered=false
	for suffix in ["",".bak"]:
		var data=read_slot(path+suffix)
		if data.get("state",null) is Dictionary and e.validate(data.state):
			e.state=data.state;e.normalize()
			var previous=data.get("previous",{})
			e.previous={}
			if previous is Dictionary and e.validate(previous):
				var loaded_state=e.state
				e.state=previous;e.normalize();e.previous=e.state;e.state=loaded_state
			recovered=suffix==".bak";return true
	return false
func save_game(e) -> bool:
	# Do not replace a valid save (or its backup) with an invalid runtime state.
	if not e.validate(e.state):return false
	var payload=JSON.stringify({"state":e.state,"previous":e.previous})
	var f=FileAccess.open(path+".tmp",FileAccess.WRITE)
	if f==null:return false
	f.store_string(JSON.stringify({"schema":1,"pack_hash":fingerprint,"payload":payload,"checksum":payload.sha256_text()}));f.flush();f.close()
	if read_slot(path+".tmp").is_empty():return false
	var old=read_slot(path)
	if old.get("state",null) is Dictionary and e.validate(old.state) and DirAccess.copy_absolute(path,path+".bak")!=OK:return false
	return DirAccess.rename_absolute(path+".tmp",path)==OK

func import_compatible(e,entries: Array) -> bool:
	for entry in entries:
		var legacy=get_script().new(str(entry.path),str(entry.pack_hash))
		if legacy.load_game(e):
			recovered=legacy.recovered
			return save_game(e)
	return false

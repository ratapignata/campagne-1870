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
	if not data.get("state",null) is Dictionary:return {}
	if raw.pack_hash!=fingerprint and migrations.get(raw.pack_hash,{}).has("objective_layout"):
		for key in ["state","previous"]:
			if data.get(key,null) is Dictionary and not data[key].is_empty():data[key].objective_layout=str(migrations[raw.pack_hash].objective_layout)
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
			if e.pack.has("previous_objectives") and str(entry.pack_hash)!=fingerprint:
				e.state.objective_layout="v4312"
				if not e.previous.is_empty():e.previous.objective_layout="v4312"
			recovered=legacy.recovered
			return save_game(e)
	return false

# Export is a separate snapshot: never rotate or rewrite the live save/backup.
func export_snapshot(e,metadata: Dictionary={}) -> String:
	if not e.validate(e.state):return ""
	var payload=JSON.stringify({"state":e.state,"previous":e.previous})
	return JSON.stringify({"schema":1,"pack_hash":fingerprint,"payload":payload,"checksum":payload.sha256_text(),"export_info":metadata.duplicate(true)},"\t")

func export_copy(location: String,snapshot: String) -> bool:
	var destination=ProjectSettings.globalize_path(location).simplify_path()
	var original=ProjectSettings.globalize_path(path).simplify_path()
	if destination in [original,original+".bak",original+".tmp"] or snapshot.is_empty():return false
	var envelope=JSON.parse_string(snapshot)
	if not envelope is Dictionary or envelope.get("pack_hash","")!=fingerprint:return false
	var payload=envelope.get("payload",null)
	if not payload is String or payload.sha256_text()!=envelope.get("checksum",""):return false
	var data=JSON.parse_string(payload)
	if not data is Dictionary or not data.get("state",null) is Dictionary:return false
	var f=open_export_file(location)
	if f==null:return false
	f.store_string(snapshot);f.flush()
	var error=f.get_error();f.close()
	# Android get_error() reports EOF when the cursor reaches the written length.
	# This is not proof of a failed write; the mandatory read-back below is decisive.
	if error!=OK and error!=ERR_FILE_EOF:return false
	# Verify all serialized fields, including the undo snapshot, without normalization.
	return read_slot(location)==data

func open_export_file(location: String):
	return FileAccess.open(location,FileAccess.WRITE)

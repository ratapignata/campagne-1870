extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const AI=preload("res://war_engine/ai/tactical_ai.gd")
const Legacy=preload("res://war_engine/ai/legacy_ai.gd")
const Store=preload("res://war_engine/platform/save_store.gd")
var checks=0
var failures=0
var profiles: Dictionary
var data: Dictionary
func check(ok: bool,msg: String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL: "+msg)
func bot():
	var ai=AI.new();ai.profiles=profiles;return ai
func fixture():
	var p=data.duplicate(true);p.map.tiles.fill("plain");var e=Rules.new(p)
	for n in range(e.state.units.size()):
		e.state.units[n].strength=0;e.state.units[n].casualties=e.state.units[n].initial_strength;e.state.units[n].done=true
	e.state.contacts=[{},{}];e.state.revealed=[[],[]];return e
func revive(e,n: int,cell: Array):
	var u=e.state.units[n];u.strength=u.initial_strength;u.casualties=0;u.cell=cell;u.done=false;u.ap=16;u.formation="none" if e.artillery(n) or e.cavalry(n) else "line"
func dispatch(e,d: Dictionary) -> bool:
	var n=e.unit_index(str(d.get("unit","")))
	match d.kind:
		"end":e.end_side();return true
		"move":return e.move(n,d.path) in ["moved","capture","discovered"]
		"fire":return e.fire(n,e.unit_index(d.target)).status=="ok"
		"assault":return e.assault(n,e.unit_index(d.target)).status=="ok"
		"formation":return e.change_formation(n,d.formation)
		"rally":return e.rally(n)
		"rest":return e.rest(n)
		"entrench":return e.entrench(n)
		"deploy","limber":return e.toggle_deployment(n)
	return false
func _initialize():
	data=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/legacy0813.json"));profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
	var ai=bot();var reference={}
	for difficulty in ["easy","medium","hard"]:
		var e=Rules.new(data);e.new_game(1,difficulty);e.state.seed=123;e.state.ai_style=0
		var comparable=e.state.duplicate(true);comparable.erase("ai_difficulty")
		if reference.is_empty():reference=comparable
		check(comparable==reference and e.pack==data,"no change in military rules/units/AP: "+difficulty)
		var view=e.observation(0);var before=view.duplicate(true);var chosen=ai.choose(view)
		check(view==before,"AI does not mutate observed input: "+difficulty)
		check(dispatch(e,chosen) and e.validate(e.state),"first command valid: "+difficulty)
		var store=Store.new("user://ai088_"+difficulty+".json","ai088");var copy=Rules.new(data)
		check(store.save_game(e) and store.load_game(copy) and copy.state==e.state,"difficulty/style save roundtrip: "+difficulty)
		# Two worlds share all visible information, with completely different hidden forces.
		e=fixture();revive(e,0,[2,2]);revive(e,4,[27,17]);e.state.ai_difficulty=difficulty;e.state.ai_style=1;e.refresh_intel()
		var twin=Rules.new(e.pack);twin.state=e.state.duplicate(true);twin.state.units[4].cell=[25,18];twin.state.units[4].strength=117;twin.state.units[4].casualties=883;twin.state.seed=8888;twin.refresh_intel()
		check(e.observation(0)==twin.observation(0),"no hidden information in observation: "+difficulty)
		check(ai.choose(e.observation(0))==ai.choose(twin.observation(0)),"decision independent of hidden enemy: "+difficulty)
	print("AI COMPAT ",checks-failures,"/",checks);quit(1 if failures else 0)

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
	data=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/three_objectives.json"))
	profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
	var difficulty="medium"
	for value in OS.get_cmdline_user_args():
		if value in ["easy","medium","hard"]:difficulty=value
	var e=Rules.new(data);e.new_game(0,difficulty);e.state.seed=123;e.state.ai_style=0
	check(e.objective_definitions().size()==3,"three goals")
	check(e.pack.map.tiles[e.objective_cell(e.pack.objectives[1])]=="forest","wood objective in forest")
	check(not e.pack.map.tiles.has("meadow"),"plain only")
	var ai=bot();var count=0;var good=true;var started=Time.get_ticks_msec()
	while not e.state.finished and count<800:
		count+=1
		var action=ai.choose(e.observation(int(e.state.side)))
		if not dispatch(e,action) or not e.validate(e.state):good=false;printerr("BAD ",action);break
		if count%100==0:print(difficulty," decision ",count," turn ",e.state.turn)
	check(good and e.state.finished,"trial finishes with legal actions")
	var slot=Store.new("user://trial_test_"+difficulty+".json",JSON.stringify(data).sha256_text())
	check(slot.save_game(e),"save final trial")
	var loaded=Rules.new(data);check(slot.load_game(loaded) and loaded.state==e.state,"resume exact final trial")
	print("TRIAL ",difficulty,": ",checks-failures,"/",checks," decisions=",count," ms=",Time.get_ticks_msec()-started," scores=",e.state.scores," result=",e.result_for(0).level)
	quit(1 if failures else 0)

extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const AI=preload("res://war_engine/ai/tactical_ai.gd")
const Store=preload("res://war_engine/platform/save_store.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL "+label)
func _initialize():
	var p=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial.json"));var ai=AI.new();ai.profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
	var old=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/legacy0832_ai_profiles.json"))
	for pair in [["easy","medium"],["medium","hard"]]:
		for key in old[pair[1]]:check(ai.profiles[pair[0]][key]==old[pair[1]][key],"profile promotion "+str(pair)+key)
	for level in ["easy","medium","hard"]:
		var e=Rules.new(p);e.new_game(0,level)
		var store=Store.new("user://ai0833_"+level+".json","0833");var copy=Rules.new(p)
		check(store.save_game(e) and store.load_game(copy) and copy.state==e.state,"complete save "+level)
		var view=e.observation(0);var before=view.duplicate(true);var chosen=ai.choose(view)
		check(view==before,"AI leaves input unchanged "+level)
		check(chosen.kind=="move" and e.move(e.unit_index(chosen.unit),chosen.path) in ["moved","capture","discovered"],"legal initial decision "+level)
		check(e.validate(e.state),"valid after AI "+level)
	print("AI 0833 ",checks-failures,"/",checks);quit(1 if failures else 0)

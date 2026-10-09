extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const AI=preload("res://war_engine/ai/tactical_ai.gd")
func _initialize():
	var p=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial.json"))
	var results=[]
	for difficulty in ["easy","medium","hard"]:
		for side in [0,1]:
			var e=Rules.new(p);e.new_game(side,difficulty);e.state.side=side;e.state.ai_style=0
			var ai=AI.new();ai.profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
			var view=e.observation(side)
			var start=Time.get_ticks_msec();var action=ai.choose(view);var elapsed=Time.get_ticks_msec()-start
			results.append({"difficulty":difficulty,"side":side,"ms":elapsed,"action":action})
			print(difficulty," ",side," ",elapsed,"ms ",action)
	var args=OS.get_cmdline_user_args()
	var f=FileAccess.open(args[0],FileAccess.WRITE);f.store_string(JSON.stringify(results,"\t"));f.close();quit()

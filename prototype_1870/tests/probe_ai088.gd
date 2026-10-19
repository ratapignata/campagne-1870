extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const AI=preload("res://war_engine/ai/tactical_ai.gd")
func _initialize():
	var data=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/prototype.json"));var ai=AI.new();ai.profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
	for difficulty in ["easy","medium","hard"]:
		var e=Rules.new(data);e.new_game(0,difficulty);e.state.ai_style=0
		var start=Time.get_ticks_msec();var view=e.observation(0);var before=JSON.stringify(view);var action=ai.choose(view)
		print(difficulty," ms=",Time.get_ticks_msec()-start," action=",action," input intact=",before==JSON.stringify(view))
	quit()

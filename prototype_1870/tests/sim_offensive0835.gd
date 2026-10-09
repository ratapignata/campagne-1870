extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const AI=preload("res://war_engine/ai/tactical_ai.gd")
func dispatch(e,d):
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
	var p=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial.json"));var e=Rules.new(p);e.new_game(0,"medium");e.state.seed=42;e.state.ai_style=0
	var ai=AI.new();ai.profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"));var actions={};var decisions=0
	while not e.state.finished and int(e.state.turn)<=4:
		if e.state.side==0:e.end_side();continue
		var view=e.observation(1);var before=view.duplicate(true);var d=ai.choose(view)
		if before!=view or not dispatch(e,d) or not e.validate(e.state):printerr("INVALID ",d);quit(1);return
		actions[d.kind]=int(actions.get(d.kind,0))+1;decisions+=1
		if d.kind=="end":print("TURN ",e.state.turn," actions ",actions," objective owners ",e.state.objective_owners," moves ",e.state.moves)
		if decisions>700:printerr("LOOP");quit(1);return
	print("OFFENSIVE FINISHED ",actions);quit()

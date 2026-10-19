extends "res://tests/test_ai_compat0833.gd"
func _initialize():
	var p=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial.json"))
	p.map.tiles.fill("plain");p.map.elevations.fill(0);p.map.river_edges=[];p.map.road_edges=[];p.rules.support.enabled=false
	var u=p.units[34].duplicate(true);u.cell=[12,9];u.arrival_turn=1;p.units=[u]
	p.objectives=p.objectives.slice(0,2);p.objectives[0].cell=[12,0];p.objectives[0].points=3;p.objectives[1].cell=[15,9];p.objectives[1].points=1
	var e=Rules.new(p);e.new_game(0,"hard");e.state.side=1;e.state.ai_style=0;e.refresh_intel()
	profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"));var ai=bot();ai.hard_planning=true;ai.offensive=true;ai.settings=profiles.hard
	var goal=ai.mission_goal(e,0,{})
	check(goal==e.objective_cell(p.objectives[0]),"main operational axis remains the distant valuable objective")
	var action=ai.choose(e.observation(1))
	check(action.kind=="move" and int(action.path[-1])==e.objective_cell(p.objectives[1]),"captures an available secondary objective off the main axis")
	check(dispatch(e,action) and e.objective_owner(p.objectives[1])==1,"secondary capture uses a legal paid movement")
	print("V39 CAPTURE OPPORTUNITY ",checks-failures,"/",checks);quit(1 if failures else 0)

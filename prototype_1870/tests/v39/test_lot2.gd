extends "res://tests/test_ai_compat0833.gd"
func _initialize():
	profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
	data=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial.json"))
	var p=data.duplicate(true);p.map.tiles.fill("plain");p.map.elevations.fill(0);p.map.river_edges=[];p.map.road_edges=[]
	var roster=[[0,[12,7]],[1,[14,7]],[34,[12,9]],[35,[13,9]],[67,[10,9]],[68,[15,10]]];var units=[]
	for pair in roster:
		var u=p.units[pair[0]].duplicate(true);u.cell=pair[1];u.arrival_turn=1;units.append(u)
	p.units=units;p.objectives=p.objectives.slice(0,2);p.objectives[0].cell=[12,7];p.objectives[1].cell=[14,7]
	for mode in ["medium","hard"]:
		var e=Rules.new(p);e.new_game(0,mode);e.state.side=1;e.state.seed=187039;e.state.ai_style=0
		for n in range(e.state.units.size()):
			if e.artillery(n):e.state.units[n].deployed=true
		e.refresh_intel();var view=e.observation(1);var before=view.duplicate(true);var ai=bot();var action=ai.choose(view)
		check(view==before,"planning does not mutate observation "+mode)
		check(action==bot().choose(view),"decision reproducible without private memory "+mode)
		var n=e.unit_index(str(action.get("unit","")))
		check(action.kind=="fire" and n>=0 and e.artillery(n),"battery prepares offensive before infantry "+mode)
		check(dispatch(e,action) and e.validate(e.state),"preparatory shot legal "+mode)
		for step in range(10):
			if e.state.side!=1:break
			action=ai.choose(e.observation(1));check(dispatch(e,action),"subsequent action legal "+mode)
		check(e.validate(e.state),"tactical sequence remains valid "+mode)
	var e=Rules.new(p);e.new_game(0,"hard");e.state.side=1;e.refresh_intel();var ai=bot();ai.settings=profiles.hard;ai.hard_planning=true;ai.offensive=true
	var n=2;var goal=e.unit_cell(e.state.units[0]);var plain=ai.approach_distances(e,goal,n);ai.enemy_screen={e.unit_cell(e.state.units[2]):12}
	var screened=ai.approach_distances(e,goal,n);check(not screened.is_empty() and screened[goal]==0,"tactical detour preserves objective reachability")
	check(e.pack.rules.victory.final_control==60 and e.pack.unit_types.cavalry.charge_ap==8,"score and cavalry unchanged")
	print("V39 LOT2 ",checks-failures,"/",checks);quit(1 if failures else 0)

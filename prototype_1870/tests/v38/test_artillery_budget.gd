extends "res://tests/test_ai_compat0833.gd"
func _initialize():
	profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
	var p=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial.json"));p.map.tiles.fill("plain");p.map.elevations.fill(0);p.map.river_edges=[];p.map.road_edges=[];p.objectives[0].cell=[4,4];var units=[]
	for pair in [[57,[4,4]],[56,[25,17]],[67,[4,7]],[66,[25,18]]]:
		var u=p.units[pair[0]].duplicate(true);u.cell=pair[1];u.arrival_turn=1;units.append(u)
	p.units=units;var e=Rules.new(p);e.new_game(0,"hard");e.state.ai_style=0;e.end_side();e.end_side();e.hold(1);var ai=bot()
	check(not e.state.units[0].command_ok and e.state.units[0].supply_ok and e.max_ap(0)==12,"actual uncommanded supplied French gun has three PA")
	check(e.visible_to(0,2),"future target is actually observed")
	var view=e.observation(0);var before=view.duplicate(true);var action=ai.choose(view)
	check(action.kind=="deploy" and action.unit==e.state.units[0].id,"hard prepares useful deployment despite insufficient PA for same-turn French shot")
	check(view==before,"preparation does not mutate observation")
	check(dispatch(e,action) and e.state.units[0].deployed and e.state.units[0].ap==8,"deployment consumes one PA, no free action")
	check(e.fire_status(0,2)=="no_ap","French shot still requires three PA")
	e.end_side();e.end_side()
	check(e.max_ap(0)==12 and e.state.units[0].ap==12 and e.fire_status(0,2)=="ok","next own turn allows existing three-PA shot")
	check(e.fire(0,2).status=="ok" and e.state.units[0].ap==0,"real French shot consumes all three PA")
	check(e.validate(e.state),"prepared deployment and shot preserve valid state")
	print("V38 ARTILLERY BUDGET ",checks-failures,"/",checks);quit(1 if failures else 0)

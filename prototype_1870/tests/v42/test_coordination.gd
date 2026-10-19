extends "res://tests/test_ai_compat0833.gd"
func setup(mode):
	var p=data.duplicate(true);p.map.tiles.fill("plain");p.map.elevations.fill(0);p.map.river_edges=[];p.map.road_edges=[];p.rules.support.enabled=false;p.rules.fog.enabled=false
	var f=p.units[0].duplicate(true);var g=p.units[1].duplicate(true);var infantry=p.units[34].duplicate(true);var cannon={}
	for u in p.units:
		if int(u.side)==1 and u.weapon=="krupp":cannon=u.duplicate(true);break
	f.cell=[11,5];g.cell=[17,7];infantry.cell=[12,7];cannon.cell=[14,7];p.units=[f,g,infantry,cannon]
	for u in p.units:u.arrival_turn=1;u.initial_strength=1000
	var e=Rules.new(p);e.new_game(0,mode);e.state.side=1;e.state.seed=420042;e.state.ai_style=0
	for u in e.state.units:u.formation="line";u.ap=16;u.done=false
	e.state.units[3].deployed=true;e.state.units[3].formation="none";e.refresh_intel();return e
func _initialize():
	data=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v42_experimental.json"));profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
	var report={"fixture":"Synthetic flat 4-unit tactical fixture, 1000 men each; deployed Krupp and friendly infantry near defended objective","modes":[],"checks":0,"failures":0}
	for mode in ["medium","hard"]:
		var e=setup(mode);var ai=bot();ai.offensive=true;ai.hard_planning=mode=="hard"
		var near_score=ai.artillery_target_value(e,3,0);var near_preparation=ai.preparation_value(e,3,0)
		e.state.units[2].cell=[29,19];var far_score=ai.artillery_target_value(e,3,0);e.state.units[2].cell=[12,7]
		check(near_score>far_score and near_preparation>0,"nearby infantry raises artillery target priority in "+mode)
		var before=e.state.duplicate(true);var d=ai.choose(e.observation(1,[0,1]))
		check(e.state==before,"AI evaluation cannot modify live combat state")
		check(d.kind=="fire" and d.unit==e.state.units[3].id,"artillery fires first in "+mode)
		var actions=[]
		for step in range(12):
			if e.state.side!=1:break
			d=ai.choose(e.observation(1,[0,1]));check(dispatch(e,d),"legal coordinated decision "+mode);actions.append(d)
		var infantry_active=false
		for action in actions:
			if action.get("unit","")==e.state.units[2].id and action.kind in ["move","fire","assault"]:infantry_active=true
		check(infantry_active,"infantry follows artillery preparation "+mode)
		report.modes.append({"mode":mode,"near_priority":near_score,"far_priority":far_score,"preparation":near_preparation,"actions":actions})
	check(report.modes[1].near_priority>report.modes[0].near_priority,"hard gives stronger planning priority only")
	report.checks=checks;report.failures=failures
	var f=FileAccess.open("user://coordination.json",FileAccess.WRITE);f.store_string(JSON.stringify(report,"\t"));f.close()
	print("V42 COORDINATION ",JSON.stringify(report));quit(1 if failures else 0)

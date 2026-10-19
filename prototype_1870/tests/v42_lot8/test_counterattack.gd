extends "res://tests/v42/test_coordination.gd"
const French=preload("res://tests/v42_lot8/mobile_defence.gd")
func _initialize():
	data=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v42_lot8.json"));profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
	var results=[]
	for mode in ["medium","hard"]:
		for seed_value in [420811,420812,420813]:
			var e=setup(mode);e.state.side=0;e.state.seed=seed_value;e.state.units[2].cell=[12,5]
			e.apply_losses(2,450);e.state.units[2].morale="stable";e.refresh_intel()
			check(e.assault_status(0,2)=="ok","French counterattack legal")
			var counter=e.assault(0,2);check(counter.status=="ok","French counterattack resolves")
			e.end_side();var ai=bot();var actions=[]
			for step in range(80):
				if e.state.side!=1 or e.state.finished:break
				var command=ai.choose(e.observation(1,[0,1]));check(dispatch(e,command) and e.validate(e.state),"German response legal after counterattack");actions.append(command)
			check(e.state.side==0 or e.state.finished,"German response phase terminates")
			results.append({"mode":mode,"seed":seed_value,"french_counterattack":counter,"german_response":actions})
		var e=setup(mode);e.state.side=0;e.state.units[2].cell=[12,5];e.apply_losses(0,600);e.state.units[0].morale="shaken";e.refresh_intel()
		var origin=e.unit_cell(e.state.units[0]);var distance=e.enemy_distance(0,origin);var command=French.new().choose(e.observation(0,[2,3]))
		check(command.kind=="move" and command.unit==e.state.units[0].id,"damaged French unit attempts withdrawal")
		check(dispatch(e,command) and e.enemy_distance(0,e.unit_cell(e.state.units[0]))>distance,"French withdrawal increases distance from enemy")
	var f=FileAccess.open("user://counterattack.json",FileAccess.WRITE);f.store_string(JSON.stringify({"fixture":"4-unit synthetic flat fixture; French infantry assaults damaged German infantry, then actual German AI plays a full response phase; separate damaged-French withdrawal check.","results":results,"checks":checks,"failures":failures},"\t"));f.close()
	print("LOT8 COUNTERATTACK ",checks-failures,"/",checks);quit(1 if failures else 0)

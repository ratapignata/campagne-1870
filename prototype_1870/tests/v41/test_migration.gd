extends "res://tests/test_ai_compat0833.gd"
func _initialize():
	var old_raw=FileAccess.get_file_as_string("res://tests/v41/reference_v40_scenario.json")
	var raw=FileAccess.get_file_as_string("res://packs/1870/regimental_trial.json");var p=JSON.parse_string(raw)
	for finished in [false,true]:
		var e=Rules.new(JSON.parse_string(old_raw));e.new_game(0,"hard")
		if finished:
			for step in range(40):e.end_side()
		else:e.state.turn=11
		var old=Store.new("user://migration_v40.json",old_raw.sha256_text())
		check(old.save_game(e),"authentic V40 slot saved")
		var migrated=Store.new(old.path,raw.sha256_text(),p.save_migrations);var copy=Rules.new(p)
		var loaded=migrated.load_game(copy);check(loaded,"V40 slot loads into V41; finished="+str(finished))
		if not loaded:continue
		check(copy.state.turn==e.state.turn and copy.state.finished==finished,"turn and completion preserved")
		check(copy.battle_turn_limit()==20 and copy.state.ai_difficulty=="hard","duration and difficulty preserved")
		check(copy.result_for(0)==e.result_for(0),"score preserved")
		check(migrated.save_game(copy),"migrated state saves under new identity")
		var again=Rules.new(p);check(migrated.load_game(again) and JSON.parse_string(JSON.stringify(again.state))==JSON.parse_string(JSON.stringify(copy.state)),"V41 exact roundtrip")
	print("V41 MIGRATION ",checks-failures,"/",checks);quit(1 if failures else 0)

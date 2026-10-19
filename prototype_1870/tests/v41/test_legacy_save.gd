extends "res://tests/test_ai_compat0833.gd"
func _initialize():
	var raw=FileAccess.get_file_as_string("res://packs/1870/regimental_trial.json");var p=JSON.parse_string(raw)
	var saved=Store.new("res://tests/results/0837/full_final_save.json",raw.sha256_text(),p.get("save_migrations",{}));var e=Rules.new(p)
	check(saved.load_game(e),"actual delivered V37 final battle save loads in V38")
	check(e.validate(e.state) and e.state.finished and e.state.turn==18,"real V37 battle state remains valid and complete")
	check(not e.state.has("battle_history"),"legacy state does not invent retrospective history")
	var d=saved.read_slot(saved.path);check(JSON.parse_string(JSON.stringify(e.state))==JSON.parse_string(JSON.stringify(d.state)),"actual V37 complete save preserved exactly")
	var new_slot=Store.new("user://v37_to_v38.json",raw.sha256_text(),p.get("save_migrations",{}));var copy=Rules.new(p)
	check(new_slot.save_game(e) and new_slot.load_game(copy) and JSON.parse_string(JSON.stringify(copy.state))==JSON.parse_string(JSON.stringify(e.state)),"V37 save safely rewritten and reloaded by V38")
	print("V38 LEGACY SAVE ",checks-failures,"/",checks);quit(1 if failures else 0)

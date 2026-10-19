extends "res://tests/v36/test_ai_active.gd"
func _initialize():
	var report=JSON.parse_string(FileAccess.get_file_as_string("res://tests/results/0836/AB_active.json"))
	var e=Rules.new(scenario());e.new_game(0,report.difficulty);e.state.seed=int(report.seed);e.state.ai_style=0
	for action in report.actions:
		if action.turn==10 and action.side==1 and action.decision.kind=="end":break
		check(dispatch(e,action.decision),"diagnostic replay command")
	var source=FileAccess.get_file_as_string("res://war_engine/ai/tactical_ai.gd")
	# Instrument only this in-memory test script; production AI and profiles unchanged.
	source=source.replace("var profiles: Dictionary={}","var profiles: Dictionary={}\nvar diagnostic_moves=[]")
	source=source.replace("\t\t\tif score>float(settings.minimum_move):","\t\t\tdiagnostic_moves.append({\"unit\":u.id,\"from\":start,\"to\":dest,\"goal\":goal,\"score\":score,\"progress\":progress,\"threat_before\":current_threat,\"threat_after\":danger})\n\t\t\tif score>float(settings.minimum_move):")
	var script=GDScript.new();script.source_code=source;check(script.reload()==OK,"diagnostic script compiles")
	var ai=script.new();ai.profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"));var decision=ai.choose(e.observation(1))
	check(decision.kind=="end","turn ten inactivity reproduced")
	var candidates=[];var best=-INF
	for item in ai.diagnostic_moves:
		if item.unit=="pru_38":candidates.append(item);best=maxf(best,item.score)
	check(not candidates.is_empty() and best<=ai.settings.minimum_move,"all legal moves filtered by current score threshold")
	var output={"turn":10,"side":1,"unit":"pru_38","decision":decision,"minimum_move":ai.settings.minimum_move,"best_move_score":best,"candidates":candidates}
	var f=FileAccess.open("user://AI_diagnosis.json",FileAccess.WRITE);f.store_string(JSON.stringify(output,"\t"));f.close()
	print("DIAGNOSIS ",JSON.stringify(output));print("V36 AI DIAGNOSIS ",checks-failures,"/",checks);quit(1 if failures else 0)

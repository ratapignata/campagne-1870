extends "res://tests/v42/test_coordination.gd"
const Resume=preload("res://tests/v42/campaign_checkpoint.gd")
func _initialize():
	data=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v42_experimental.json"))
	profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
	var args=OS.get_cmdline_user_args()
	if args.size()!=2:printerr("checkpoint path and report path required");quit(2);return
	var raw=FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v42_experimental.json")
	var e=Rules.new(data)
	check(Store.new(args[0],raw.sha256_text()).load_game(e),"real interrupted campaign loads")
	var report=JSON.parse_string(FileAccess.get_file_as_string(args[1]))
	check(Resume.problem(e,report,"hard").is_empty(),"legacy phase boundary is safe")
	var wrong=report.duplicate(true);wrong.decision_ms.pop_back()
	check(not Resume.problem(e,wrong,"hard").is_empty(),"reject mismatched timing/action generations")
	wrong=report.duplicate(true);wrong.counts[1].fire+=1
	check(not Resume.problem(e,wrong,"hard").is_empty(),"reject mismatched counters")
	wrong=report.duplicate(true);wrong.completed_turns+=1
	check(not Resume.problem(e,wrong,"hard").is_empty(),"reject wrong completed turns")
	wrong=report.duplicate(true);wrong.failures=1
	check(not Resume.problem(e,wrong,"hard").is_empty(),"reject failed run")
	check(not Resume.problem(e,report,"medium").is_empty(),"reject changed difficulty")
	wrong=report.duplicate(true);wrong.boundaries[-1].losses[0]+=1
	check(not Resume.problem(e,wrong,"hard").is_empty(),"reject stale legacy state evidence")
	wrong=report.duplicate(true);wrong.actions[-1].decision.kind="fire";wrong.counts[0].end-=1;wrong.counts[0].fire+=1
	check(not Resume.problem(e,wrong,"hard").is_empty(),"reject legacy midphase without AI continuation")
	var modern=report.duplicate(true);modern.checkpoint_state_sha256=Resume.state_hash(e.state);modern.ai_relocation={}
	check(Resume.problem(e,modern,"hard").is_empty(),"new checkpoint fingerprint accepted")
	wrong=modern.duplicate(true);wrong.checkpoint_state_sha256="wrong"
	check(not Resume.problem(e,wrong,"hard").is_empty(),"reject stale fingerprint")
	wrong=modern.duplicate(true);wrong.erase("ai_relocation")
	check(not Resume.problem(e,wrong,"hard").is_empty(),"reject missing continuation state")
	var store=Store.new("user://resume_roundtrip.json",raw.sha256_text());var copy=Rules.new(data)
	check(store.save_game(e) and store.load_game(copy),"physical roundtrip succeeds")
	check(Resume.problem(copy,JSON.parse_string(JSON.stringify(modern)),"hard").is_empty(),"fingerprint survives JSON numeric conversion and normalization")
	# Actual artillery continuation after limbering, compared before/after JSON restore.
	for mode in ["medium","hard"]:
		var tactical=setup(mode);var n=3;var u=tactical.state.units[n]
		check(tactical.toggle_deployment(n),"limber battery for continuation "+mode)
		var reach=tactical.reach(n);var destination=-1;var start=tactical.unit_cell(u)
		for cell in reach.costs:
			if cell!=start and tactical.unit_at(cell)<0:destination=cell;break
		check(destination>=0,"battery has legal movement "+mode)
		var a=bot();a.relocation={"unit":u.id,"path":[start,destination],"turn":tactical.state.turn,"side":tactical.state.side,"ap":int(u.ap)}
		var b=bot();b.relocation=JSON.parse_string(JSON.stringify(a.relocation))
		var view=tactical.observation(1,[0,1]);var expected=a.choose(view);var resumed=b.choose(view)
		check(JSON.parse_string(JSON.stringify(expected))==JSON.parse_string(JSON.stringify(resumed)) and expected.kind=="move","same artillery continuation after resume "+mode)
		check(dispatch(tactical,resumed),"resumed artillery move legal "+mode)
	var f=FileAccess.open("user://checkpoint_tests.json",FileAccess.WRITE)
	f.store_string(JSON.stringify({"checks":checks,"failures":failures},"\t"));f.close()
	print("V42 CAMPAIGN CHECKPOINT ",checks-failures,"/",checks);quit(1 if failures else 0)

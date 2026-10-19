extends "res://tests/test_ai_compat0833.gd"
func cpu_ticks():
	var f=FileAccess.open("/proc/self/stat",FileAccess.READ);var line=f.get_line();f.close();var fields=line.substr(line.rfind(")")+2).split(" ",false);return int(fields[11])+int(fields[12])
func _initialize():
	profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"));var p=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v42_experimental.json"));var samples=[];var args=OS.get_cmdline_user_args()
	for mode in ["medium","hard"]:
		var e=Rules.new(p);e.new_game(0,mode);e.state.seed=187037;e.state.ai_style=0;if not args.is_empty():
			var store=Store.new(args[0],FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v42_experimental.json").sha256_text())
			check(store.load_game(e),"load measured mid-battle checkpoint");e.state.ai_difficulty=mode
		if int(e.state.side)==0:e.end_side()
		var view=e.observation(1);var reference={}
		for repeat in range(4):
			var ai=bot();var cpu=cpu_ticks();var start=Time.get_ticks_usec();var d=ai.choose(view);var wall=Time.get_ticks_usec()-start;var ticks=cpu_ticks()-cpu
			if reference.is_empty():reference=d
			check(d==reference,"reproducible decision from same state")
			if repeat>0:samples.append({"mode":mode,"repeat":repeat,"wall_ms":wall/1000.0,"cpu_ms_at_100Hz":ticks*10,"decision":d})
	var f=FileAccess.open("user://benchmark.json",FileAccess.WRITE);f.store_string(JSON.stringify({"fixture":"German phase of V42; initial state unless checkpoint argument supplied. Fresh AI per sample, first sample excluded. Linux host, not Android.","samples":samples,"checks":checks,"failures":failures},"\t"));f.close()
	print("V42 BENCHMARK ",checks-failures,"/",checks);quit(1 if failures else 0)

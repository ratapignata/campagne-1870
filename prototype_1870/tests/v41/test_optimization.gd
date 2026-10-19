extends "res://tests/v36/test_ai_active.gd"
const Uncached=preload("res://tests/v41/reference_v41_uncached.gd")
func _initialize():
	profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
	var report={"paired_decisions":[],"matched":0,"ranked_matched":0,"checks":0,"failures":0}
	for mode in ["medium","hard"]:
		var e=Rules.new(scenario());e.new_game(0,mode);e.state.seed=187041;e.state.ai_style=0
		var fast=bot();var slow=Uncached.new();slow.profiles=profiles
		for step in range(40):
			var view=e.observation(int(e.state.side));var before=view.duplicate(true)
			var da;var db;var ta;var tb;var t=Time.get_ticks_usec()
			if step%2==0:
				da=fast.choose(view);ta=Time.get_ticks_usec()-t;t=Time.get_ticks_usec();db=slow.choose(view);tb=Time.get_ticks_usec()-t
			else:
				db=slow.choose(view);tb=Time.get_ticks_usec()-t;t=Time.get_ticks_usec();da=fast.choose(view);ta=Time.get_ticks_usec()-t
			check(da==db,"identical decision "+mode+"/"+str(step))
			check(fast.ranked==slow.ranked,"identical candidate ranking and scores")
			check(view==before,"observation unmodified")
			if da==db:report.matched+=1
			if fast.ranked==slow.ranked:report.ranked_matched+=1
			report.paired_decisions.append({"mode":mode,"step":step,"turn":e.state.turn,"side":e.state.side,"action":da.kind,"optimized_us":ta,"reference_us":tb,"candidates":fast.ranked.size()})
			check(dispatch(e,da) and e.validate(e.state),"decision legal in authoritative engine")
			if failures>0:break
			if step%10==9:print("PAIR ",mode," ",step+1)
	# Real roster / deployment, late pressure and both difficulty levels.
	for mode in ["medium","hard"]:
		for turn in [1,12,20]:
			var p=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial.json"));var e=Rules.new(p);e.new_game(0,mode);e.state.side=1;e.state.turn=turn;e.state.ai_style=0;e.refresh_intel()
			var view=e.observation(1);var fast=bot();var slow=Uncached.new();slow.profiles=profiles
			var da=fast.choose(view);var db=slow.choose(view)
			check(da==db and fast.ranked==slow.ranked,"real roster identical decisions and scores "+mode+"/"+str(turn))
	report.checks=checks;report.failures=failures
	var out=FileAccess.open("user://optimization.json",FileAccess.WRITE);out.store_string(JSON.stringify(report,"\t"));out.close()
	print("V41 OPTIMIZATION ",checks-failures,"/",checks);quit(1 if failures else 0)

extends "res://tests/v36/test_ai_active.gd"
const Uncached=preload("res://tests/v41/reference_v41_uncached.gd")
func cpu_ticks() -> int:
	var f=FileAccess.open("/proc/self/stat",FileAccess.READ)
	if f==null:return -1
	var line=f.get_line();f.close()
	var fields=line.substr(line.rfind(")")+2).split(" ",false)
	return int(fields[11])+int(fields[12])
func timed(ai,view):
	var cpu=cpu_ticks();var wall=Time.get_ticks_usec();var d=ai.choose(view)
	return {"decision":d,"wall_us":Time.get_ticks_usec()-wall,"cpu_ticks":cpu_ticks()-cpu}
func save_report(report):
	var f=FileAccess.open("user://performance_cpu.json",FileAccess.WRITE);f.store_string(JSON.stringify(report,"\t"));f.close()
func _initialize():
	profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
	var args=OS.get_cmdline_user_args();var hz=int(args[0]) if not args.is_empty() else 100
	var report={"ticks_per_second":hz,"platform":"Linux process utime+stime from /proc/self/stat","samples":[],"checks":0,"failures":0}
	check(cpu_ticks()>=0,"Linux process CPU accounting available")
	for mode in ["medium","hard"]:
		for turn in [1,12]:
			var e=Rules.new(scenario());e.new_game(0,mode);e.state.side=1;e.state.turn=turn;e.state.seed=187041;e.state.ai_style=0;e.refresh_intel()
			var view=e.observation(1)
			# Warm each implementation before measurements. Both see identical input.
			var warm=bot();warm.choose(view);var other=Uncached.new();other.profiles=profiles;other.choose(view)
			for repeat in range(4):
				var fast=bot();var slow=Uncached.new();slow.profiles=profiles;var a;var b
				if repeat%2==0:a=timed(fast,view);b=timed(slow,view)
				else:b=timed(slow,view);a=timed(fast,view)
				check(a.decision==b.decision and fast.ranked==slow.ranked,"repeated benchmark choices and scores match")
				report.samples.append({"mode":mode,"turn_pressure":turn,"repeat":repeat,"optimized":a,"reference":b,"candidates":fast.ranked.size()})
				report.checks=checks;report.failures=failures;save_report(report)
			print("CPU BENCH ",mode," pressure=",turn)
	print("V41 CPU PERFORMANCE ",checks-failures,"/",checks);quit(1 if failures else 0)

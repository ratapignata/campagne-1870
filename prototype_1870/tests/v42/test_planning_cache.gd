extends "res://tests/test_ai_compat0833.gd"
const Reference=preload("res://tests/v42/reference_ai_lot6.gd")
const Planner=preload("res://war_engine/ai/planning_engine.gd")
func _initialize():
	profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
	var raw=FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v42_experimental.json");var p=JSON.parse_string(raw);var args=OS.get_cmdline_user_args();var samples=[]
	for source in ["initial"]+Array(args):
		for mode in ["medium","hard"]:
			var e=Rules.new(p);e.new_game(0,mode);e.state.seed=187037;e.state.ai_style=0
			if source!="initial":check(Store.new(source,raw.sha256_text()).load_game(e),"load parity checkpoint")
			e.state.ai_difficulty=mode
			if int(e.state.side)==0:e.end_side()
			for repeat in range(2):
				var view=e.observation(1);var original=view.duplicate(true);var fast=bot();var reference=Reference.new();reference.profiles=profiles
				var start=Time.get_ticks_usec();var a=reference.choose(view);var slow_us=Time.get_ticks_usec()-start
				start=Time.get_ticks_usec();var b=fast.choose(view);var fast_us=Time.get_ticks_usec()-start
				check(a==b,"exact chosen decision "+source+" "+mode)
				check(reference.ranked==fast.ranked,"all candidate scores and order identical")
				check(view==original,"observation unchanged")
				var planner=Planner.new(view.pack,view.state)
				var plain=Rules.new(view.pack,view.state)
				if source=="initial" and mode=="medium" and repeat==0:
					for a_cell in range(planner.width*planner.height):
						for b_cell in range(planner.width*planner.height):check(planner.distance(a_cell,b_cell)==plain.distance(a_cell,b_cell),"exact geometric distance")
				for cell in range(planner.width*planner.height):check(planner.unit_at(cell)==plain.unit_at(cell),"initial occupied cell parity")
				for n in range(planner.state.units.size()):
					var old=planner.state.units[n].cell.duplicate();var dest=planner.index(Vector2i(29,19))
					if planner.unit_at(dest)>=0:continue
					planner.set_planning_cell(n,[29,19]);plain.state.units[n].cell=[29,19]
					check(planner.unit_at(dest)==plain.unit_at(dest),"hypothetical occupancy update")
					planner.set_planning_cell(n,old);plain.state.units[n].cell=old
					check(planner.unit_at(dest)==plain.unit_at(dest),"hypothetical occupancy restored")
				samples.append({"source":source,"mode":mode,"repeat":repeat,"reference_us":slow_us,"cached_us":fast_us,"decision":a,"candidates":fast.ranked.size()})
				check(dispatch(e,a),"parity decision legal in live engine")
	var f=FileAccess.open("user://planning_cache.json",FileAccess.WRITE);f.store_string(JSON.stringify({"checks":checks,"failures":failures,"samples":samples},"\t"));f.close()
	print("V42 PLANNING CACHE ",checks-failures,"/",checks);quit(1 if failures else 0)

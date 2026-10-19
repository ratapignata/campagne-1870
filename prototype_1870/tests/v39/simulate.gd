extends "res://tests/v36/test_ai_active.gd"
const Reference=preload("res://tests/v39/reference_ai_v38.gd")
func snapshot(e,turn,report):
	var m=metrics(e);m.turn=turn;m.counts=report.counts.duplicate(true);m.prepared_assaults=report.prepared_assaults;m.flank_moves=report.flank_moves
	var isolation=0;var command=0;var supply=0;var distance_sum=0.0;var count=0
	for n in range(e.state.units.size()):
		if not e.alive(n):continue
		var u=e.state.units[n]
		if int(u.side)==0:
			if not u.get("command_ok",true):command+=1
			if not u.get("supply_ok",true):supply+=1
			if not u.get("supply_ok",true) and not u.get("command_ok",true):isolation+=1
		elif not e.headquarters(n):
			var nearest=999
			for goal in e.objective_definitions():nearest=mini(nearest,e.distance(e.unit_cell(u),e.objective_cell(goal)))
			distance_sum+=nearest;count+=1
	m.french_isolated=isolation;m.french_uncommanded=command;m.french_unsupplied=supply;m.prussian_mean_objective_distance=distance_sum/maxi(1,count)
	return m
func _initialize():
	var args=OS.get_cmdline_user_args();var mode=args[0];var seed_value=int(args[1]);var reference=mode=="baseline"
	var p=scenario();var e=Rules.new(p);e.new_game(0,"medium");e.state.seed=seed_value;e.state.ai_style=0
	profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
	var french=Reference.new();french.profiles=profiles
	var prussian=Reference.new() if reference else bot();prussian.profiles=profiles
	var report={"mode":mode,"seed":seed_value,"fixture":"14 units, original map, synthetic deployment, no scheduled reinforcements; V38 medium French active policy; all runs 20 turns", "counts":[{},{}],"actions":[],"snapshots":[],"captures":[],"idle_attacks":[],"prepared_assaults":0,"flank_moves":0,"checks":0,"failures":0}
	var bombardment={};var start_time=Time.get_ticks_msec()
	for step in range(4000):
		if e.state.finished:break
		var side=int(e.state.side);var turn=int(e.state.turn);e.state.ai_difficulty="medium" if side==0 or reference else mode
		var ai=french if side==0 else prussian;var view=e.observation(side);var before_view=view.duplicate(true);var d=ai.choose(view)
		check(view==before_view,"observation unmodified");var owners=e.state.objective_owners.duplicate();var n=e.unit_index(str(d.get("unit","")))
		if d.kind=="end":
			var available=opportunities(e,side)
			if not available.is_empty():report.idle_attacks.append({"turn":turn,"side":side,"units":available})
		if n>=0 and d.kind=="fire" and e.artillery(n):
			report.counts[side]["artillery_fire"]=int(report.counts[side].get("artillery_fire",0))+1
			if side==1:bombardment[str(d.target)]=turn
		if side==1 and d.kind=="assault" and bombardment.get(str(d.target),-1)==turn:report.prepared_assaults+=1
		if side==1 and d.kind=="move" and not e.artillery(n) and not e.headquarters(n):
			var a=e.unit_cell(e.state.units[n]);var b=int(d.path[-1]);var flanked=false
			for j in range(e.state.units.size()):
				if int(e.state.units[j].side)!=0 or not e.alive(j) or not e.visible_to(1,j):continue
				var foe=e.unit_cell(e.state.units[j])
				if e.distance(a,foe)<=4 and e.distance(b,foe)<=3 and e.cell(b).y<e.cell(foe).y and e.cell(a).y>=e.cell(foe).y:flanked=true
			if flanked:report.flank_moves+=1
		check(dispatch(e,d),"legal decision");check(e.validate(e.state),"valid authoritative state")
		if failures>0:break
		report.counts[side][d.kind]=int(report.counts[side].get(d.kind,0))+1;report.actions.append({"turn":turn,"side":side,"decision":d})
		for id in owners:
			if owners[id]!=e.state.objective_owners[id]:report.captures.append({"turn":turn,"objective":id,"owner":e.state.objective_owners[id]})
		if d.kind=="end" and side==1:
			report.snapshots.append(snapshot(e,turn,report));report.checks=checks;report.failures=failures
			var f=FileAccess.open("user://simulation.json",FileAccess.WRITE);f.store_string(JSON.stringify(report));f.close()
			var save=Store.new("user://checkpoint.json","v39-simulation");check(save.save_game(e),"checkpoint saved")
			print(mode," ",seed_value," turn=",turn," actions=",step+1," elapsed_s=",(Time.get_ticks_msec()-start_time)/1000)
	check(e.state.finished and e.state.turn==20,"complete 20-turn active battle")
	report.final=snapshot(e,20,report);report.elapsed_ms=Time.get_ticks_msec()-start_time;report.checks=checks;report.failures=failures
	var f=FileAccess.open("user://simulation.json",FileAccess.WRITE);f.store_string(JSON.stringify(report,"\t"));f.close()
	print("V39 SIM ",mode," ",checks-failures,"/",checks);quit(1 if failures else 0)

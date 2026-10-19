extends "res://tests/v36/test_ai_active.gd"
func artillery_snapshot(e,n):
	var u=e.state.units[n];var targets=[]
	for j in range(e.state.units.size()):
		if e.fire_status(n,j)=="ok":targets.append(e.state.units[j].id)
	return {"unit":u.id,"cell":u.cell.duplicate(),"ap":u.ap,"deployed":u.deployed,"ammo":u.get("ammo_level",0),"legal_targets":targets,"command":u.get("command_ok",true),"supply":u.get("supply_ok",true)}
func _initialize():
	profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
	var args=OS.get_cmdline_user_args();var mode=args[0];var french_mode=args[2] if args.size()>2 else "medium";var e=Rules.new(scenario());e.new_game(0,"medium");e.state.seed=int(args[1]) if args.size()>1 else 187037;e.state.ai_style=0;var ai=bot()
	var report={"mode_prussian":mode,"mode_french":french_mode,"fixture":"14 units, synthetic deployment on original terrain, no reinforcements; identical initial state except selected Prussian policy", "seed":e.state.seed,"counts":[{},{}],"actions":[],"captures":[],"boundaries":[],"artillery":[],"artillery_idle":[],"decision_ms":[],"completed_turns":0,"benchmark_snapshots":[]}
	for step in range(4000):
		if e.state.finished:break
		var side=int(e.state.side);var turn=int(e.state.turn);e.state.ai_difficulty=mode if side==1 else french_mode
		var before=Time.get_ticks_msec();var d=ai.choose(e.observation(side));report.decision_ms.append(Time.get_ticks_msec()-before)
		var n=e.unit_index(str(d.get("unit","")));var record={};var owners=e.state.objective_owners.duplicate()
		if n>=0 and e.artillery(n):
			record=artillery_snapshot(e,n);record.turn=turn;record.side=side;record.kind=d.kind
			if d.has("target"):
				var j=e.unit_index(d.target);record.target=d.target;record.target_type=e.weapon(j).get("unit_type","");record.target_cell=e.state.units[j].cell.duplicate();record.objective_target=not e.objective_at(e.unit_cell(e.state.units[j])).is_empty()
		if d.kind=="end":
			for j in range(e.state.units.size()):
				if e.can_act(j) and e.artillery(j):report.artillery_idle.append({"turn":turn,"side":side,"snapshot":artillery_snapshot(e,j)})
		var ok=dispatch(e,d);check(ok,"comparative command accepted "+mode);check(e.validate(e.state),"comparative state valid "+mode)
		if not ok or failures>0:break
		if not record.is_empty():record.after=artillery_snapshot(e,n);report.artillery.append(record)
		report.counts[side][d.kind]=int(report.counts[side].get(d.kind,0))+1;report.actions.append({"turn":turn,"side":side,"decision":d})
		for id in owners:
			if owners[id]!=e.state.objective_owners[id]:report.captures.append({"turn":turn,"objective":id,"owner":e.state.objective_owners[id]})
		if d.kind=="end":
			if side==1:report.completed_turns+=1
			report.boundaries.append(metrics(e));print(mode," turn=",turn," side=",side," actions=",step+1)
			if side==0 and turn in [5,10,15,20]:report.benchmark_snapshots.append(e.state.duplicate(true))
			var checkpoint=FileAccess.open("user://comparison_checkpoint.json",FileAccess.WRITE);checkpoint.store_string(JSON.stringify({"state":e.state,"report":report}));checkpoint.close()
	check(e.state.finished and report.completed_turns==int(e.pack.rules.turns),"comparative battle completed")
	report.final=metrics(e);report.checks=checks;report.failures=failures
	var f=FileAccess.open("user://compare_"+mode+".json",FileAccess.WRITE);f.store_string(JSON.stringify(report,"\t"));f.close()
	print("COMPARISON ",mode," ",checks-failures,"/",checks," ",JSON.stringify(report.final));quit(1 if failures else 0)

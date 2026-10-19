extends "res://tests/v36/test_ai_active.gd"
const Save=preload("res://war_engine/platform/save_store.gd")
func pending_count(e):
	var total=0
	for u in e.state.units:
		if u.get("pending",false):total+=1
	return total
static func scheduled_reinforcements_consistent(e):
	for u in e.state.units:
		if not u.get("pending",false):continue
		if int(u.get("arrival_turn",1))<=int(e.state.turn) and e.unit_at(e.unit_cell(u))<0:return false
	return true
func _initialize():
	var mode=OS.get_cmdline_user_args()[0] if not OS.get_cmdline_user_args().is_empty() else "medium"
	var raw=FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v42_experimental.json")
	var p=JSON.parse_string(raw);var e=Rules.new(p);e.new_game(0,mode);e.state.seed=187037;e.state.ai_style=0
	profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"));var ai=bot()
	var save=Save.new("user://full_battle_checkpoint.json",raw.sha256_text())
	var args=OS.get_cmdline_user_args();var resume="--resume" in args
	var report={"label":"V42_FULL_95","fixture":"Experimental V42: 95 units, original lot 6 deployment, strengths, reinforcements and fog. Both sides controlled by AI.", "seed":187037,"difficulty":mode,"ai_style":0,"start_turn":1,"counts":[{},{}],"actions":[],"boundaries":[],"captures":[],"inactive_legal_attacks":[],"completed_turns":0,"max_routed":[0,0],"checks":0,"failures":0,"decision_ms":[],"elapsed_ms":0}
	if resume:
		if not save.load_game(e):printerr("FAIL cannot resume checkpoint");quit(1);return
		report=JSON.parse_string(FileAccess.get_file_as_string("user://full_battle_report.json"));checks=int(report.checks);failures=int(report.failures)
	check(e.validate(e.state) and e.state.units.size()==95,"full actual scenario starts valid")
	var started=Time.get_ticks_msec();var previous_ms=int(report.elapsed_ms)
	print("FULL BATTLE START turn=",e.state.turn," units=",e.state.units.size()," pending=",pending_count(e)," resume=",resume)
	var cap=int(p.units.size())*int(p.rules.ap)*int(p.rules.turns)+2*int(p.rules.turns)+100
	for step in range(report.actions.size(),cap):
		if e.state.finished:break
		var side=int(e.state.side);var turn=int(e.state.turn);var owners=e.state.objective_owners.duplicate();var before=Time.get_ticks_msec();var view=e.observation(side)
		var d=ai.choose(view);var elapsed=Time.get_ticks_msec()-before;report.decision_ms.append(elapsed)
		var tactical=[] # Separate tactical tests; exclude exhaustive scan from full simulation.
		var ok=dispatch(e,d)
		if not ok:
			check(false,"rejected full scenario command "+JSON.stringify(d));report.rejected={"turn":turn,"side":side,"decision":d};break
		check(e.validate(e.state),"full state valid after command "+str(step))
		if failures>0:break
		report.counts[side][d.kind]=int(report.counts[side].get(d.kind,0))+1;report.actions.append({"turn":turn,"side":side,"decision":d,"cannon":e.artillery(e.unit_index(str(d.get("unit",""))))})
		for id in owners:
			if owners[id]!=e.state.objective_owners[id]:report.captures.append({"turn":turn,"side":side,"objective":id,"owner":e.state.objective_owners[id]})
		for camp in [0,1]:report.max_routed[camp]=maxi(int(report.max_routed[camp]),e.routed_count(camp))
		if d.kind=="end":
			if not tactical.is_empty():report.inactive_legal_attacks.append({"turn":turn,"side":side,"units":tactical})
			if side==1:report.completed_turns+=1
			var boundary=metrics(e);boundary.pending=pending_count(e);boundary.actions=report.actions.size();report.boundaries.append(boundary)
			print("FULL BOUNDARY turn=",turn," side=",side," actions=",report.actions.size()," counts=",JSON.stringify(report.counts)," pending=",boundary.pending," losses=",boundary.losses," elapsed_s=",(previous_ms+Time.get_ticks_msec()-started)/1000)
		if step%10==0:print("FULL PROGRESS turn=",turn," side=",side," action=",step+1," kind=",d.kind," decision_ms=",elapsed)
		if step%20==0 or d.kind=="end":
			report.elapsed_ms=previous_ms+Time.get_ticks_msec()-started;report.checks=checks;report.failures=failures
			check(save.save_game(e),"periodic real save checkpoint")
			var f=FileAccess.open("user://full_battle_report.json",FileAccess.WRITE);f.store_string(JSON.stringify(report,"\t"));f.close()
	check(e.state.finished and report.completed_turns==int(p.rules.turns),"Configured actual turns completed with both active AIs")
	check(report.counts[0].get("fire",0)>0 and report.counts[1].get("fire",0)>0,"both sides fired")
	check(scheduled_reinforcements_consistent(e),"scheduled reinforcements entered or legally waiting at occupied entry")
	check(save.save_game(e),"final full battle physical save")
	var copy=Rules.new(p);check(save.load_game(copy) and copy.validate(copy.state),"final full battle reload validates")
	check(JSON.parse_string(JSON.stringify(copy.state))==JSON.parse_string(JSON.stringify(e.state)),"exact final full battle reload")
	report.loss_history=e.state.loss_history;check(e.state.loss_history.size()==20,"20 end-of-turn snapshots");report.final=metrics(e);report.final.pending=pending_count(e);report.elapsed_ms=previous_ms+Time.get_ticks_msec()-started;report.checks=checks;report.failures=failures
	var f=FileAccess.open("user://full_battle_report.json",FileAccess.WRITE);f.store_string(JSON.stringify(report,"\t"));f.close()
	print("FULL RESULT ",JSON.stringify({"turns":report.completed_turns,"counts":report.counts,"captures":report.captures,"final":report.final,"max_routed":report.max_routed,"elapsed_s":report.elapsed_ms/1000,"checks":checks,"failures":failures}))
	print("V42 FULL BATTLE ",checks-failures,"/",checks);quit(1 if failures else 0)

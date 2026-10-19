extends "res://tests/v36/test_ai_active.gd"
const French=preload("res://tests/v42_lot8/mobile_defence.gd")
func _initialize():
	var args=OS.get_cmdline_user_args();var mode=args[0];var seed_value=int(args[1])
	var p=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json"))
	var wanted={"fr_1":[11,5],"fr_2":[15,4],"fr_3":[18,6],"fr_4":[12,4],"qg_fr_Ducrot":[13,3],"art_fr_Ducrot0":[11,3],"pru_36":[12,7],"pru_37":[15,7],"pru_38":[18,8],"pru_54":[13,10],"qg_pr_Sandrart":[14,9],"art_pr_Sandrart0":[10,8]}
	var units=[]
	for id in wanted:
		for u in p.units:
			if u.id==id:
				var copy=u.duplicate(true);copy.cell=wanted[id];copy.initial_strength=1000;copy.arrival_turn=1;copy.command_group="fr_Ducrot" if copy.side==0 else "pr_Sandrart";units.append(copy);break
	p.units=units
	var e=Rules.new(p);e.new_game(0,mode);e.state.seed=seed_value;e.state.ai_style=0
	profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"));var ai=bot();var french=French.new()
	check(units.size()==12 and e.validate(e.state),"12-unit tactical fixture valid")
	var counts=[{},{}];var actions=[];var captures=[];var abandoned=[];var times=[];var final_turns=0
	for step in range(6000):
		if e.state.finished:break
		var side=int(e.state.side);var turn=int(e.state.turn);var old=e.state.objective_owners.duplicate();var view=e.observation(side);var start=Time.get_ticks_msec()
		var d=french.choose(view) if side==0 else ai.choose(view);times.append(Time.get_ticks_msec()-start)
		if side==1 and d.kind=="end":
			var opportunity=opportunities(e,1)
			if not opportunity.is_empty():abandoned.append({"turn":turn,"units":opportunity})
		check(dispatch(e,d) and e.validate(e.state),"legal tactical command")
		if failures:break
		counts[side][d.kind]=int(counts[side].get(d.kind,0))+1;actions.append({"turn":turn,"side":side,"decision":d})
		for id in old:
			if old[id]!=e.state.objective_owners[id]:captures.append({"turn":turn,"side":side,"objective":id,"owner":e.state.objective_owners[id]})
		if side==1 and d.kind=="end":final_turns+=1;print("TACTICAL ",mode," ",seed_value," turn ",final_turns)
	check(e.state.finished and final_turns==20,"20 tactical turns complete")
	check(counts[0].get("move",0)>0 and counts[0].get("fire",0)>0,"French move and fire")
	var f=FileAccess.open("user://tactical_mobile.json",FileAccess.WRITE)
	f.store_string(JSON.stringify({"fixture":"12 units, each initially 1000 men, synthetic deployment on original map, V43 variant B; mobile French test policy, real German production AI. Tactical stress test, not full battle balance.","mode":mode,"seed":seed_value,"counts":counts,"actions":actions,"captures":captures,"legal_attacks_left_at_end":abandoned,"decision_ms":times,"turns":final_turns,"final":metrics(e),"checks":checks,"failures":failures},"\t"));f.close()
	print("V43 TACTICAL ",checks-failures,"/",checks);quit(1 if failures else 0)

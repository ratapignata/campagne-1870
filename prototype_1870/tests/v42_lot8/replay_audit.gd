extends "res://tests/v36/test_ai_active.gd"
func _initialize():
	var args=OS.get_cmdline_user_args();var d=JSON.parse_string(FileAccess.get_file_as_string(args[0]));var p=JSON.parse_string(FileAccess.get_file_as_string(args[1]))
	if "--tactical" in args:
		var wanted={"fr_1":[11,5],"fr_2":[15,4],"fr_3":[18,6],"fr_4":[12,4],"qg_fr_Ducrot":[13,3],"art_fr_Ducrot0":[11,3],"pru_36":[12,7],"pru_37":[15,7],"pru_38":[18,8],"pru_54":[13,10],"qg_pr_Sandrart":[14,9],"art_pr_Sandrart0":[10,8]}
		var units=[]
		for id in wanted:
			for u in p.units:
				if u.id==id:
					var copy=u.duplicate(true);copy.cell=wanted[id];copy.initial_strength=1000;copy.arrival_turn=1;copy.command_group="fr_Ducrot" if copy.side==0 else "pr_Sandrart";units.append(copy);break
		p.units=units
	var mode=str(d.get("difficulty",d.get("mode","medium")));var e=Rules.new(p);e.new_game(0,mode);e.state.seed=int(d.seed);e.state.ai_style=0
	var ends=[];var exposure=[];var isolation=[];var deaths=[];var before_prisoners=0;var arrivals=[];var replay_step=0
	for a in d.actions:
		replay_step+=1
		if replay_step%100==0:print("REPLAY PROGRESS ",replay_step,"/",d.actions.size()," turn=",a.turn)
		check(int(e.state.turn)==int(a.turn) and int(e.state.side)==int(a.side),"replay phase matches")
		if int(a.side)==1 and a.decision.kind=="end":
			var observed=e.observation(1);var v=Rules.new(observed.pack,observed.state);var fire=[];var assault=[]
			for n in range(v.state.units.size()):
				if not v.can_act(n):continue
				for j in range(v.state.units.size()):
					if v.fire_status(n,j)=="ok":fire.append({"unit":v.state.units[n].id,"target":v.state.units[j].id})
					if v.assault_status(n,j)=="ok":assault.append({"unit":v.state.units[n].id,"target":v.state.units[j].id,"ratio":v.attack_power_against(n,j)/maxf(1,v.defence_power_against(j,n))})
			ends.append({"turn":a.turn,"legal_observed_fire":fire,"legal_observed_assaults":assault})
			var guns=[];var cut=[]
			for n in range(e.state.units.size()):
				if not e.alive(n) or int(e.state.units[n].side)!=1:continue
				if e.artillery(n) and e.enemy_distance(n,e.unit_cell(e.state.units[n]))<=1:guns.append(e.state.units[n].id)
				if not e.state.units[n].get("command_ok",true) and not e.state.units[n].get("supply_ok",true):cut.append(e.state.units[n].id)
			exposure.append({"turn":a.turn,"adjacent_enemy_batteries":guns});isolation.append({"turn":a.turn,"units":cut})
		var incoming={}
		if a.decision.kind=="end":
			for u in e.state.units:
				if u.get("pending",false):incoming[u.id]=true
		check(dispatch(e,a.decision),"replay command legal")
		# The originating campaign already validates every intermediate state.
		# Replay checks command legality, phase identity and exact final state.
		if failures:break
		for u in e.state.units:
			if incoming.has(u.id) and not u.get("pending",false):arrivals.append({"id":u.id,"side":u.side,"turn":e.state.turn,"command_group":u.command_group,"command_ok":u.get("command_ok",true),"supply_ok":u.get("supply_ok",true)})
		var captured=e.prisoners(1)
		if captured>before_prisoners:deaths.append({"turn":a.turn,"side":a.side,"command":a.decision,"new_german_prisoners":captured-before_prisoners});before_prisoners=captured
	check(e.validate(e.state),"replay final state valid")
	var final=metrics(e);var expected=d.final.duplicate(true);expected.erase("pending")
	check(JSON.parse_string(JSON.stringify(final))==expected,"deterministic final replay exact")
	var f=FileAccess.open("user://replay_audit.json",FileAccess.WRITE);f.store_string(JSON.stringify({"checks":checks,"failures":failures,"end_phases":ends,"battery_exposure":exposure,"isolated_germans":isolation,"prisoner_events":deaths,"arrivals":arrivals},"\t"));f.close()
	print("LOT8 REPLAY ",checks-failures,"/",checks);quit(1 if failures else 0)

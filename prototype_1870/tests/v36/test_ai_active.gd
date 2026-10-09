extends "res://tests/test_ai_compat0833.gd"
# Real 30x20 map; a declared, reduced 14-unit battle, not the 81-unit campaign.
func scenario():
	var p=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial.json"))
	var roster=[[0,[11,5]],[1,[15,4]],[2,[18,6]],[3,[12,4]],[4,[16,4]],[56,[13,3]],[57,[11,3]], [34,[12,7]],[35,[15,7]],[36,[18,8]],[37,[14,9]],[52,[10,8]],[66,[13,10]],[67,[16,9]]]
	var units=[]
	for item in roster:
		var u=p.units[item[0]].duplicate(true);u.cell=item[1];u.arrival_turn=1;u.command_group="fr_Ducrot" if u.side==0 else "pr_Sandrart";units.append(u)
	p.units=units;return p
func opportunities(e,side):
	var result=[]
	for n in range(e.state.units.size()):
		if int(e.state.units[n].side)!=side or not e.can_act(n):continue
		for j in range(e.state.units.size()):
			if e.fire_status(n,j)=="ok" or e.assault_status(n,j)=="ok":result.append(e.state.units[n].id);break
	return result
func metrics(e):
	var spread=[{},{}]
	for n in range(e.state.units.size()):
		if not e.alive(n):continue
		var u=e.state.units[n];var closest="";var distance=10000
		for goal in e.objective_definitions():
			var d=e.distance(e.unit_cell(u),e.index(Vector2i(goal.cell[0],goal.cell[1])))
			if d<distance:distance=d;closest=goal.id
		spread[int(u.side)][closest]=int(spread[int(u.side)].get(closest,0))+1
	return {"turn":e.state.turn,"finished":e.state.finished,"owners":e.state.objective_owners.duplicate(),"losses":[e.losses(0),e.losses(1)],"prisoners":[e.prisoners(0),e.prisoners(1)],"routed":[e.routed_count(0),e.routed_count(1)],"distribution":spread,"score":e.result_for(1)}
func simulation(label,start_turn,seed,difficulty):
	var e=Rules.new(scenario());e.new_game(0,difficulty);e.state.seed=seed;e.state.turn=start_turn;e.state.ai_style=0
	# Synthetic late battle: disrupted defenders, contested objectives, spent ammo.
	if start_turn>1:
		e.state.owner=0;e.state.objective_owners={"froeschwiller":0,"elsasshausen":1,"niederwald":0};e.state.units[8].cell=[15,4];e.state.units[1].cell=[16,3]
		for n in [0,3,7,9]:
			var u=e.state.units[n];u.casualties=roundi(u.initial_strength*0.3);u.strength=u.initial_strength-u.casualties;u.cohesion=55;u.morale="shaken";u.ammo_level=1
		e.refresh_support();e.refresh_intel()
	check(e.validate(e.state),label+" initial fixture valid")
	var ai=bot();var counts=[{},{}];var actions=[];var boundaries=[];var captures=[];var inactive=[];var turns_completed=0
	for step in range(4000):
		if e.state.finished:break
		var side=int(e.state.side);var turn=int(e.state.turn);var owners=e.state.objective_owners.duplicate();var d=ai.choose(e.observation(side));var tactical=[]
		if d.kind=="end":tactical=opportunities(e,side)
		var ok=dispatch(e,d)
		if not ok:check(false,label+" rejected command "+JSON.stringify(d));break
		counts[side][d.kind]=int(counts[side].get(d.kind,0))+1
		actions.append({"turn":turn,"side":side,"decision":d})
		for id in owners:
			if owners[id]!=e.state.objective_owners[id]:captures.append({"turn":turn,"objective":id,"owner":e.state.objective_owners[id]})
		if d.kind=="end":
			if not tactical.is_empty():inactive.append({"turn":turn,"side":side,"units_with_legal_attack":tactical})
			if side==1:turns_completed+=1
			boundaries.append(metrics(e))
			print(label," boundary ",turn,"/",side," actions ",actions.size())
			check(e.validate(e.state),label+" boundary state "+str(turn)+"/"+str(side))
	check(e.state.finished,label+" battle completed")
	check(counts[0].get("fire",0)>0 and counts[1].get("fire",0)>0,label+" both sides fire actively")
	check(counts[1].get("move",0)>0,label+" Prussian offensive progression")
	var report={"label":label,"fixture":"14 units on unchanged historical map; synthetic deployment", "start_turn":start_turn,"seed":seed,"difficulty":difficulty,"completed_turns":turns_completed,"counts":counts,"captures":captures,"inactive_legal_attacks":inactive,"boundaries":boundaries,"final":metrics(e),"actions":actions}
	var file=FileAccess.open("user://"+label+".json",FileAccess.WRITE);file.store_string(JSON.stringify(report,"\t"));file.close()
	print("RESULT ",label," ",JSON.stringify({"counts":counts,"captures":captures,"inactive":inactive.size(),"final":report.final}))
func _initialize():
	profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
	var args=OS.get_cmdline_user_args();var label=args[0] if not args.is_empty() else "AB_active"
	match label:
		"C_turn12":simulation(label,12,187012,"medium")
		"E_final":simulation(label,17,187018,"hard")
		_:simulation(label,1,187036,"medium")
	print("V36 AI ACTIVE ",checks-failures,"/",checks);quit(1 if failures else 0)

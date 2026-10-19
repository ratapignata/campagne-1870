extends "res://tests/test_ai_compat0833.gd"
func _initialize():
	var raw=FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v42_experimental.json")
	var p=JSON.parse_string(raw);var e=Rules.new(p);e.new_game(0,"medium")
	var counts=[0,0];var totals=[0,0];var ids={};var occupied={}
	for n in range(e.state.units.size()):
		var u=e.state.units[n];counts[int(u.side)]+=1;totals[int(u.side)]+=int(u.initial_strength)
		check(not ids.has(u.id),"unique id "+u.id);ids[u.id]=true
		check(e.unit_cell(u)>=0,"entry inside map "+u.id)
		if not u.pending:
			check(not occupied.has(str(u.cell)),"unique initial position");occupied[str(u.cell)]=true
	check(counts==[45,50] and totals==[45550,95000],"V42 exact roster and strengths")
	check(int(p.rules.turns)==20 and int(p.rules.victory.final_control)==60 and int(p.rules.victory.duration)==20 and int(p.rules.victory.military)==20,"20 turns and 60/20/20")
	for n in range(e.state.units.size()):
		if e.cavalry(n):check(int(p.unit_types.cavalry.charge_ap)==8 and (not e.alive(n) or e.assault_cost(n)==8),"cavalry charge remains 2 AP")
	e.apply_losses(0,17);e.apply_losses(34,23)
	e.end_side();check(e.state.loss_history.is_empty(),"no snapshot at half-turn")
	e.end_side();check(e.state.loss_history.size()==1 and e.state.loss_history[0].losses==[17,23],"snapshot at end of turn one")
	check(not e.observation(0).state.has("loss_history"),"history never leaks to AI observation")
	var store=Store.new("user://v42_history.json",raw.sha256_text());var copy=Rules.new(p)
	check(store.save_game(e) and store.load_game(copy) and copy.state.loss_history==e.state.loss_history,"history save and reload")
	var bad=e.state.duplicate(true);bad.loss_history[0].losses[0]=-1;check(not e.validate(bad),"reject negative history")
	bad=e.state.duplicate(true);bad.loss_history.append(bad.loss_history[0].duplicate(true));check(not e.validate(bad),"reject duplicate turn")
	bad=e.state.duplicate(true);bad.loss_history[0].losses[0]=999999;check(not e.validate(bad),"reject totals above actual losses")
	copy.state.erase("loss_history");check(copy.validate(copy.state),"legacy saves without history remain valid")
	check(store.save_game(copy) and store.load_game(copy),"legacy history-free roundtrip")
	copy.end_side();copy.end_side();check(copy.state.loss_history.size()==1 and int(copy.state.loss_history[0].turn)==2,"legacy snapshot starts now without invented past")
	var arrivals=[]
	while not e.state.finished:
		var pending={}
		for u in e.state.units:
			if u.pending:pending[u.id]=true
		e.end_side();check(e.validate(e.state),"valid turn boundary")
		for n in range(e.state.units.size()):
			var u=e.state.units[n]
			if pending.has(u.id) and not u.pending:
				check(int(e.state.turn)>=int(u.arrival_turn),"no premature reinforcement")
				check(e.unit_cell(u)==e.index(Vector2i(int(p.units[n].cell[0]),int(p.units[n].cell[1]))),"reinforcement at scheduled position")
				arrivals.append({"id":u.id,"scheduled":u.arrival_turn,"actual":e.state.turn})
	check(e.state.loss_history.size()==20 and int(e.state.loss_history[-1].turn)==20,"all 20 turns including final snapshot")
	var before=e.state.loss_history.duplicate(true);e.end_side();check(before==e.state.loss_history,"finished end_side is idempotent")
	var f=FileAccess.open("user://contract.json",FileAccess.WRITE);f.store_string(JSON.stringify({"checks":checks,"failures":failures,"arrivals_no_movement":arrivals,"history":e.state.loss_history},"\t"));f.close()
	print("V42 CONTRACT ",checks-failures,"/",checks);quit(1 if failures else 0)

extends "res://tests/test_ai_compat0833.gd"
const French=preload("res://tests/v42_lot8/mobile_defence.gd")
func _initialize():
	var raw=FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v42_lot8.json");var p=JSON.parse_string(raw)
	var original=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v42_experimental.json"))
	check(p.rules==original.rules and p.weapons==original.weapons and p.map==original.map,"all rules weapons terrain unchanged")
	var totals=[0,0];var counts=[0,0];var heads={};var top=0
	for u in p.units:
		totals[int(u.side)]+=int(u.initial_strength);counts[int(u.side)]+=1
		if str(u.id).begins_with("qg_"):heads[u.command_group]=u.id
		if u.side==1:top=maxi(top,int(u.initial_strength))
	check(totals==[45550,95000] and counts==[45,50],"exact roster target")
	check(top==2900,"largest German unit reduced to 2900")
	for i in range(p.units.size()):
		var u=p.units[i];var before=original.units[i]
		check(u.id==before.id and u.cell==before.cell and u.arrival_turn==before.arrival_turn,"identity position arrival preserved")
		check(heads.has(u.command_group),"every command group has a real HQ")
		if u.side==0:check(u==before,"French unit unchanged")
	var e=Rules.new(p);e.new_game(0,"medium")
	for u in p.units:
		if not str(u.id).begins_with("v42_de_reserve"):continue
		var entry=e.index(Vector2i(u.cell[0],u.cell[1]));var closest=10000;var assigned=10000
		for h in p.units:
			if h.side!=1 or not str(h.id).begins_with("qg_"):continue
			var distance=e.distance(entry,e.index(Vector2i(h.cell[0],h.cell[1])));closest=mini(closest,distance)
			if h.command_group==u.command_group:assigned=distance
		check(assigned==closest,"reserve assigned to one of the nearest original HQs using actual hex geometry")
	check(e.validate(e.state),"initial candidate valid")
	while not e.state.finished:
		e.end_side();check(e.validate(e.state),"20-turn candidate boundary valid")
	check(e.state.loss_history.size()==20,"candidate records 20 snapshots")
	var legacy=e.state.duplicate(true)
	for snapshot in legacy.loss_history:snapshot.casualties=snapshot.losses;snapshot.erase("losses")
	check(e.validate(legacy),"recovered V42 casualty-history accepted")
	e.state=legacy;e.normalize()
	check(e.state.loss_history[0].has("losses") and not e.state.loss_history[0].has("casualties"),"legacy history normalized without losing records")
	var store=Store.new("user://lot8_history.json",raw.sha256_text());var copy=Rules.new(p)
	check(store.save_game(e) and store.load_game(copy) and copy.state.loss_history==e.state.loss_history,"normalized legacy history roundtrip")
	var bad=e.state.duplicate(true);bad.loss_history[0].casualties=[999,999]
	check(not e.validate(bad),"conflicting history keys rejected")
	# Twin hidden worlds: the test opponent, too, must receive only visible information.
	e=Rules.new(p);e.new_game(0,"medium");var twin=Rules.new(p);twin.state=e.state.duplicate(true)
	for n in range(twin.state.units.size()):
		if int(twin.state.units[n].side)==1 and not e.visible_to(0,n):
			twin.state.units[n].strength-=1;twin.state.units[n].casualties+=1
	var a=e.observation(0);var b=twin.observation(0)
	check(a==b,"mobile opponent sees no hidden strengths")
	var opponent=French.new();var before=a.duplicate(true);var command=opponent.choose(a)
	check(a==before and command==opponent.choose(b),"mobile opponent nonmutation and hidden-world parity")
	check(command.kind=="move" and dispatch(e,command),"mobile opponent makes legal movement")
	var f=FileAccess.open("user://contract_lot8.json",FileAccess.WRITE);f.store_string(JSON.stringify({"checks":checks,"failures":failures},"\t"));f.close()
	print("LOT8 CONTRACT ",checks-failures,"/",checks);quit(1 if failures else 0)

extends "res://tests/test_river0814.gd"
func _initialize():
	data=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/prototype.json"))
	var e=fixture()
	check(e.max_ap(10)==16 and e.max_ap(11)==16 and e.assault_cost(10)==8,"both cavalries 4 PA, charge 2 PA")
	for side in [0,1]:
		e=fixture();e.state.side=side;var n=0 if side==0 else 4
		put(e,n,102);e.state.units[n].formation="line"
		var before=e.state.duplicate(true)
		check(e.move(n,[102,132,162,192,222])=="moved" and e.state.units[n].ap==0 and e.state.units[n].done,"move spends all PA")
		check(e.undo_status()=="ok" and e.undo() and e.state==before,"zero-PA undo restores exact state: "+str(side))
		check(e.move(n,[102,132])=="moved","ordinary move before save")
		var store=Store.new("user://undo0816_"+str(side)+".json","0816");check(store.save_game(e),"save reversible movement")
		var copy=fixture();check(store.load_game(copy) and copy.undo_status()=="ok" and copy.undo() and copy.state==before,"undo survives save and reload")
	# Only the opponent observes this movement; the player's information is unchanged.
	e=fixture(true)
	for n in range(e.state.units.size()):
		if n not in [0,11]:e.state.units[n].strength=0;e.state.units[n].casualties=e.state.units[n].initial_strength
	put(e,0,219);put(e,11,225);e.refresh_intel()
	check(not e.visible_to(0,11) and e.visible_to(1,0),"asymmetric cavalry observation fixture")
	var ours=e.intel_signature(0);var theirs=e.intel_signature(1);var before=e.state.duplicate(true)
	check(e.move(0,[219,220])=="moved" and ours==e.intel_signature(0) and theirs!=e.intel_signature(1),"opponent alone updates its information")
	check(e.undo_status()=="ok" and e.undo() and e.state==before,"being observed does not disable undo or leak detection")
	# A real player discovery is irreversible, with its reason retained after reload.
	e=fixture(true)
	for n in range(e.state.units.size()):
		if n not in [0,4]:e.state.units[n].strength=0;e.state.units[n].casualties=e.state.units[n].initial_strength
	put(e,0,220);put(e,4,225);e.refresh_intel();check(not e.visible_to(0,4),"enemy initially hidden")
	check(e.move(0,[220,221])=="discovered" and not e.undo() and e.undo_status()=="discovery","new enemy information blocks undo")
	var store=Store.new("user://discovery0816.json","0816");var copy=fixture(true)
	check(store.save_game(e) and store.load_game(copy) and copy.undo_status()=="discovery","discovery reason survives reload")
	check(not e.observation(1).state.has("undo_reason"),"reason not exposed to opponent AI")
	for action in ["fire","assault","formation","entrench","deployment","rally","rest","turn","capture"]:
		e=fixture();put(e,0,220);put(e,4,221);e.state.units[0].formation="line"
		match action:
			"fire":check(e.fire(0,4).status=="ok","fire executes")
			"assault":check(e.assault(0,4).status=="ok","assault executes")
			"formation":check(e.change_formation(0,"column"),"formation executes")
			"entrench":check(e.entrench(0),"entrench executes")
			"deployment":check(e.toggle_deployment(8),"deployment executes")
			"rally":
				put(e,4,500);e.state.units[0].morale="shaken";e.state.units[0].cohesion=50
				check(e.rally(0),"rally executes")
			"rest":e.state.units[0].ammo_level=2;check(e.rest(0),"rest executes")
			"turn":e.end_side()
			"capture":
				e.pack.objective.cell=[10,8];e.state.owner=1
				check(e.move(0,[220,250])=="capture","capture executes")
		check(e.undo_status()==action and not e.undo(),"specific undo lock: "+action)
	var old=Rules.new(JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/legacy0815.json")))
	check(old.max_ap(10)==20 and not old.pack.rules.get("undo_player_discovery_only",false),"previous pack preserves its movement rules")
	var bad=e.state.duplicate(true);bad.undo_reason="invented";check(not e.validate(bad),"bad save reason rejected")
	var ai=AI.new();ai.profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
	for level in ["easy","medium","hard"]:
		for side in [0,1]:
			e=Rules.new(data);e.new_game(1-side,level);e.state.side=side;e.refresh_intel()
			var decision=ai.choose(e.observation(side))
			check(dispatch(e,decision) and e.validate(e.state),"legal AI action with 4 PA cavalry: "+level+str(side))
	print("REVISION 0816: ",checks-failures,"/",checks," passed");quit(1 if failures else 0)

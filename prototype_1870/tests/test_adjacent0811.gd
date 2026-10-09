extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const Store=preload("res://war_engine/platform/save_store.gd")
var failures=0
var checks=0
func check(ok: bool,message: String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL "+message)
func world():
	var p=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/prototype.json"));p.map.tiles.fill("plain")
	var e=Rules.new(p)
	for n in range(e.state.units.size()):e.state.units[n].cell=[0 if int(e.state.units[n].side)==0 else 29,n]
	e.state.contacts=[{},{}];e.state.revealed=[[],[]];e.refresh_intel();return e
func exact(e,n: int,side: int):return e.contact(n,side).has("exact_strength")
func _initialize():
	for side in [0,1]:
		var a=0 if side==0 else 4;var b=4 if side==0 else 0;var e=world();e.state.side=side
		e.state.units[a].cell=[10,8];e.state.units[b].cell=[10,10];e.refresh_intel()
		check(e.visible_to(side,b) and not exact(e,b,side),"distant sight remains estimate")
		var before=e.state.units[a].ap;var path=e.path_to(a,e.index(Vector2i(10,9)));var result=e.move(a,path)
		check(result=="discovered" and exact(e,b,side),"adjacent move discovers exact strength without combat")
		check(e.state.events.is_empty() and e.state.shots==0 and e.state.assaults==0,"no combat to identify")
		check(e.state.units[a].ap==before-e.path_cost(path,a),"only movement AP spent")
		check(not e.undo() and e.previous.is_empty(),"new exact information locks undo")
		check(exact(e,a,1-side),"reciprocal exact information")
		check(e.contact(b,side).exact_strength==1000 and e.contact(b,side).exact_power==10,"correct exact men and power")
		var ai_view=e.observation(1-side);var found=false
		for u in ai_view.state.units:
			if u.id==e.state.units[a].id:found=u.strength==e.state.units[a].strength
		check(found,"AI receives same exact information")
		# Distance increases but continuous observation retains and refreshes the number.
		e.state.units[a].cell=[10,8];e.state.units[b].strength-=73;e.state.units[b].casualties+=73;e.refresh_intel()
		check(exact(e,b,side) and e.contact(b,side).exact_strength==927,"exact information retained and updated while observed")
		var store=Store.new("user://adjacent0811_%d.json"%side,"adjacent0811");var copy=Rules.new(e.pack)
		check(store.save_game(e) and store.load_game(copy) and copy.state==e.state,"save/reload exact intelligence")
		e.state.units[a].cell=[0 if side==0 else 29,a];e.state.revealed[side].append(b);e.refresh_intel()
		check(not exact(e,b,side),"loss of observation erases exact info even with muzzle flash")
		e.state.revealed[side]=[];e.refresh_intel();check(not e.visible_to(side,b) and not exact(e,b,side),"hidden report has no exact strength")
		e.state.units[a].cell=[10,8];e.refresh_intel();check(e.visible_to(side,b) and not exact(e,b,side),"distant reacquisition stays estimate")
		e.state.units[a].cell=[10,9];e.refresh_intel();check(exact(e,b,side),"adjacent reacquisition reveals without fighting again")
		# Two PA rally even when both links are cut; coherence recovery still penalized.
		e.state.units[a].morale="shaken";e.state.units[a].cohesion=45;e.state.units[a].command_ok=false;e.state.units[a].supply_ok=false;e.state.units[a].ap=8;e.state.units[a].done=false
		e.state.units[b].cell=[29 if side==0 else 0,b];e.refresh_intel()
		check(e.rally_cost(a)==8 and e.rally(a) and e.state.units[a].ap==0,"isolated rally costs exactly 2 PA")
	for n in [0,8,10]:
		var e=world();e.state.units[n].cell=[10,9];e.state.units[4].cell=[10,10];e.pack.map.tiles[e.unit_cell(e.state.units[4])]="forest";e.refresh_intel()
		check(exact(e,4,0),"infantry artillery cavalry each identify adjacent enemy in forest")
	var legacy=Rules.new(JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/legacy0810.json")))
	legacy.state.units[0].cell=[10,9];legacy.state.units[4].cell=[10,10];legacy.state.contacts=[{},{}];legacy.refresh_intel();legacy.state.units[0].command_ok=false
	check(not exact(legacy,4,0) and legacy.rally_cost(0)==12,"legacy rules preserved")
	print("ADJACENCY 0811: %d/%d passed"%[checks-failures,checks]);quit(1 if failures else 0)

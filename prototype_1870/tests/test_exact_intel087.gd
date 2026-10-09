extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const Store=preload("res://war_engine/platform/save_store.gd")
var checks=0
var failures=0
func check(ok: bool,msg: String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL: "+msg)
func world(attacker: int=0,target: int=4):
	var p=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/legacy088.json"));p.map.tiles.fill("plain");var e=Rules.new(p)
	for n in range(e.state.units.size()):e.state.units[n].cell=[0 if int(e.state.units[n].side)==0 else 29,n]
	e.state.units[attacker].cell=[10,9];e.state.units[target].cell=[10,10];e.state.side=int(e.state.units[attacker].side);e.state.seed=123
	e.state.contacts=[{},{}];e.state.revealed=[[],[]];e.refresh_intel();return e
func exact(e,n: int,side: int) -> bool:return e.contact(n,side).has("exact_strength")
func ai_strength(e,side: int,id: String) -> int:
	for u in e.observation(side).state.units:
		if u.id==id:return int(u.strength)
	return -1
func _initialize():
	for side in [0,1]:
		var a=0 if side==0 else 4;var b=4 if side==0 else 0;var e=world(a,b)
		check(not exact(e,b,side),"adjacency alone does not reveal strength camp %d"%side)
		check(e.fire_status(a,b)=="ok" and not exact(e,b,side),"preview gives no exact information")
		var result=e.fire(a,b)
		check(result.status=="ok" and result.event.reaction,"adjacent exchange actually fires with return fire")
		check(exact(e,b,side) and int(e.contact(b,side).exact_strength)==int(e.state.units[b].strength),"actual surviving men, not pre-combat strength or estimate")
		check(int(e.contact(b,side).exact_power)==ceili(float(e.state.units[b].strength)/e.state.units[b].initial_strength*10),"counter uses same exact power formula as friendly units")
		check(exact(e,a,1-side) and ai_strength(e,1-side,e.state.units[a].id)==int(e.state.units[a].strength),"defender AI receives exact strength under same rule")
		var store=Store.new("user://exact087_%d.json"%side,"exact087");var copy=Rules.new(e.pack)
		check(store.save_game(e) and store.load_game(copy) and copy.state==e.state,"exact reports survive save and reload")
		var bad=e.state.duplicate(true);bad.contacts[side][str(b)].exact_power=99
		check(not e.validate(bad),"invalid exact power rejected")
		e.state.units[b].strength-=17;e.state.units[b].casualties+=17;e.refresh_intel()
		check(int(e.contact(b,side).exact_strength)==int(e.state.units[b].strength),"observed strength stays current")
		# Last observer leaves: muzzle-flash revelation must not preserve exact values.
		e.state.units[a].cell=[0 if side==0 else 29,a];e.refresh_intel()
		check(not exact(e,b,side),"exact strength erased as soon as visual contact ends")
		e.state.revealed=[[],[]];e.refresh_intel()
		check(not e.visible_to(side,b) and not exact(e,b,side),"stale report holds no exact strength")
		e.state.units[b].strength-=19;e.state.units[b].casualties+=19;e.refresh_intel()
		check(not exact(e,b,side) and ai_strength(e,side,e.state.units[b].id)==-1,"hidden losses and strength unavailable to observing camp AI")
		check(store.save_game(e) and store.load_game(copy) and not exact(copy,b,side),"lost strength remains absent after reload")
		e.state.units[a].cell=[10,9];e.refresh_intel()
		check(e.visible_to(side,b) and not exact(e,b,side),"reacquisition alone does not restore exact number")
		e.state.units[a].ap=16;e.state.units[a].done=false;e.fire(a,b)
		check(exact(e,b,side),"second close engagement unlocks actual strength again")
	var e=world();e.state.units[4].cell=[10,11];e.refresh_intel()
	check(e.fire(0,4).status=="ok" and not exact(e,4,0) and not exact(e,0,1),"distant fire never unlocks strength")
	for a in [0,10]:
		e=world(a);var result=e.assault(a,4)
		check(result.status=="ok" and exact(e,4,0) and exact(e,a,1),"assault/charge reveals both strengths")
	# Save from v086 has no optional exact fields and retains its existing fingerprint.
	e=world();var raw=JSON.parse_string(JSON.stringify(e.state))
	check(e.validate(raw),"existing 086 save schema remains accepted")
	e.state=raw;e.normalize();check(not exact(e,4,0),"legacy report does not manufacture an old close engagement")
	print("EXACT INTEL 087: %d / %d passed"%[checks-failures,checks]);quit(1 if failures else 0)

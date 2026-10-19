extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
var checks=0
var failures=0
func check(ok: bool,msg: String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL: "+msg)
func _initialize():
	var p=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/prototype.json"));p.map.tiles.fill("plain");var e=Rules.new(p)
	for n in range(e.state.units.size()):e.state.units[n].cell=[0 if int(e.state.units[n].side)==0 else 29,n]
	e.state.units[8].cell=[10,3];e.state.units[8].deployed=true;e.state.units[4].cell=[10,9];e.state.units[5].cell=[10,8]
	# Target is known from a previous muzzle flash; an intervening enemy is not.
	e.state.revealed=[ [4], [] ];e.state.contacts=[{},{}];e.refresh_intel()
	check(e.visible_to(0,4) and not e.visible_to(0,5),"target revealed, intervening unit hidden")
	check(e.fire_status(8,4)=="ok","aim preview cannot reveal hidden blocker")
	var old=e.state.units[4].strength;var shot=e.fire(8,4)
	check(shot.status=="ok" and shot.event.target==5 and shot.event.get("intercepted",false),"hidden nearer unit intercepts actual shot")
	check(e.state.units[8].ap==4 and e.state.units[4].strength==old and e.state.units[5].casualties>0,"normal shot AP paid, damage goes to interceptor")
	check(e.visible_to(0,5) and not e.undo() and e.validate(e.state),"interceptor revealed only by irreversible shot")
	var old_report=e.contact(5,0).duplicate(true);e.state.side=1
	var moved=e.move(5,[e.unit_cell(e.state.units[5]),e.index(Vector2i(11,8))])
	check(moved in ["moved","discovered"] and not e.visible_to(0,5) and e.contact(5,0)==old_report,"fired unit moving outside view leaves frozen report, never live tracking")
	e.reveal_combatants(8,4);var old_cell=e.contact(4,0).cell.duplicate();e.state.units[4].morale="routed";e.retreat(4);e.refresh_intel()
	check(not e.visible_to(0,4) and e.contact(4,0).cell==old_cell,"forced retreat does not reveal hidden destination")
	print("HIDDEN FIRE 086: %d / %d passed"%[checks-failures,checks]);quit(1 if failures else 0)

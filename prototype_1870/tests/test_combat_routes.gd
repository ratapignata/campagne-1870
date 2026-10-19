extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const Store=preload("res://war_engine/platform/save_store.gd")
var checks=0
var failures=0
func check(ok: bool,name: String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL: "+name)
func scenario(pack):
	var e=Rules.new(pack);e.state.units[0].cell=[3,3];e.state.units[4].cell=[5,3];e.state.seed=123
	return e
func _initialize():
	var data=JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/prototype08.json"));var e=Rules.new(data)
	var preview=e.preview(0,e.index(Vector2i(23,5)))
	check(preview.full.size()>preview.route.size() and preview.route.size()>1,"long route exposes reachable portion")
	check(preview.cost<=e.state.units[0].ap,"partial route respects budget")
	check(preview.limit==preview.route[-1],"limit is reachable endpoint")
	var before=e.state.duplicate(true)
	check(e.state==before and e.state.moves==0,"preview has no mutation")
	check(e.move(0,preview.route)=="moved","reachable portion can execute")
	check(e.undo() and e.state==before,"partial move reversible")
	check(e.preview(0,e.index(Vector2i(14,7))).full.is_empty(),"water destination invalid")
	e.state.units[0].ap=1
	check(e.preview(0,e.index(Vector2i(23,5))).route.is_empty(),"insufficient fractional AP cannot move")
	# Isolated flat test map gives independently controlled combat geometry.
	var pack=data.duplicate(true);pack.map.tiles.fill("plain")
	e=scenario(pack)
	check(e.fire_status(0,4)=="ok","enemy in clear range can be targeted")
	check(e.fire_status(0,1)=="friendly","friendly fire rejected")
	check(e.fire_status(4,0)=="invalid","opponent cannot act during player turn")
	before=e.state.duplicate(true)
	check(e.fire(0,1).status=="friendly" and e.state==before,"invalid attack is atomic")
	var result=e.fire(0,4)
	check(result.status=="ok" and result.event.loss>0,"shot inflicts losses")
	check(e.state.units[0].ap==8,"shot costs 2 AP")
	check(e.state.units[4].strength==1000-result.event.loss,"losses deducted exactly")
	check(e.state.shots==1 and e.state.events.size()==1,"result logged once")
	check(not e.undo(),"shot cannot be undone")
	check(e.fire_status(0,4)=="ok","second shot allowed if AP remain")
	e.fire(0,4)
	check(not e.can_act(0) and e.state.units[0].ap==0,"two shots exhaust AP")
	e=scenario(pack);e.state.units[0].ap=7
	check(e.fire_status(0,4)=="no_ap","shot cannot overspend")
	e=scenario(pack);e.state.units[4].cell=[8,3]
	check(e.fire_status(0,4)=="range","far target rejected")
	e=scenario(pack);e.pack.map.tiles[e.index(Vector2i(4,3))]="forest"
	check(e.fire_status(0,4)=="blocked_cover","intermediate forest blocks shot")
	check(not e.line_clear(e.unit_cell(e.state.units[4]),e.unit_cell(e.state.units[0])),"occlusion symmetric")
	e=scenario(pack);e.state.units[1].cell=[4,3]
	check(e.fire_status(0,4)=="blocked_friendly","intermediate unit blocks shot")
	e=scenario(pack);var open_loss=e.fire(0,4).event.loss
	e=scenario(pack);e.pack.map.tiles[e.unit_cell(e.state.units[4])]="village"
	check(e.fire_status(0,4)=="ok","target inside cover can be attacked")
	check(e.fire(0,4).event.loss<open_loss,"village reduces losses at same random seed")
	e=scenario(pack);e.state.units[0].strength=500
	check(e.fire(0,4).event.loss<open_loss,"casualties reduce shooting strength")
	e=scenario(pack);e.state.units[4].strength=1
	result=e.fire(0,4)
	check(result.event.loss==1 and result.event.eliminated,"losses capped at remaining men")
	check(e.unit_at(e.index(Vector2i(5,3)))==-1 and not e.alive(4),"eliminated counter removed")
	e.end_side()
	check(not e.can_act(4) and e.state.units[4].ap==0,"eliminated unit stays unavailable next turn")
	e=scenario(pack);e.fire(0,4)
	var store=Store.new("user://combat_test_save.json","combat-pack")
	check(store.save_game(e),"combat state saved")
	var restored=scenario(pack)
	check(store.load_game(restored) and restored.state==e.state,"combat state and journal restored exactly")
	check(e.fire(0,4).event.loss==restored.fire(0,4).event.loss,"reload cannot reroll next shot")
	var bad=e.state.duplicate(true);bad.units[0].strength=-1
	check(not e.validate(bad),"negative strength rejected")
	bad=e.state.duplicate(true);bad.events[0].target=100
	check(not e.validate(bad),"invalid journal index rejected")
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute("user://combat_test_save.json"+suffix)
	print("ROUTE/COMBAT CHECKS: %d passed / %d total"%[checks-failures,checks]);quit(1 if failures else 0)

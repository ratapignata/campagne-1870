extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const Store=preload("res://war_engine/platform/save_store.gd")
var checks=0
var failures=0
func check(ok: bool,name: String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL: "+name)
func fixture(data):
	var p=data.duplicate(true);p.map.tiles.fill("plain")
	var e=Rules.new(p)
	for n in range(e.state.units.size()):e.state.units[n].cell=[n*2,18]
	e.state.seed=123
	return e
func _initialize():
	var data=JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/prototype08.json"))
	var e=fixture(data)
	e.state.units[0].cell=[4,4];e.state.units[4].cell=[4,7]
	check(e.fire_status(0,4)=="ok","Chassepot can fire at three hexes")
	e.end_side()
	check(e.fire_status(4,0)=="range","Dreyse cannot answer at three hexes")
	e.state.units[4].cell=[4,6]
	check(e.fire_status(4,0)=="ok","Dreyse effective at two hexes")
	# Weapon characteristics, not faction bonuses.
	e=fixture(data);e.state.units[0].cell=[4,4];e.state.units[4].cell=[4,7]
	e.state.units[0].weapon="dreyse"
	check(e.fire_status(0,4)=="range","French unit with Dreyse uses Dreyse range")
	e.state.units[4].weapon="chassepot";e.end_side()
	check(e.fire_status(4,0)=="ok","German unit with Chassepot uses Chassepot range")
	e=fixture(data);e.state.units[8].cell=[4,4];e.state.units[4].cell=[4,10]
	check(e.artillery(8) and e.artillery(9) and not e.artillery(0),"battery type derives from weapon")
	var before=e.state.duplicate(true)
	check(e.fire(8,4).status=="limbered" and e.state==before,"limbered battery cannot fire or spend AP")
	check(e.toggle_deployment(8),"deploy French battery")
	check(e.state.units[8].ap==12 and e.state.units[8].deployed,"deployment costs one PA")
	check(e.reach(8).costs.is_empty(),"deployed battery has no reachable hexes")
	var start=e.unit_cell(e.state.units[8]);before=e.state.duplicate(true)
	check(e.move(8,[start,e.neighbours(start)[0]])=="deployed" and e.state==before,"direct movement of deployed battery rejected atomically")
	check(e.fire_status(8,4)=="ok","French cannon can reach six hexes")
	var french_loss=e.fire(8,4).event.loss
	check(e.state.units[8].ap==0 and not e.can_act(8),"French deploy plus shot consumes four PA")
	check(not e.toggle_deployment(8),"spent unit cannot limber")
	e.end_side();e.end_side()
	check(e.state.units[8].deployed and e.state.units[8].ap==16,"deployment persists after new turn")
	check(e.toggle_deployment(8) and e.state.units[8].ap==12,"limber costs one PA")
	check(not e.state.units[8].deployed and not e.reach(8).costs.is_empty(),"limbered battery can move")
	var path=e.path_to(8,e.index(Vector2i(5,4)))
	check(e.move(8,path)=="moved" and e.undo(),"battery movement undo works")
	e.state.units[8].ap=3;before=e.state.duplicate(true)
	check(not e.toggle_deployment(8) and e.state==before,"deployment cannot overspend")
	check(not e.toggle_deployment(0),"infantry cannot deploy")
	e=fixture(data);e.state.side=1;e.state.units[9].cell=[4,4];e.state.units[0].cell=[4,10]
	check(e.toggle_deployment(9),"deploy Krupp")
	var krupp_loss=e.fire(9,0).event.loss
	check(krupp_loss>french_loss,"Krupp better long range effect at identical seed and strength")
	check(e.state.units[9].ap==4,"Krupp fire costs two PA")
	check(e.fire_status(9,0)=="no_ap","remaining one PA insufficient for Krupp shot")
	e.end_side();e.end_side()
	check(e.fire(9,0).status=="ok" and e.fire(9,0).status=="ok" and e.state.units[9].ap==0,"Krupp can shoot twice when already deployed")
	e=fixture(data);e.state.side=1;e.state.units[9].cell=[4,4];e.state.units[0].cell=[4,11];e.toggle_deployment(9)
	check(e.fire_status(9,0)=="range","Krupp maximum six hexes")
	e.state.units[0].cell=[4,10];e.pack.map.tiles[e.index(Vector2i(4,7))]="forest"
	check(e.fire_status(9,0)=="blocked_cover","artillery does not shoot through forest")
	e.pack.map.tiles[e.index(Vector2i(4,7))]="plain";e.state.units[5].cell=[4,7]
	check(e.fire_status(9,0)=="blocked_friendly","level artillery does not shoot over friendly units")
	e=fixture(data);e.toggle_deployment(8)
	var store=Store.new("user://weapons_test.json","weapons-v021")
	check(store.save_game(e),"battery save written")
	var restored=fixture(data)
	check(store.load_game(restored) and restored.state==e.state and restored.state.units[8].deployed,"battery posture and AP restored exactly")
	var invalid=e.state.duplicate(true);invalid.units[0].deployed=true
	check(not e.validate(invalid),"forged infantry deployment save rejected")
	invalid=e.state.duplicate(true);invalid.units[8].erase("deployed")
	check(not e.validate(invalid),"missing battery state rejected")
	invalid=e.state.duplicate(true);invalid.units[8].deployed="yes"
	check(not e.validate(invalid),"invalid battery state type rejected")
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute("user://weapons_test.json"+suffix)
	print("WEAPON CHECKS: %d passed / %d total"%[checks-failures,checks]);quit(1 if failures else 0)

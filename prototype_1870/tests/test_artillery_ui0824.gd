extends SceneTree
var checks=0
var failures=0
func check(ok: bool,label: String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL "+label)
func _initialize():call_deferred("run")
func run():
	root.size=Vector2i(1280,720)
	var game=load("res://main.tscn").instantiate();root.add_child(game);game.ai_enabled=false;game.music_player.stop();game.sound_enabled=false
	await process_frame
	game.new_game(0);game.ai_enabled=false
	var e=game.engine;e.pack.map.tiles.fill("plain");e.pack.map.elevations.fill(0);e.pack.rules.fog.enabled=false
	for n in range(e.state.units.size()):e.state.units[n].cell=[n*2,18]
	e.state.units[8].cell=[10,3];e.state.units[8].deployed=true;e.state.units[4].cell=[10,7]
	game.on_cell(e.unit_cell(e.state.units[8]));check(not game.map.fire_cells.is_empty(),"select ready cannon lights cells")
	check(game.map.fire_target_lit(4) and not game.map.fire_target_lit(8),"enemy lights, friendly does not")
	e.state.units[0].cell=[10,5];game.refresh();check(not game.map.fire_target_lit(4),"blocked enemy does not light")
	e.state.units[0].cell=[0,18];game.refresh()
	var target=e.unit_cell(e.state.units[4]);var strength=e.state.units[4].strength
	game.on_cell(target);check(e.state.units[4].strength==strength and game.target==4,"first target tap only previews")
	game.on_cell(target);check(e.state.units[4].strength<strength and game.map.fire_cells.is_empty(),"second tap fires and remaining AP clears overlay")
	game.map.combat_ttl=0;e.state.units[8].ap=16;e.state.units[8].done=false;game.refresh()
	check(not game.map.fire_cells.is_empty(),"refresh restores legal cells")
	game.on_cell(e.unit_cell(e.state.units[8]));check(game.map.fire_cells.is_empty(),"deselect clears overlay")
	game.on_cell(e.unit_cell(e.state.units[0]));check(game.map.fire_cells.is_empty(),"infantry unchanged")
	game.playing=false;game.queue_free();await process_frame
	print("ARTILLERY UI 0824 ",checks-failures,"/",checks);quit(1 if failures else 0)

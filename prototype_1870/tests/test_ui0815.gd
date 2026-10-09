extends "res://tests/test_ui0813.gd"
func run():
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute("user://save_v0815.json"+suffix)
	var old_raw=FileAccess.get_file_as_string("res://packs/1870/legacy0814.json")
	var old=Rules.new(JSON.parse_string(old_raw));old.state.units[0].ap=7
	var old_store=Store.new("user://save_v0814.json",old_raw.sha256_text())
	check(old_store.save_game(old),"write genuine v0814 save")
	game=load("res://main.tscn").instantiate();root.add_child(game);game.ai_enabled=false;game.music_enabled=false;game.music_player.stop();game.sound_enabled=false
	await process_frame
	check(game.has_save and game.legacy_game and game.engine.state.units[0].ap==7,"resume v0814 without changing PA or rules")
	await screenshot("1870_v0815_menu")
	game.new_game(0);game.ai_enabled=false
	await process_frame
	check(game.engine.validate(game.engine.state) and game.saver.path=="user://save_v0815.json","new battle uses corrected pack and independent save")
	var matched=true
	for i in range(600):matched=matched and game.map.pick(game.map.screen(i))==i
	check(matched,"all 600 cells selectable with north on left")
	await tap_cell(game.engine.unit_cell(game.engine.state.units[0]));check(game.selected==0,"tap selects French unit")
	check_layout("initial Sauer unit");await screenshot("1870_v0815_apercu")
	await tap_cell(game.engine.unit_cell(game.engine.state.units[0]));check(game.selected==-1,"second tap deselects")
	game.engine.pack.rules.fog.enabled=false;game.engine.pack.map.tiles.fill("plain");game.engine.pack.map.elevations.fill(0)
	for n in range(game.engine.state.units.size()):game.engine.state.units[n].cell=[n*2,1]
	game.engine.state.units[0].cell=[19,11];game.engine.refresh_intel();game.map.focus=game.map.world(349);game.refresh();await process_frame
	await tap_cell(349);await tap_cell(379)
	check(game.route==[349,379] and game.context_detail.text.contains("+2 PA"),"tap destination previews ford and cost")
	check_layout("ford preview");await screenshot("1870_v0815_traversee")
	await tap_cell(379);check(game.engine.unit_cell(game.engine.state.units[0])==379 and game.engine.state.units[0].river_halt,"second destination tap crosses and stops movement")
	check_layout("after crossing")
	await tap_cell(409);check(game.engine.unit_cell(game.engine.state.units[0])==379,"touch cannot bypass halt")
	check(game.saver.load_game(game.engine) and game.engine.state.units[0].river_halt,"UI save restores crossing state")
	check(game.actions.undo.visible and not game.actions.undo.disabled,"undo visible after reversible crossing")
	await tap(game.actions.undo.get_global_rect().get_center())
	check(game.engine.unit_cell(game.engine.state.units[0])==349 and game.engine.state.units[0].ap==16 and not game.engine.state.units[0].river_halt,"undo restores cell PA and crossing permission")
	game.engine.state.units[4].cell=[19,12];game.engine.refresh_intel()
	check(game.engine.fire(0,4).status=="ok","actual fire locks undo")
	game.refresh();await process_frame
	check(game.actions.undo.visible and game.actions.undo.disabled,"undo visible but disabled after combat")
	await tap(game.actions.undo.get_global_rect().get_center())
	check(game.context_detail.text.contains("Aucun mouvement annulable"),"disabled undo explains reason")
	check_layout("disabled undo");await screenshot("1870_v0815_annulation")
	game.engine.state.units[0].ammo_level=2;game.engine.state.units[0].attacked=false;game.engine.state.units[0].supply_ok=true;game.refresh();await process_frame
	check(game.actions.rest.visible and game.actions.undo.visible and not game.actions.rest.get_global_rect().intersects(game.actions.undo.get_global_rect()),"rest and undo separate")
	check_layout("rest and disabled undo")
	game.new_game(1);game.ai_enabled=false;game.engine.state.side=1;game.engine.refresh_intel();game.map.focus=game.map.world(442);game.refresh();await process_frame
	await tap_cell(game.engine.unit_cell(game.engine.state.units[4]));check(game.selected==4,"Prussian camp selectable")
	check_layout("Prussian unit");await screenshot("1870_v0815_prusse")
	game.show_help(1);await process_frame;await screenshot("1870_v0815_aide")
	game.close_modal();game.new_game(0);game.ai_enabled=false
	game.queue_free();await process_frame
	print("UI 0815: ",checks-failures,"/",checks," passed");quit(1 if failures else 0)

extends "res://tests/test_formation_button_ui.gd"
const Rules089=preload("res://war_engine/core/engine.gd")
const Store089=preload("res://war_engine/platform/save_store.gd")
func run():
	for suffix in ["",".bak",".tmp"]:
		DirAccess.remove_absolute("user://save_v089.json"+suffix);DirAccess.remove_absolute("user://save_v086.json"+suffix)
	var raw=FileAccess.get_file_as_string("res://packs/1870/legacy088.json");var old=Rules089.new(JSON.parse_string(raw));old.state.units[0].ap=9
	var store=Store089.new("user://save_v086.json",raw.sha256_text());store.save_game(old)
	game=load("res://main.tscn").instantiate();root.add_child(game);game.ai_enabled=false
	await process_frame
	check(game.has_save and game.legacy_game and not game.engine.support_enabled() and game.engine.state.units[0].ap==9,"continue preserves 088 battle")
	game.new_game(0);game.ai_enabled=false
	check(game.engine.support_enabled() and game.saver.path=="user://save_v089.json","new battle enables support in separate save")
	game.selected=0;game.refresh();await process_frame
	check(game.unit_card.size==game.action_card.size and game.unit_card.size.x>=486,"matching enlarged panels")
	check(not game.unit_card.get_global_rect().intersects(game.action_card.get_global_rect()),"panels do not overlap")
	check(game.ammo_label.text.contains("Abondantes") and game.support_label.text.contains("assuré"),"own ammunition and links readable")
	check(not game.formation_button.get_global_rect().intersects(game.actions.entrench.get_global_rect()),"formation remains separate from entrench")
	await screenshot("1870_v089_fiche")
	game.engine.state.units[0].ammo_level=2;game.refresh();await process_frame
	check(game.actions.rest.visible,"rest button available for low reserves")
	await press("rest");check(game.engine.state.units[0].done and game.engine.state.units[0].ammo_level==2,"touch rest ends orders without free ammunition")
	game.engine.state.units[0].morale="shaken";game.engine.state.units[0].command_ok=false;game.engine.state.units[0].supply_ok=false;game.engine.state.units[0].encircled=true;game.engine.state.units[0].done=false;game.refresh();await process_frame
	check(game.actions.rally.text.contains("3") and game.context_detail.text.contains("3 PA") and game.support_label.text.contains("coupé"),"isolated rally cost and links displayed")
	await screenshot("1870_v089_isolee")
	game.engine.state.units[4].cell=[12,7];game.engine.refresh_intel();game.selected=-1;game.target=-1;game.on_cell(game.engine.unit_cell(game.engine.state.units[4]));await process_frame
	check(game.ammo_label.text.is_empty() and game.support_label.text.is_empty(),"enemy logistics remain hidden")
	game.persist();var restarted=load("res://main.tscn").instantiate();root.add_child(restarted);restarted.ai_enabled=false
	check(restarted.has_save and restarted.engine.state==game.engine.state,"restart restores support fields exactly")
	for app in [restarted,game]:
		app.playing=false;app.set_process(false)
		for player in [app.music_player,app.sound_player,app.reaction_player,app.assault_player]:player.stop();player.stream=null
		app.queue_free();await process_frame
	await process_frame;game=null
	print("SUPPORT UI 089: %d/%d passed"%[checks-failures,checks]);quit(1 if failures else 0)

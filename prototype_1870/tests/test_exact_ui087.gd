extends "res://tests/test_fog_ui086.gd"
func run():
	game=load("res://main.tscn").instantiate();game.prefs_path="user://exact_ui087.cfg";root.add_child(game);game.ai_enabled=false
	await process_frame;game.new_game();await setup_world()
	var e=game.engine;e.state.units[4].cell=[10,10];e.refresh_intel();game.refresh()
	var enemy=e.unit_cell(e.state.units[4]);var own=e.unit_cell(e.state.units[0])
	await tap_cell(enemy)
	check(game.map.contact_power_text(4)=="?" and game.unit_info.text.begins_with("Est."),"before combat counter unknown, sheet retains reconnaissance estimate")
	await tap_cell(enemy);await tap_cell(own);await tap_cell(enemy)
	check(e.state.events.is_empty() and game.map.contact_power_text(4)=="?","first target tap does not reveal strength")
	await tap_cell(enemy);await create_timer(1.4).timeout
	check(e.state.events.size()==1 and e.state.events[0].reaction,"second target tap resolves exchange and riposte")
	await tap_cell(own);await tap_cell(enemy)
	check(game.selected==4 and game.unit_info.text==game.t("fog_exact")%int(e.state.units[4].strength),"enemy sheet displays actual survivors")
	check(game.map.contact_power_text(4)==str(ceili(float(e.state.units[4].strength)/e.state.units[4].initial_strength*10)),"counter displays actual power")
	check(not game.unit_info.text.contains("Est.") and game.unit_ap.text.is_empty(),"no estimate after close combat, PA still hidden")
	await screenshot("1870_v087_effectif_exact")
	e.state.units[0].cell=[0,0];e.state.units[4].cell=[20,10];e.state.revealed=[[],[]];e.refresh_intel();game.refresh()
	await tap_cell(enemy)
	check(game.selected==-1 and game.inspected_report==4,"lost enemy only opens stale report")
	check(game.map.contact_power_text(4).is_empty(),"lost counter displays no number")
	check(game.unit_info.text==game.t("fog_strength_hidden"),"stale sheet displays no cached number or estimate")
	await screenshot("1870_v087_contact_perdu")
	e.state.units[0].cell=[10,9];e.state.units[4].cell=[10,10];e.refresh_intel();game.refresh();await tap_cell(enemy)
	check(game.map.contact_power_text(4)=="?" and game.unit_info.text.begins_with("Est."),"observing again requires a new close exchange for exact information")
	game.playing=false;game.set_process(false)
	for player in [game.music_player,game.sound_player,game.reaction_player,game.assault_player]:player.stop();player.stream=null
	await create_timer(0.3).timeout;game.queue_free();await process_frame;await process_frame;game=null
	print("EXACT UI 087: %d / %d passed"%[checks-failures,checks]);quit(1 if failures else 0)

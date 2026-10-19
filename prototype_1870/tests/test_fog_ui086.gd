extends "res://tests/test_formation_button_ui.gd"
const Rules086=preload("res://war_engine/core/engine.gd")
const Store086=preload("res://war_engine/platform/save_store.gd")
func setup_world():
	game.close_modal();game.engine.new_game();game.engine.pack.map.tiles.fill("plain")
	for n in range(game.engine.state.units.size()):game.engine.state.units[n].cell=[0 if int(game.engine.state.units[n].side)==0 else 29,n]
	game.engine.state.units[0].cell=[10,9];game.engine.state.units[4].cell=[10,14];game.engine.state.contacts=[{},{}];game.engine.state.revealed=[[],[]];game.engine.refresh_intel()
	game.selected=-1;game.clear_preview();game.map.combat_ttl=0;game.map.feedback_ttl=0;game.map.zoom=1.0;game.map.focus=game.map.world(game.engine.index(Vector2i(10,10)));game.refresh();await process_frame
func run():
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute("user://save_v086.json"+suffix)
	var raw=FileAccess.get_file_as_string("res://packs/1870/legacy085.json");var old=Rules086.new(JSON.parse_string(raw));old.state.units[10].ap=9
	var old_store=Store086.new("user://save_v085.json",raw.sha256_text());old_store.save_game(old)
	game=load("res://main.tscn").instantiate();game.prefs_path="user://fog_ui086.cfg";root.add_child(game);game.ai_enabled=false
	await process_frame
	check(game.has_save and game.legacy_game and not game.engine.fog_enabled() and game.engine.state.units[10].ap==9,"old cavalry battle keeps progress and full visibility")
	check(game.engine.assault_cost(10)==8,"legacy cavalry also charges for two PA")
	await press("continue");game.new_game()
	check(game.engine.fog_enabled() and not game.legacy_game and game.engine.assault_cost(10)==8,"new game enables fog and charge two PA")
	var restart=load("res://main.tscn").instantiate();restart.prefs_path="user://fog_ui086.cfg";root.add_child(restart);restart.ai_enabled=false
	check(restart.has_save and restart.engine.fog_enabled() and restart.engine.state==game.engine.state,"restart resumes new fog save")
	for player in [restart.music_player,restart.sound_player,restart.reaction_player,restart.assault_player]:player.stop();player.stream=null
	await create_timer(0.3).timeout;restart.queue_free();await process_frame
	await create_timer(0.15).timeout;await screenshot("1870_v086_carte")
	await setup_world()
	var hidden=game.engine.unit_cell(game.engine.state.units[4]);await tap_cell(hidden)
	check(game.selected==-1 and game.target==-1 and game.unit_label.text==game.t("terrain_plain"),"touch hidden enemy cell only inspects known terrain")
	check(game.weapon_label.text.contains(game.t("fog_unknown")),"terrain sheet explains unobserved sector")
	game.engine.state.units[10].cell=[10,8];game.engine.refresh_intel();game.refresh()
	await tap_cell(hidden)
	check(game.selected==4 and game.unit_label.text==game.t("fog_infantry"),"spotted enemy shows type rather than unit identity")
	check(game.unit_info.text.begins_with("Est.") and game.unit_ap.text.is_empty() and not game.ap_segments[0].get_parent().visible,"enemy sheet hides exact strength and PA")
	check(not game.formation_label.visible and game.unit_state.text==game.t("fog_no_state"),"spotted enemy hides morale and formation")
	game.map.focus=game.map.world(game.engine.index(Vector2i(10,12)));game.map.queue_redraw()
	await create_timer(0.15).timeout;await screenshot("1870_v086_repere")
	game.engine.state.units[10].cell=[10,12];game.engine.refresh_intel();game.refresh()
	check(game.unit_label.text==game.t("unit_1_0_short") and game.weapon_label.text==game.t("fog_identified"),"near cavalry identifies enemy")
	check(game.unit_ap.text.is_empty() and game.unit_reaction.text==game.t("fog_no_ap_info"),"identified enemy still has no exact AP or reaction budget")
	await create_timer(0.15).timeout;await screenshot("1870_v086_identifie")
	var record=game.engine.contact(4,0).duplicate(true);game.engine.state.units[0].cell=[0,0];game.engine.state.units[10].cell=[0,10];game.engine.state.units[4].cell=[20,14];game.engine.refresh_intel();game.refresh()
	check(game.selected==-1 and game.engine.contact(4,0)==record,"lost contact does not track hidden true position")
	await tap_cell(hidden)
	check(game.inspected_report==4 and game.selected==-1 and game.unit_state.text.contains("Dernier signalement"),"old marker opens dated report without selectable enemy")
	check(not game.actions.assault.visible,"stale report cannot be charged")
	await create_timer(0.15).timeout;await screenshot("1870_v086_signalement")
	await setup_world();game.engine.state.units[10].cell=[10,13];game.engine.state.units[4].strength=450;game.engine.state.units[4].casualties=550;game.engine.state.units[4].morale="shaken";game.engine.state.units[4].cohesion=55;game.engine.refresh_intel();game.refresh()
	await tap_cell(game.engine.unit_cell(game.engine.state.units[10]));await tap_cell(game.engine.unit_cell(game.engine.state.units[4]))
	check(game.actions.assault.text=="Charger · 2 PA" and game.context_detail.text.contains("2 PA"),"button and confirmation both show charge two PA")
	check(game.engine.state.events.is_empty(),"first enemy tap does not charge")
	await tap_cell(game.engine.unit_cell(game.engine.state.units[4]));check(game.engine.state.events.size()==1 and game.engine.state.units[10].ap==8,"second tap charges once for exactly two PA")
	check(game.map.combat_feedback.contains("estimées") and not game.map.combat_feedback.contains("Pertes françaises"),"combat report separates own losses from enemy estimate")
	await create_timer(1.4).timeout
	game.show_journal();await create_timer(0.15).timeout;await screenshot("1870_v086_journal");game.close_modal()
	game.show_help(0);await create_timer(0.15).timeout;await screenshot("1870_v086_aide");game.close_modal()
	# Enemy-side play uses the same visibility rules and charges.
	game.engine.new_game(1);game.engine.state.side=1;game.engine.refresh_intel();game.selected=11;game.clear_preview();game.map.zoom=1.0;game.map.focus=game.map.world(game.engine.unit_cell(game.engine.state.units[11]));game.refresh()
	check(game.unit_label.text==game.t("cavalry_1_short") and game.unit_ap.text.contains("4"),"Prussian player retains full own-unit information")
	await create_timer(0.15).timeout;await screenshot("1870_v086_prusse")
	game.playing=false;game.set_process(false)
	for player in [game.music_player,game.sound_player,game.reaction_player,game.assault_player]:player.stop();player.stream=null
	await create_timer(0.3).timeout;game.queue_free();await process_frame;await process_frame;game=null
	print("FOG UI 086: %d / %d passed"%[checks-failures,checks]);quit(1 if failures else 0)

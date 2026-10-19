extends "res://tests/test_formation_button_ui.gd"
const Rules085=preload("res://war_engine/core/engine.gd")
const Store085=preload("res://war_engine/platform/save_store.gd")
func arrange_charge(side: int=0):
	game.engine.new_game(side);game.engine.state.side=side;game.engine.pack.map.tiles.fill("plain")
	for n in range(game.engine.state.units.size()):game.engine.state.units[n].cell=[n*2,18]
	var cav=10+side;var foe=4 if side==0 else 0
	game.engine.state.units[cav].cell=[12,9];game.engine.state.units[foe].cell=[12,10]
	game.engine.state.units[foe].strength=450;game.engine.state.units[foe].casualties=550;game.engine.state.units[foe].morale="shaken";game.engine.state.units[foe].cohesion=55
	game.selected=-1;game.clear_preview();game.map.combat_ttl=0;game.map.feedback_ttl=0;game.map.zoom=1.3;game.map.focus=game.map.world(game.engine.index(Vector2i(12,9)));game.refresh()
	await process_frame
func run():
	# Real startup loads the previous release's exact saved scenario, with no added unit.
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute("user://save_v085.json"+suffix)
	var old_raw=FileAccess.get_file_as_string("res://packs/1870/legacy084.json")
	var old=Rules085.new(JSON.parse_string(old_raw));old.new_game(1);old.state.side=1;old.state.units[4].ap=11;old.state.units[4].formation="skirmish"
	var old_store=Store085.new("user://save_v081.json",old_raw.sha256_text());old_store.save_game(old)
	game=load("res://main.tscn").instantiate();game.prefs_path="user://cavalry_ui085.cfg";root.add_child(game);game.ai_enabled=false
	await process_frame
	check(game.has_save and game.legacy_game and game.engine.state==old.state,"startup resumes previous scenario with original AP, formation and ten units")
	await press("continue");check(game.playing and game.engine.state.units.size()==10,"Continue retains old battle")
	game.new_game(0)
	check(not game.legacy_game and game.engine.state.units.size()==12 and game.map.engine==game.engine,"new battle switches to cavalry scenario and renderer")
	var saved_copy=Rules085.new(game.engine.pack)
	check(game.saver.load_game(saved_copy) and saved_copy.state==game.engine.state,"new scenario autosave reloads")
	var restart=load("res://main.tscn").instantiate();restart.prefs_path="user://cavalry_ui085.cfg";root.add_child(restart);restart.ai_enabled=false
	check(restart.has_save and not restart.legacy_game and restart.engine.state==game.engine.state,"app restart prefers valid cavalry save over legacy save")
	for player in [restart.music_player,restart.sound_player,restart.reaction_player,restart.assault_player]:player.stop();player.stream=null
	await create_timer(0.3).timeout;restart.queue_free();await process_frame;restart=null
	game.show_menu();await press("continue");check(game.playing and not is_instance_valid(game.modal),"new cavalry scenario can continue from menu")
	await arrange_charge()
	await tap_cell(game.engine.unit_cell(game.engine.state.units[10]))
	check(game.selected==10 and game.unit_label.text==game.t("cavalry_0_short"),"cavalry selected with correct sheet")
	check(not game.formation_button.visible and not game.actions.entrench.visible and not game.actions.deploy.visible,"mounted sheet has no inapplicable commands")
	check(game.weapon_label.text.contains("Charge") and not game.weapon_label.text.contains("0 hex"),"cavalry sheet shows contact instead of firing range")
	await screenshot("1870_v085_cavalier")
	await tap_cell(game.engine.unit_cell(game.engine.state.units[10]));check(game.selected==-1,"second cavalry tap deselects")
	await tap_cell(game.engine.unit_cell(game.engine.state.units[10]));var dest=game.engine.index(Vector2i(11,9))
	await tap_cell(dest);check(game.engine.state.moves==0 and game.context_label.text.contains("0,5"),"cavalry path preview uses mounted cost")
	await tap_cell(dest);check(game.engine.state.moves==1 and game.engine.state.units[10].ap==14,"second destination tap moves cavalry once")
	await press("undo");check(game.engine.state.units[10].ap==16 and game.engine.state.moves==0,"cavalry undo restores PA")
	await tap_cell(game.engine.unit_cell(game.engine.state.units[4]))
	check(game.target==4 and game.engine.state.events.is_empty() and game.actions.assault.visible and game.actions.assault.text==game.t("charge"),"first enemy tap previews charge without combat")
	check(game.context_detail.text==game.t("charge_confirm"),"charge confirmation instruction visible")
	check(game.terrain_label.visible and game.terrain_label.text==game.t("terrain_short_plain"),"target terrain retained on first line")
	await create_timer(0.15).timeout
	await screenshot("1870_v085_charge_confirmation")
	await tap_cell(game.engine.unit_cell(game.engine.state.units[4]))
	check(game.engine.state.events.size()==1 and game.engine.state.events[0].kind=="charge" and game.map.busy(),"second enemy tap commits exactly one charge and animation")
	var events=game.engine.state.events.size();await tap_cell(game.engine.index(Vector2i(12,10)));check(game.engine.state.events.size()==events,"touch during charge cannot double execute")
	await create_timer(1.4).timeout
	check(not game.map.busy() and game.engine.state.units[10].ap==4,"charge animation completes, one PA remains")
	await screenshot("1870_v085_charge_resultat")
	game.show_journal();check(is_instance_valid(game.modal),"charge journal opens");game.close_modal()
	await arrange_charge(1);await tap_cell(game.engine.unit_cell(game.engine.state.units[11]));await tap_cell(game.engine.unit_cell(game.engine.state.units[0]));await press("charge")
	check(game.engine.state.events.size()==1 and game.engine.state.events[0].kind=="charge","Prussian charge button confirms selected target")
	await create_timer(1.4).timeout
	await arrange_charge();game.engine.state.units[10].ap=8
	await tap_cell(game.engine.unit_cell(game.engine.state.units[10]));await tap_cell(game.engine.unit_cell(game.engine.state.units[4]));check(game.actions.assault.disabled,"charge button disabled with insufficient PA")
	await tap_cell(game.engine.unit_cell(game.engine.state.units[4]));check(game.engine.state.events.is_empty(),"second tap cannot bypass charge PA gate")
	game.show_help(2);await screenshot("1870_v085_aide");game.close_modal()
	# Source data remains unchanged by the staged tests; show a normal new battle.
	game.engine=Rules085.new(JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/prototype.json")));game.map.engine=game.engine;game.engine.new_game();game.selected=10;game.clear_preview();game.map.zoom=1.18;game.map.focus=Vector2(765,580);game.refresh()
	await screenshot("1870_v085_carte")
	game.playing=false;game.set_process(false)
	for player in [game.music_player,game.sound_player,game.reaction_player,game.assault_player]:player.stop();player.stream=null
	await create_timer(0.3).timeout;game.queue_free();await process_frame;await process_frame;game=null
	print("CAVALRY UI 085: %d / %d passed"%[checks-failures,checks]);quit(1 if failures else 0)

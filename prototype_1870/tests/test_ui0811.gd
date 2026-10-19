extends "res://tests/test_formation_button_ui089.gd"
const Rules=preload("res://war_engine/core/engine.gd")
const Store=preload("res://war_engine/platform/save_store.gd")
func check_layout(case_name: String):
	var visible_buttons=[]
	for b in [game.actions.undo,game.actions.rest,game.actions.rally,game.actions.assault,game.actions.entrench,game.actions.deploy,game.formation_button]:
		if b.visible:visible_buttons.append(b)
	var valid=true
	for a in range(visible_buttons.size()):
		var b=visible_buttons[a]
		valid=valid and game.action_card.get_global_rect().encloses(b.get_global_rect())
		for c in range(a):valid=valid and not b.get_global_rect().intersects(visible_buttons[c].get_global_rect())
		for l in [game.context_label,game.context_detail]:valid=valid and not b.get_global_rect().intersects(l.get_global_rect())
	check(valid,case_name+": separate button and text rectangles")
	var font=game.context_label.get_theme_font("font");var fs=game.context_label.get_theme_font_size("font_size")
	check(font.get_string_size(game.context_label.text,HORIZONTAL_ALIGNMENT_LEFT,-1,fs).x<=game.context_label.size.x,case_name+": heading fits reserved width")
	check(game.context_detail.get_minimum_size().y<=70,case_name+": detail fits available height")
	var labels=[game.unit_label,game.terrain_label,game.unit_info,game.unit_ap,game.unit_state,game.formation_label,game.weapon_label,game.ammo_label,game.support_label,game.unit_reaction,game.encircled_label]
	valid=true
	for a in range(labels.size()):
		var l=labels[a]
		if not l.visible or l.text.is_empty():continue
		valid=valid and game.unit_card.get_global_rect().encloses(l.get_global_rect())
		for line in l.text.split("\n"):
			valid=valid and l.get_theme_font("font").get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,l.get_theme_font_size("font_size")).x<=l.size.x
		for c in range(a):
			if labels[c].visible and not labels[c].text.is_empty():valid=valid and not l.get_global_rect().intersects(labels[c].get_global_rect())
	check(valid,case_name+": unit rows and columns do not overlap")
func run():
	for file in ["save_v0811.json","save_v0810.json","save_v086.json"]:
		for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute("user://"+file+suffix)
	var old_raw=FileAccess.get_file_as_string("res://packs/1870/legacy0810.json");var old=Rules.new(JSON.parse_string(old_raw));old.state.units[10].ap=9
	var old_store=Store.new("user://save_v0810.json",old_raw.sha256_text());old_store.save_game(old)
	game=load("res://main.tscn").instantiate();root.add_child(game);game.ai_enabled=false
	await process_frame
	check(game.has_save and game.legacy_game and game.engine.state.units[10].ap==9 and game.engine.max_ap(10)==20,"legacy battle restored without adding PA")
	game.new_game(0);game.ai_enabled=false;game.engine.pack.rules.fog.enabled=false
	check(game.saver.path=="user://save_v0811.json" and game.engine.state.units[10].ap==20,"new battle uses 5 PA")
	game.selected=0;game.refresh();await process_frame
	check(game.unit_state.text=="En ordre" and game.unit_ap.text=="4 / 4 PA","short morale and numeric PA")
	check(game.support_label.position.x>game.ammo_label.position.x+game.ammo_label.size.x,"links in right column")
	check_layout("infantry initial");await screenshot("1870_v0811_fiche")
	await setup_case();game.ai_enabled=false
	check_layout("infantry after move")
	var dest=game.engine.index(Vector2i(11,8));await tap_cell(dest)
	check(not game.route.is_empty() and game.actions.undo.visible and game.context_detail.text.begins_with("Restants :"),"second route preview with undo reproduces reported case")
	check_layout("route plus undo");await screenshot("1870_v0811_trajet")
	await tap(game.actions.undo.get_global_rect().get_center())
	check(game.engine.state.units[6].ap==16 and game.engine.state.units[6].cell==[8,8],"undo remains clickable during preview")
	game.selected=11;game.clear_preview();game.refresh();await process_frame
	check(game.unit_ap.text=="5 / 5 PA","cavalry 5 / 5 shown")
	check_layout("cavalry");await screenshot("1870_v0811_cavalerie")
	game.selected=9;game.refresh();await process_frame;check_layout("artillery limbered")
	game.engine.state.units[9].deployed=true;game.refresh();await process_frame;check_layout("artillery deployed")
	game.selected=6;game.engine.state.units[6].entrenched=true;game.engine.state.units[6].ammo_level=2;game.refresh();await process_frame;check_layout("entrenched and rest")
	game.engine.state.units[6].morale="shaken";game.engine.state.units[6].command_ok=false;game.engine.state.units[6].supply_ok=false;game.engine.state.units[6].encircled=true
	game.refresh();await process_frame;check_layout("isolated disorganized");await screenshot("1870_v0811_isolee")
	game.selected=-1;game.inspected=game.engine.index(Vector2i(6,6));game.refresh();await process_frame;check_layout("terrain")
	game.new_game(0);game.ai_enabled=false;game.engine.pack.rules.fog.enabled=true
	for n in range(game.engine.state.units.size()):game.engine.state.units[n].cell=[0 if game.engine.state.units[n].side==0 else 29,n]
	game.engine.state.units[0].cell=[12,8];game.engine.state.units[4].cell=[12,9]
	game.engine.state.units[8].cell=[10,8];game.engine.state.units[9].cell=[14,8]
	game.engine.state.units[10].cell=[10,10];game.engine.state.units[11].cell=[14,10]
	game.engine.state.contacts=[{},{}];game.engine.state.revealed=[[],[]];game.engine.refresh_intel()
	game.map.focus=game.map.world(game.engine.index(Vector2i(12,9)));game.map.zoom=1.7
	game.selected=0;game.target=4;game.refresh();await process_frame
	check(game.engine.state.shots==0 and game.unit_info.text.contains("1000") and game.map.contact_power_text(4)=="10","enemy exact effectif displayed without combat")
	check(game.ammo_label.text.is_empty() and game.support_label.text.is_empty() and game.unit_ap.text.is_empty(),"enemy private ammo links and PA remain hidden")
	check_layout("enemy adjacent");await screenshot("1870_v0811_pions_contact")
	game.clear_preview();game.selected=0;game.refresh();await process_frame;check_layout("friendly enlarged card")
	await screenshot("1870_v0811_pions")
	game.map.zoom=1.18;game.refresh();await process_frame;await screenshot("1870_v0811_zoom_normal")
	game.map.zoom=0.65;game.refresh();await process_frame;await screenshot("1870_v0811_zoom_lointain")
	game.engine.state.units[0].cell=[0,0];game.engine.state.units[8].cell=[0,8];game.engine.state.units[10].cell=[0,10];game.engine.refresh_intel()
	check(game.map.contact_power_text(4)=="" and not game.engine.contact(4,0).has("exact_strength"),"out of sight removes exact enemy information")
	game.playing=false;game.set_process(false)
	for player in [game.music_player,game.sound_player,game.reaction_player,game.assault_player]:player.stop();player.stream=null
	game.queue_free();await process_frame;await process_frame;game=null
	print("UI 0811: %d/%d passed"%[checks-failures,checks]);quit(1 if failures else 0)

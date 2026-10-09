extends "res://tests/test_formation_button_ui089.gd"
const Rules=preload("res://war_engine/core/engine.gd")
const Store=preload("res://war_engine/platform/save_store.gd")
# Headless layout/controller integration; no physical touch or rendered screenshot.
func screenshot(_name: String):
	await process_frame
func tap_cell(index: int):
	game.on_cell(index);await process_frame
func tap(pos: Vector2):
	for b in [game.actions.undo,game.actions.rally,game.actions.assault,game.actions.entrench,game.actions.deploy,game.formation_button]:
		if b.visible and b.get_global_rect().has_point(pos):
			if b.disabled:
				var ev=InputEventScreenTouch.new();ev.pressed=true;ev.position=pos
				game.disabled_button_input(b,ev)
			else:b.pressed.emit()
			break
	await process_frame
func check_layout(case_name: String):
	var visible_buttons=[]
	for b in [game.actions.undo,game.actions.rally,game.actions.assault,game.actions.entrench,game.actions.deploy,game.formation_button]:
		if b.visible:visible_buttons.append(b)
	var valid=true
	for a in range(visible_buttons.size()):
		var b=visible_buttons[a]
		valid=valid and game.action_card.get_global_rect().encloses(b.get_global_rect())
		for c in range(a):valid=valid and not b.get_global_rect().intersects(visible_buttons[c].get_global_rect())
		for l in [game.context_label,game.context_detail]:
			if l.visible:valid=valid and not b.get_global_rect().intersects(l.get_global_rect())
	check(valid,case_name+": separate button and text rectangles")
	var font=game.context_label.get_theme_font("font");var fs=game.context_label.get_theme_font_size("font_size")
	check(font.get_string_size(game.context_label.text,HORIZONTAL_ALIGNMENT_LEFT,-1,fs).x<=game.context_label.size.x,case_name+": heading fits reserved width")
	check(game.context_detail.get_minimum_size().y<=70,case_name+": detail fits available height")
	var labels=[game.unit_label,game.terrain_label,game.unit_info,game.unit_ap,game.unit_state,game.formation_label,game.weapon_label,game.ammo_label,game.support_label,game.supply_label,game.unit_reaction,game.encircled_label]
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
	root.size=Vector2i(1520,720) if "--wide" in OS.get_cmdline_user_args() else Vector2i(1280,720)
	await process_frame
	print("UI viewport: ",root.get_visible_rect().size)
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute("user://save_v0816.json"+suffix)
	var old_raw=FileAccess.get_file_as_string("res://packs/1870/legacy0815.json")
	var old=Rules.new(JSON.parse_string(old_raw));old.state.units[0].ap=7
	var old_store=Store.new("user://save_v0815.json",old_raw.sha256_text())
	check(old_store.save_game(old),"write genuine v0815 save")
	game=load("res://main.tscn").instantiate();root.add_child(game);game.ai_enabled=false;game.music_enabled=false;game.music_player.stop();game.sound_enabled=false
	await process_frame
	check(game.has_save and game.legacy_game and game.engine.state.units[0].ap==7,"resume v0815 without changing PA or rules")
	await screenshot("1870_v0816_menu")
	game.new_game(0);game.ai_enabled=false
	await process_frame
	check(game.engine.max_ap(10)==16 and game.engine.max_ap(11)==16,"both cavalry budgets four PA")
	check(game.engine.validate(game.engine.state) and game.saver.path=="user://save_v0816.json","new battle uses corrected pack and independent save")
	var relief_count=0
	for i in range(600):relief_count+=game.map.relief_edges(i).size()
	check(relief_count>0,"public height transitions have contour lines")
	var matched=true
	for i in range(600):matched=matched and game.map.pick(game.map.screen(i))==i
	check(matched,"all 600 cells selectable with north on left")
	await tap_cell(game.engine.unit_cell(game.engine.state.units[0]));check(game.selected==0,"tap selects French unit")
	check_layout("initial Sauer unit");await screenshot("1870_v0816_apercu")
	await tap_cell(game.engine.unit_cell(game.engine.state.units[0]));check(game.selected==-1,"second tap deselects")
	game.engine.pack.rules.fog.enabled=false;game.engine.pack.map.tiles.fill("plain");game.engine.pack.map.elevations.fill(0)
	for n in range(game.engine.state.units.size()):game.engine.state.units[n].cell=[n*2,1]
	game.engine.state.units[0].cell=[19,11];game.engine.refresh_intel();game.map.focus=game.map.world(349);game.refresh();await process_frame
	await tap_cell(349);await tap_cell(379)
	check(game.route==[349,379] and game.context_detail.text.contains("+2 PA"),"tap destination previews ford and cost")
	check(game.map.crossing_edges(game.route)==[[349,379]],"one blue marker on planned open-water crossing")
	check(game.map.crossing_edges([382,412]).is_empty(),"no ford marker on bridge")
	check_layout("ford preview");await screenshot("1870_v0816_traversee")
	await tap_cell(379);check(game.engine.unit_cell(game.engine.state.units[0])==379 and game.engine.state.units[0].river_halt,"second destination tap crosses and stops movement")
	check(game.map.crossing_cell==379 and game.map.crossing_unit==0 and game.map.crossing_ttl>0 and not game.map.busy(),"brief crossing effect starts without input lock")
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
	check(game.context_detail.text.contains("Tir effectué"),"disabled undo explains reason")
	check_layout("disabled undo");await screenshot("1870_v0816_annulation")
	game.engine.state.units[0].ammo_level=2;game.engine.state.units[0].attacked=false;game.engine.state.units[0].supply_ok=true;game.refresh();await process_frame
	check(not game.actions.has("rest"),"Repos button removed")
	check(game.context_label.visible,"action heading always visible")
	check_layout("automatic supply")
	game.engine.state.units[0].morale="shaken";game.engine.state.units[0].command_ok=false;game.engine.state.units[0].supply_ok=false;game.engine.state.units[0].encircled=true
	game.refresh();await process_frame;check_layout("disorganized isolated infantry")
	game.engine.state.units[0].morale="stable"
	var ev=game.engine.state.events[-1].duplicate(true)
	ev.attacker_old_morale="stable";ev.attacker_new_morale="shaken"
	game.show_combat_report(ev);await process_frame
	check(game.context_detail.text.contains("Votre unité : Désorganisé"),"own morale change explained")
	check_layout("combat report")
	ev.new_morale="routed";ev.attacker_new_morale="stable"
	game.show_combat_report(ev)
	check(not game.context_detail.text.contains("déroute"),"hidden enemy morale not disclosed")
	game.show_formations();await process_frame
	for b in game.modal_box.get_children():
		if b is Label and b.autowrap_mode!=TextServer.AUTOWRAP_OFF:check(b.get_minimum_size().y<=b.size.y,"formation explanation fits")
	game.close_modal()
	# A normal move exhausting all PA must still be reversible by touch.
	game.engine.state.units[0].cell=[12,3];game.engine.state.units[0].formation="line";game.engine.state.units[0].ap=16;game.engine.state.units[0].done=false
	game.selected=0;game.clear_preview();game.route=[102,132,162,192,222];game.full_route=game.route.duplicate();game.commit_move();await process_frame
	check(game.engine.state.units[0].ap==0 and game.actions.undo.visible and not game.actions.undo.disabled,"zero PA retains enabled undo button")
	await tap(game.actions.undo.get_global_rect().get_center())
	check(game.engine.state.units[0].ap==16 and game.engine.unit_cell(game.engine.state.units[0])==102,"touch undo restores full PA after exhausted movement")
	game.new_game(1);game.ai_enabled=false;game.engine.state.side=1;game.engine.refresh_intel();game.map.focus=game.map.world(442);game.refresh();await process_frame
	await tap_cell(game.engine.unit_cell(game.engine.state.units[4]));check(game.selected==4,"Prussian camp selectable")
	check_layout("Prussian unit");await screenshot("1870_v0816_prusse")
	game.engine.pack.rules.fog.enabled=true;game.engine.state.units[0].cell=[11,3];game.engine.refresh_intel();game.map.crossing_ttl=0
	check(not game.engine.visible_to(1,0),"enemy hidden for crossing animation check")
	game.map.animate_crossing(0);check(game.map.crossing_ttl==0,"hidden enemy crossing never leaks through animation")
	game.show_help(1);await process_frame;await screenshot("1870_v0816_aide")
	game.close_modal();game.new_game(0);game.ai_enabled=false
	game.queue_free();await process_frame
	print("UI 0817: ",checks-failures,"/",checks," passed");quit(1 if failures else 0)

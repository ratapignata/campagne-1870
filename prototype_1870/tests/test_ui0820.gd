extends SceneTree
var checks=0
var failures=0
func check(ok: bool,msg: String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL "+msg)
func _initialize():call_deferred("run")
func run():
	root.size=Vector2i(1280,720)
	var game=load("res://main.tscn").instantiate();root.add_child(game);game.ai_enabled=false;game.music_player.stop();game.sound_enabled=false
	await process_frame
	game.scenario_choice="three";game.new_game(0);game.ai_enabled=false
	var e=game.engine
	check(e.fixed_hq() and e.state.units[0].is_hq,"new game carries QG")
	game.selected=0;game.refresh()
	check(not game.support_label.get_global_rect().intersects(game.supply_label.get_global_rect()),"command and supply touch targets separate")
	game.show_link_info(true);check(is_instance_valid(game.modal) and game.modal_box.find_children("*","RichTextLabel",true,false)[0].text.contains("10 hexagones"),"command explanation and radius")
	game.close_modal();game.show_link_info(false);check(game.modal_box.find_children("*","RichTextLabel",true,false)[0].text.contains("réserves"),"supply explanation")
	game.close_modal();game.selected=4;game.show_link_info(true);check(not is_instance_valid(game.modal),"enemy logistics cannot open")
	game.selected=-1;game.inspected=e.index(Vector2i(18,3));game.refresh();check(game.unit_label.text==game.t("supply_zone"),"rear depot description")
	# A visible target across a raised hex must report blocked BEFORE any confirmation.
	e.pack.rules.fog.enabled=false;e.pack.map.tiles.fill("plain");e.pack.map.elevations.fill(0);e.river_links={}
	for n in range(e.state.units.size()):e.state.units[n].cell=[28,n]
	e.state.units[0].cell=[8,4];e.state.units[4].cell=[8,6];e.state.units[0].formation="line";e.state.units[4].formation="line"
	e.pack.map.elevations[158]=5
	game.selected=0;game.clear_preview();game.on_cell(188)
	check(game.target==4 and game.context_label.text==game.t("fire_preview_blocked") and game.context_detail.text==game.t("fire_blocked_terrain"),"first enemy tap explains blocking relief")
	var before=e.state.duplicate(true);game.on_cell(188)
	check(e.state==before,"blocked second tap consumes neither AP nor ammunition")
	e.pack.map.elevations[158]=0;game.refresh()
	check(game.context_label.text==game.t("fire_preview_ok") and game.context_detail.text==game.t("fire_confirm"),"clear shot preview still requires second tap")
	game.on_cell(188);check(e.state.shots==1 and e.state.units[0].ap<int(before.units[0].ap),"second tap fires")
	game.map.combat_ttl=0;game.target=-1;game.selected=-1;game.refresh()
	# Transfer reported briefly, never duplicate on later refreshes.
	e.state.units[0].morale="routed";e.refresh_support();game.refresh()
	check(game.context_detail.text.begins_with("QG transféré"),"brief QG transfer notice")
	game.refresh();check(not game.context_detail.text.begins_with("QG transféré"),"transfer notice not repeated")
	# Actual previous-version saves remain loadable with their original pack hash and rules.
	for entry in [["classic","legacy0819.json","save_v0816.json"],["three","legacy_three0819.json","save_three_v0819.json"]]:
		var raw=FileAccess.get_file_as_string("res://packs/1870/"+entry[1]);var old=game.EngineRules.new(JSON.parse_string(raw));old.state.units[0].ap=9
		var slot=game.SaveStore.new("user://"+entry[2],raw.sha256_text());slot.save_game(old)
		for suffix in ["",".bak"]:DirAccess.remove_absolute("user://"+game.SCENARIOS[entry[0]].save+suffix)
		game.has_save=false;var found=game.saved_scenario(entry[0])
		check(not found.is_empty() and not found.engine.fixed_hq() and found.engine.state.units[0].ap==9,"legacy save retained "+entry[0])
	game.playing=false;game.queue_free();await process_frame
	print("UI 0820: ",checks-failures,"/",checks," (headless)")
	quit(1 if failures else 0)

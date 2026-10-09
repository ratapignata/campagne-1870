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
	for side in [0,1]:
		game.scenario_choice="three";game.new_game(side);game.ai_enabled=false
		var n=game.engine.unit_index("hq_"+str(side));game.on_cell(game.engine.unit_cell(game.engine.state.units[n]))
		check(game.selected==n and game.unit_label.text==game.t("hq_"+str(side)+"_short"),"QG selected and named "+str(side))
		check(game.unit_info.text.contains("250") and game.unit_ap.text.contains("4 / 4") and not game.formation_button.visible,"QG strength PA and simple controls")
		game.on_cell(game.engine.unit_cell(game.engine.state.units[n]));check(game.selected==-1,"second QG tap deselects")
		var cell=game.engine.pack.rules.support.supply_sources[side][0]
		game.on_cell(game.engine.index(Vector2i(cell[0],cell[1])))
		check(game.unit_label.text==game.t("supply_zone") and game.unit_state.text==game.t("supply_zone_detail"),"wagon terrain card")
		game.show_help();var help=game.modal_box.find_children("*","RichTextLabel",true,false)[0].text
		check(help.contains("250 hommes") and help.contains("chariots") and not help.contains("Le QG est intégré"),"updated help for separate QG and wagon")
		game.close_modal()
	for entry in [["classic","legacy0821.json","save_classic_v0821.json"],["three","legacy_three0821.json","save_three_v0821.json"]]:
		var raw=FileAccess.get_file_as_string("res://packs/1870/"+entry[1]);var old=game.EngineRules.new(JSON.parse_string(raw));old.state.units[0].ap=9
		var slot=game.SaveStore.new("user://"+entry[2],raw.sha256_text());slot.save_game(old)
		for suffix in ["",".bak"]:DirAccess.remove_absolute("user://"+game.SCENARIOS[entry[0]].save+suffix)
		game.has_save=false;var found=game.saved_scenario(entry[0])
		check(not found.is_empty() and found.engine.state.units.size()==14 and found.engine.state.units[0].ap==9,"v0821 save still loads "+entry[0])
	game.playing=false;game.queue_free();await process_frame
	print("HQ UI 0822 ",checks-failures,"/",checks," headless")
	quit(1 if failures else 0)

extends SceneTree
var checks=0
var failures=0
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL "+label)
func _initialize():call_deferred("run")
func run():
	var game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
	game.scenario_choice="historical";game.new_game(1);game.playing=false;game.music_player.stop()
	var e=game.engine;e.pack.rules.fog.enabled=false;e.state.side=1
	var gun=-1;var foe=-1
	for n in range(e.state.units.size()):
		if e.artillery(n) and int(e.state.units[n].side)==1:gun=n
		if not e.artillery(n) and int(e.state.units[n].side)==0:foe=n
	for u in e.state.units:u.strength=0
	for i in range(600):e.pack.map.tiles[i]="plain";e.pack.map.elevations[i]=0
	var a=e.state.units[gun];var b=e.state.units[foe]
	a.cell=[10,2];a.strength=a.initial_strength;a.pending=false;a.deployed=true;a.ap=16;a.done=false
	b.cell=[10,4];b.strength=b.initial_strength;b.pending=false
	game.selected=gun;game.target=foe;game.inspected=-1
	e.pack.map.tiles[100]="forest";game.refresh()
	check(game.context_label.text==game.t("fire_preview_blocked"),"blocked heading shown")
	check(game.context_detail.text==game.t("fire_blocked_cover"),"precise blocked reason visible")
	game._process(2);check(game.context_detail.text==game.t("fire_blocked_cover"),"blocked reason persists until interaction")
	e.pack.map.tiles[100]="plain";e.pack.map.elevations[100]=2;game.refresh()
	check(game.context_label.text==game.t("fire_preview_ok"),"plain shot available in UI")
	check(game.map.fire_cells.has(130),"enemy cell illuminated")
	e.pack.map.elevations[130]=2;game.refresh()
	check(game.terrain_label.text=="Hauteur","height in target terrain caption")
	var text_width=game.BODY.get_string_size(game.terrain_label.text,HORIZONTAL_ALIGNMENT_LEFT,-1,game.terrain_label.get_theme_font_size("font_size")).x
	check(text_width<=game.terrain_label.size.x,"height caption fits allocated width")
	var event=e.fire(gun,foe).event
	game.clear_preview();game.show_combat_report(event)
	check(game.context_label.text==game.t("combat_report_title"),"combat report displayed")
	game._process(1.4)
	check(game.context_label.text!=game.t("combat_report_title"),"report cleared after 1.3 seconds")
	game.queue_free();await process_frame
	print("FEEDBACK UI 0831 ",checks-failures,"/",checks);quit(1 if failures else 0)

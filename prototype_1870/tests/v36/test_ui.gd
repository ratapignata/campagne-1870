extends "res://tests/test_strict0833.gd"
func _initialize():call_deferred("run")
func tap(game,pos):
	for pressed in [true,false]:
		var event=InputEventScreenTouch.new();event.position=pos;event.pressed=pressed;event.index=0;Input.parse_input_event(event);await process_frame
	await process_frame
func run():
	root.size=Vector2i(1280,720)
	var game=load("res://main.tscn").instantiate();root.add_child(game);game.ai_enabled=false;game.music_player.stop();game.sound_enabled=false;game.close_modal()
	game.engine=fresh();game.map.engine=game.engine;game.playing=true
	var e=game.engine;e.state.units[foot].cell=[4,4];e.state.units[enemy].cell=[4,6];e.state.units[enemy].strength=e.state.units[enemy].initial_strength;e.state.units[enemy].casualties=0;e.state.units[enemy].ap=16;e.state.units[enemy].done=false
	e.refresh_support();e.refresh_intel();game.map.focus=game.map.world(e.index(Vector2i(4,5)));game.map.zoom=1.6;game.selected=-1;game.clear_preview();game.refresh();await process_frame
	var shoot=e.unit_cell(e.state.units[foot]);var target=e.unit_cell(e.state.units[enemy])
	check(e.fire_status(foot,enemy)=="ok","touch fixture permits fire")
	await tap(game,game.map.screen(shoot)+game.map.position)
	check(game.selected==foot,"touch selects infantry")
	await tap(game,game.map.screen(target)+game.map.position)
	check(game.target==enemy and e.state.shots==0,"first enemy touch only confirms aim")
	await tap(game,game.map.screen(target)+game.map.position)
	check(e.state.shots==1,"second enemy touch fires")
	var fire_button=false
	for b in game.find_children("*","Button",true,false):
		if b.text.strip_edges().to_upper()=="TIRER":fire_button=true
	check(not fire_button,"no TIRER button")
	game.map.combat_ttl=0;game.map.feedback_ttl=0
	var before=e.state.duplicate(true);var old_focus=game.map.focus;var center=game.map.position+Vector2(600,220)
	var touch=InputEventScreenTouch.new();touch.position=center;touch.pressed=true;touch.index=0;Input.parse_input_event(touch);await process_frame
	var drag=InputEventScreenDrag.new();drag.position=center+Vector2(70,0);drag.relative=Vector2(70,0);drag.index=0;Input.parse_input_event(drag);await process_frame
	touch=InputEventScreenTouch.new();touch.position=drag.position;touch.pressed=false;touch.index=0;Input.parse_input_event(touch);await process_frame
	check(game.map.focus!=old_focus and e.state==before,"drag pans without firing or changing battle")
	var old_zoom=game.map.zoom
	for k in [0,1]:
		touch=InputEventScreenTouch.new();touch.position=center+Vector2(k*120,0);touch.pressed=true;touch.index=k;Input.parse_input_event(touch);await process_frame
	drag=InputEventScreenDrag.new();drag.position=center+Vector2(190,0);drag.relative=Vector2(70,0);drag.index=1;Input.parse_input_event(drag);await process_frame
	for k in [0,1]:
		touch=InputEventScreenTouch.new();touch.position=center+Vector2(k*190,0);touch.pressed=false;touch.index=k;Input.parse_input_event(touch);await process_frame
	check(game.map.zoom>old_zoom and e.state==before,"pinch zooms without firing or changing battle")
	game.map.combat_ttl=0;e.state.turn=20;e.state.side=1;e.state.finished=false;game.refresh()
	check(game.score_label.text.begins_with(game.t("time")%[17,30]),"last active turn begins at 17:30")
	e.end_side();game.refresh();check(e.state.turn==20 and e.state.finished,"final clock adds no turn")
	check(game.score_label.text.begins_with(game.t("time")%[18,0]),"final clock displays 18:00")
	for location in e.pack.map.labels:
		if location.text=="Vers Reichshoffen":check(int(location.cell[0])==6 and int(location.cell[1])==2 and int(location.arrow_cell[0])==5 and int(location.arrow_cell[1])==0,"Reichshoffen arrow unchanged")
	game.playing=false;game.queue_free();await process_frame;game=null;e=null
	print("V36 UI ",checks-failures,"/",checks);call_deferred("quit",1 if failures else 0)

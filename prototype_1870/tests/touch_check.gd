extends SceneTree
var failures=0
var checks=0
var game
var taps=0
func _initialize():call_deferred("run")
func check(ok: bool,name: String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL: "+name)
	else:print("PASS: "+name)
func touch(pos: Vector2,pressed: bool,index: int=0):
	var event=InputEventScreenTouch.new();event.position=pos;event.pressed=pressed;event.index=index
	Input.parse_input_event(event);await process_frame
func tap(pos: Vector2):
	await touch(pos,true);await touch(pos,false);await process_frame
func drag(pos: Vector2,delta: Vector2,index: int=0):
	var event=InputEventScreenDrag.new();event.position=pos;event.relative=delta;event.index=index
	Input.parse_input_event(event);await process_frame
func mouse_click(pos: Vector2):
	for pressed in [true,false]:
		var event=InputEventMouseButton.new();event.position=pos;event.global_position=pos;event.pressed=pressed;event.button_index=MOUSE_BUTTON_LEFT;event.device=0
		Input.parse_input_event(event);await process_frame
	await process_frame
func find_button(node: Node,value: String) -> Button:
	if node is Button and node.text==value and node.is_visible_in_tree():return node
	for child in node.get_children():
		var result=find_button(child,value)
		if result!=null:return result
	return null
func press(key: String):
	var b=find_button(game,game.t(key))
	if b==null:check(false,"missing button "+key);return
	await tap(b.get_global_rect().get_center())
func tap_cell(index: int):await tap(game.map.screen(index)+game.map.position)
func screenshot(name: String):
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../releases/"+name+("_large" if root.get_visible_rect().size.x>1280 else "")+".png")
func run():
	game=load("res://main.tscn").instantiate();game.prefs_path="user://touch_prefs081.cfg";root.add_child(game);game.ai_enabled=false;game.engine.pack.rules.fog.enabled=false;game.engine.pack.rules.formations.initial="line"
	game.saver=load("res://war_engine/platform/save_store.gd").new("user://touch_test_save.json","touch-test")
	game.has_save=false;game.engine.new_game();game.refresh();game.show_menu()
	await process_frame;await process_frame
	await screenshot("1870_v081_menu")
	await press("start")
	check(is_instance_valid(game.modal) and find_button(game,game.t("choose_france"))!=null,"start opens camp selection")
	await screenshot("1870_v081_camp")
	await press("choose_france")
	check(game.playing and not is_instance_valid(game.modal),"touch starts through real button")
	if not game.playing:finish();return
	check(find_button(game,game.t("move"))==null,"no move button")
	check(find_button(game,game.t("overview"))==null and find_button(game,"+")==null and find_button(game,"−")==null,"no general view or zoom buttons")
	var terrain_cell=game.engine.index(Vector2i(12,9))
	game.engine.pack.map.tiles[terrain_cell]="village"
	await tap_cell(terrain_cell)
	check(game.selected==-1 and game.unit_label.text==game.t("terrain_village"),"empty terrain tap shows terrain sheet")
	check(game.unit_state.text.contains("Protection") and game.weapon_label.text.contains("Visibilité"),"terrain sheet shows movement protection and line of fire")
	await screenshot("1870_v081_fiche_terrain")
	game.map.cell_tapped.connect(func(_i):taps+=1)
	await tap_cell(game.engine.unit_cell(game.engine.state.units[0]))
	check(game.selected==0 and game.unit_info.text.contains("1000"),"selection opens unit sheet")
	check(taps==1,"touch produces one selection")
	check(not is_instance_valid(game.mission),"objective banner removed")
	check(game.ap_segments.size()==4 and game.ap_segments[0].size.x==33,"four PA segments shown")
	check(game.turn_label.get_theme_font_size("font_size")==26,"larger header type")
	var destination=game.engine.index(Vector2i(14,8))
	await tap_cell(destination)
	check(game.route.size()>1 and game.engine.state.moves==0,"first destination tap previews only")
	check(game.selected==0 and game.weapon_label.text.contains("Pont") and game.unit_info.text.contains("1000"),"destination terrain fits beneath selected unit summary")
	check(game.context_label.text.contains("Coût") and game.context_label.text.contains("Restants"),"cost and remaining AP explicit")
	await screenshot("1870_v081_apercu")
	await tap_cell(game.engine.unit_cell(game.engine.state.units[0]))
	check(game.route.is_empty() and game.selected==-1,"retap deselects unit and cancels route")
	await tap_cell(game.engine.unit_cell(game.engine.state.units[0]))
	await tap_cell(destination);await tap_cell(destination)
	check(game.engine.state.moves==1 and game.engine.state.units[0].ap<16,"second destination tap executes once")
	await press("undo")
	check(game.engine.state.moves==0 and game.engine.state.units[0].ap==16,"undo button restores move")
	# Alternating units does not end the previous activation.
	await tap_cell(game.engine.index(Vector2i(11,8)));await tap_cell(game.engine.index(Vector2i(11,8)))
	await tap_cell(game.engine.unit_cell(game.engine.state.units[1]))
	await tap_cell(game.engine.index(Vector2i(11,10)));await tap_cell(game.engine.index(Vector2i(11,10)))
	await tap_cell(game.engine.unit_cell(game.engine.state.units[0]))
	check(game.selected==0 and game.engine.can_act(0),"free selection after other unit moves")
	# Long preview: tapping the remote goal repeatedly never commits the reachable prefix.
	game.engine.new_game();game.map.feedback_ttl=0;game.selected=-1;game.clear_preview();game.refresh();game.map.zoom=0.68;game.map.focus=Vector2(765,530)
	await tap_cell(game.engine.unit_cell(game.engine.state.units[0]))
	var distant=game.engine.index(Vector2i(23,5))
	await tap_cell(distant)
	check(game.full_route.size()>game.route.size() and game.route.size()>1,"long request exposes reachable limit")
	var limit=int(game.route[-1]);await tap_cell(distant)
	check(game.engine.state.moves==0,"retapping far goal does not move")
	await screenshot("1870_v081_trajet_long")
	await tap_cell(limit)
	check(game.engine.state.moves==1 and game.engine.unit_cell(game.engine.state.units[0])==limit,"retapping limit moves to it")
	await press("help")
	check(is_instance_valid(game.modal),"touch opens help")
	await press("help_terrain")
	check(find_button(game,game.t("help_terrain"))!=null,"terrain help tab available")
	await screenshot("1870_v081_terrains")
	var scroll=game.modal_box.get_children().filter(func(n):return n is ScrollContainer)[0]
	await touch(Vector2(940,470),true);await drag(Vector2(940,445),Vector2(0,-25));await drag(Vector2(940,250),Vector2(0,-195));await touch(Vector2(940,250),false)
	await process_frame
	check(scroll.scroll_vertical>0,"terrain help scrolls with one finger")
	await press("close")
	check(not is_instance_valid(game.modal),"touch closes help")
	var previous_focus=game.map.focus;var previous_taps=taps
	await touch(Vector2(720,405),true);await drag(Vector2(775,405),Vector2(55,0));await touch(Vector2(775,405),false)
	check(game.map.focus.distance_to(previous_focus)>20 and taps==previous_taps,"pan without stray selection")
	var previous_zoom=game.map.zoom
	await touch(Vector2(600,420),true,0);await touch(Vector2(800,420),true,1);await drag(Vector2(840,420),Vector2(40,0),1)
	await touch(Vector2(840,420),false,1);await touch(Vector2(600,420),false,0)
	check(game.map.zoom>previous_zoom and taps==previous_taps,"pinch without stray selection")
	await press("end_turn")
	check(is_instance_valid(game.modal),"end turn asks while AP remain")
	await press("cancel")
	check(game.engine.state.side==0 and not is_instance_valid(game.modal),"cancel end turn keeps camp")
	for u in game.engine.state.units:
		if int(u.side)==0:u.ap=0;u.done=true
	game.refresh();await press("end_turn")
	check(game.engine.state.side==1 and not is_instance_valid(game.modal),"no confirmation when all AP spent")
	# Exercise real attack controls; a controlled layout makes the input test independent of tactical setup.
	game.engine.new_game();game.engine.state.units[0].cell=[16,8];game.engine.state.units[4].cell=[17,8]
	game.selected=-1;game.clear_preview();game.map.zoom=1.1;game.map.focus=game.map.world(game.engine.unit_cell(game.engine.state.units[0]));game.refresh()
	await tap_cell(game.engine.unit_cell(game.engine.state.units[0]));await tap_cell(game.engine.unit_cell(game.engine.state.units[4]))
	check(game.target==4 and game.engine.fire_status(0,4)=="ok","touch selects valid fire target")
	check(game.engine.state.shots==0,"first target tap never fires")
	check(game.unit_label.text==game.t(str(game.engine.state.units[4].name_key)+"_short") and game.selected==0,"enemy sheet shown without changing shooter")
	check(game.terrain_label.visible and game.terrain_label.text==game.t("terrain_short_"+str(game.engine.pack.map.tiles[game.engine.unit_cell(game.engine.state.units[4])])),"target terrain shown in first line")
	check(game.context_label.text==game.t("acting_shooter")%game.t(game.engine.state.units[0].name_key),"shooter distinguished from inspected enemy")
	check(game.weapon_label.text.contains("Dreyse") and game.unit_info.text==game.t("unit_strength")%[game.engine.state.units[4].strength,game.engine.state.units[4].initial_strength],"enemy sheet uses target's own weapon and strength")
	check(game.unit_label.get_global_rect().end.x<game.terrain_label.get_global_rect().position.x,"name and terrain fields do not overlap")
	check(game.context_detail.text==game.t("fire_confirm"),"no forecast before shot")
	check(game.actions.assault.visible and not game.actions.assault.disabled,"adjacent target exposes separate assault button")
	await screenshot("1870_v081_cibles")
	await tap_cell(game.engine.unit_cell(game.engine.state.units[0]))
	check(game.selected==-1 and game.target==-1 and game.engine.state.shots==0,"retap deselects without firing prepared target")
	await tap_cell(game.engine.unit_cell(game.engine.state.units[0]));await tap_cell(game.engine.unit_cell(game.engine.state.units[4]))
	check(find_button(game,game.t("fire"))==null,"fire button removed")
	await tap_cell(game.engine.unit_cell(game.engine.state.units[4]))
	check(game.engine.state.shots==1 and game.map.busy(),"second tap shoots and animates")
	check(game.engine.state.events[-1].reaction and game.engine.losses(0)>0,"touch fire applies attacker losses through reaction")
	await create_timer(.4).timeout
	check(game.map.reaction_sounded and game.map.combat_duration==1.15,"reaction sound triggers without extending animation")
	await screenshot("1870_v081_riposte")
	await tap_cell(game.engine.unit_cell(game.engine.state.units[4]))
	check(game.engine.state.shots==1 and game.target==-1,"extra tap during animation ignored")
	await screenshot("1870_v081_animation")
	await create_timer(1.3).timeout
	check(game.map.feedback_ttl>0 and game.map.feedback_text.contains("Français") and game.map.feedback_text.contains("Prussiens"),"feedback after short animation")
	await tap_cell(game.engine.unit_cell(game.engine.state.units[4]))
	check(game.engine.state.shots==1 and game.target==4,"fresh shot needs new selection")
	await tap_cell(game.engine.unit_cell(game.engine.state.units[0]))
	await screenshot("1870_v081_tir")
	check(game.actions.undo.disabled,"shot disables undo")
	await press("journal")
	check(is_instance_valid(game.modal) and game.engine.state.events.size()==1,"journal available after shot")
	await press("close");await press("menu");await press("continue")
	check(not is_instance_valid(game.modal) and game.engine.state.shots==1,"menu continue preserves session")
	await mouse_click(find_button(game,game.t("help")).get_global_rect().get_center())
	check(is_instance_valid(game.modal),"physical mouse still opens help")
	await press("close")
	# Entrenchment uses the real control, persists and is restored by movement undo.
	game.engine.new_game();game.selected=-1;game.clear_preview();game.map.feedback_ttl=0;game.map.combat_ttl=0
	game.map.focus=game.map.world(game.engine.unit_cell(game.engine.state.units[0]));game.refresh()
	await tap_cell(game.engine.unit_cell(game.engine.state.units[0]))
	check(game.actions.entrench.visible and not game.actions.entrench.disabled,"selected infantry offers entrenchment")
	await press("entrench")
	check(game.engine.state.units[0].entrenched and game.engine.state.units[0].ap==8,"touch digging spends two PA")
	await screenshot("1870_v081_retranchement")
	var step=game.engine.index(Vector2i(11,8));await tap_cell(step);await tap_cell(step)
	check(not game.engine.state.units[0].entrenched and game.actions.undo.visible,"moving abandons shelter and offers undo")
	check(not game.actions.undo.get_global_rect().intersects(game.actions.entrench.get_global_rect()),"digging and undo controls do not overlap")
	await press("undo")
	check(game.engine.state.units[0].entrenched and game.engine.state.moves==0,"touch undo restores shelter")
	# Battery controls, posture persistence, help and no forecast.
	game.engine.new_game();game.map.feedback_ttl=0;game.selected=-1;game.clear_preview()
	game.map.focus=game.map.world(game.engine.unit_cell(game.engine.state.units[8]));game.map.zoom=1.1;game.refresh()
	await tap_cell(game.engine.unit_cell(game.engine.state.units[8]))
	check(game.selected==8 and game.actions.deploy.visible,"battery shows deployment control")
	check(game.weapon_label.text.contains("Canon français"),"battery weapon shown in sheet")
	await press("deploy")
	check(game.engine.state.units[8].deployed and game.engine.state.units[8].ap==12,"touch deploy spends one PA")
	check(game.map.reachable.is_empty(),"deployed unit shows no movement range")
	await screenshot("1870_v081_artillerie")
	check(game.unit_reaction.text==game.t("reaction_ready"),"sheet explains ready battery reaction")
	await press("limber")
	check(not game.engine.state.units[8].deployed and not game.map.reachable.is_empty(),"touch limber restores movement")
	await press("help");await press("help_fire")
	var help_scroll=game.modal_box.get_children().filter(func(n):return n is ScrollContainer)[0]
	var help_content=help_scroll.get_child(0).text
	check(help_content.contains("Chassepot : 3") and help_content.contains("Dreyse : 2") and help_content.contains("Krupp : 6"),"help lists weapon rules from pack")
	await screenshot("1870_v081_armes");await press("close")
	# Selecting an enemy before deployment offers the deployment action, not a dead end.
	game.engine.new_game();game.engine.pack.map.tiles.fill("plain")
	game.engine.state.side=1;game.engine.state.units[9].cell=[16,8];game.engine.state.units[0].cell=[16,11]
	game.selected=-1;game.clear_preview();game.map.focus=game.map.world(game.engine.unit_cell(game.engine.state.units[9]));game.refresh()
	await tap_cell(game.engine.unit_cell(game.engine.state.units[9]));await tap_cell(game.engine.unit_cell(game.engine.state.units[0]))
	check(game.target==0 and game.actions.deploy.visible,"limbered target selection offers deployment")
	await press("deploy");await tap_cell(game.engine.unit_cell(game.engine.state.units[0]))
	check(game.engine.fire_status(9,0)=="ok" and not game.actions.deploy.visible,"deployed Krupp exposes fire command")
	await tap_cell(game.engine.unit_cell(game.engine.state.units[0]))
	await create_timer(1.3).timeout
	check(game.engine.state.shots==1 and game.engine.state.units[9].ap==4,"second tap fires Krupp once")
	var restored=game.engine.get_script().new(game.engine.pack)
	check(game.saver.load_game(restored) and restored.state==game.engine.state,"UI autosave restores battery and firing state")
	game.engine.new_game();game.map.feedback_ttl=0;game.map.combat_ttl=0
	game.engine.state.units[0].morale="routed";game.engine.state.units[0].cohesion=20;game.engine.state.units[0].cell=[3,3]
	game.selected=-1;game.clear_preview();game.map.focus=game.map.world(game.engine.unit_cell(game.engine.state.units[0]));game.refresh()
	var old_focus=game.map.focus
	await tap_cell(game.engine.unit_cell(game.engine.state.units[0]))
	check(game.map.focus==old_focus,"selecting unit leaves camera still")
	check(game.actions.rally.visible and not game.actions.rally.disabled,"routed safe unit offers rally")
	check(game.context_detail.text==game.t("rally_ok"),"routing hint describes rally instead of movement")
	await screenshot("1870_v081_moral");await press("rally")
	await screenshot("1870_v081_desorganise")
	check(game.unit_state.text.contains("Désorganisé"),"sheet uses new morale name")
	check(game.engine.state.units[0].morale=="shaken" and game.engine.state.units[0].ap==8,"rally touch applies one state improvement")
	await press("help");var previous_sound=game.sound_enabled
	await press("sound_on" if previous_sound else "sound_off")
	check(game.sound_enabled!=previous_sound,"sound setting toggles")
	await press("sound_on" if game.sound_enabled else "sound_off");await press("close")
	# Assault button, outcome, terrain-aware UI and exact autosave.
	game.engine.new_game();game.engine.pack.map.tiles.fill("plain")
	for n in range(game.engine.state.units.size()):game.engine.state.units[n].cell=[n*2,18]
	game.engine.state.units[0].cell=[15,8];game.engine.state.units[4].cell=[15,9]
	game.engine.state.units[4].strength=400;game.engine.state.units[4].casualties=600
	game.selected=-1;game.clear_preview();game.map.feedback_ttl=0;game.map.combat_ttl=0
	game.map.focus=game.map.world(game.engine.unit_cell(game.engine.state.units[0]));game.map.zoom=1.18;game.refresh()
	await tap_cell(game.engine.unit_cell(game.engine.state.units[0]));await tap_cell(game.engine.unit_cell(game.engine.state.units[4]))
	check(game.engine.state.assaults==0 and game.actions.assault.visible,"selecting target does not launch assault")
	var assault_signals=[0];game.map.assault_sound.connect(func():assault_signals[0]+=1)
	await press("assault")
	check(assault_signals[0]==1,"assault emits its separate sound")
	check(game.engine.state.assaults==1 and game.engine.state.shots==0 and game.map.busy(),"assault button launches assault instead of fire")
	check(game.engine.state.units[0].ap==4 and game.engine.unit_cell(game.engine.state.units[0])==game.engine.objective(),"touch assault takes objective automatically for three PA")
	await create_timer(1.3).timeout
	check(game.map.feedback_text.contains("Position prise") and not game.map.feedback_text.contains("Nous"),"postcombat message names camps and outcome")
	await screenshot("1870_v081_assaut")
	restored=game.engine.get_script().new(game.engine.pack)
	check(game.saver.load_game(restored) and restored.state==game.engine.state,"UI autosaves assault and spent defender reaction exactly")
	await press("journal");await screenshot("1870_v081_journal");await press("close")
	check(game.context_detail.get_global_rect().end.x<game.actions.end_turn.get_global_rect().position.x,"context text area avoids end turn controls")
	game.ai_enabled=true;game.show_camp_choice();await press("choose_germany")
	check(game.engine.state.human_side==1 and not game.human_turn(),"German choice gives first turn to French AI")
	game._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	var suspended_state=game.engine.state.duplicate(true);await create_timer(0.4).timeout
	check(game.engine.state==suspended_state,"application pause suspends AI")
	game._notification(Node.NOTIFICATION_APPLICATION_RESUMED)
	game.show_menu();var before_pause=game.engine.state.duplicate(true);await create_timer(0.4).timeout
	check(game.engine.state==before_pause,"menu pauses AI")
	await press("continue")
	var ai_deadline=Time.get_ticks_msec()+25000
	while game.engine.state.side==0 and Time.get_ticks_msec()<ai_deadline:await process_frame
	check(game.engine.state.side==1 and game.engine.state.moves>0,"AI completes turn and hands control to German player")
	check(game.human_turn() and not game.actions.end_turn.disabled,"player controls enabled after AI")
	game.ai_enabled=false;game.engine.new_game()
	for k in range(12):game.end_side()
	check(game.engine.state.finished and is_instance_valid(game.modal),"six full rounds show result")
	game.engine.state.human_side=1;game.engine.state.scores=[4,1];game.engine.state.owner=0;game.show_result()
	check(game.engine.result_for(1).level=="minor_loss","result follows selected German camp")
	await press("inspect_battle")
	check(not is_instance_valid(game.modal) and game.actions.end_turn.text==game.t("results") and not game.actions.end_turn.disabled,"inspect closes result with enabled return button")
	var final_state=game.engine.state.duplicate(true)
	game.map.focus=game.map.world(game.engine.unit_cell(game.engine.state.units[8]))
	await tap_cell(game.engine.unit_cell(game.engine.state.units[8]))
	check(game.selected==8 and not game.actions.deploy.visible and not game.actions.entrench.visible and not game.actions.undo.visible,"postbattle inspection hides military controls")
	await tap_cell(game.engine.unit_cell(game.engine.state.units[8]));check(game.selected==-1,"postbattle retap deselects")
	await tap_cell(game.engine.index(Vector2i(12,9)))
	check(game.engine.state==final_state,"postbattle map taps never change battle")
	await press("results");check(is_instance_valid(game.modal),"results reopen from map")
	game.engine.state.human_side=0;game.show_result();await screenshot("1870_v081_resultat")
	# Reproduce the supplied result: French 979 casualties, German 1963 + 1868 prisoners.
	game.engine.new_game();game.engine.state.finished=true;game.engine.state.owner=0;game.engine.state.scores=[1,4]
	game.engine.state.units[0].strength=21;game.engine.state.units[0].casualties=979
	game.engine.state.units[4].strength=0;game.engine.state.units[4].casualties=1000
	game.engine.state.units[5].strength=37;game.engine.state.units[5].casualties=963
	game.engine.state.units[6].strength=0;game.engine.state.units[6].prisoners=1000
	game.engine.state.units[7].strength=132;game.engine.state.units[7].prisoners=868
	game.show_result();check(game.engine.result_for(0).level=="major_win","user example with final French control is major victory")
	await screenshot("1870_v081_resultat_reconquete")
	var explanation=game.modal_box.get_children().filter(func(n):return n is Label and n.text==game.result_reason(game.engine.result_for(0)))[0]
	check(explanation.size.x<=964 and explanation.size.y<=55,"result explanation fits panel")
	await press("inspect_battle");game.show_menu()
	var sound_before=game.sound_enabled
	await press("music_on" if game.music_enabled else "music_off")
	check(not game.music_enabled and not game.music_player.playing and game.sound_enabled==sound_before,"menu music off leaves effects setting intact")
	await press("music_off");check(game.music_enabled and game.music_player.playing,"menu music on starts playback")
	var prefs=ConfigFile.new();prefs.load(game.prefs_path)
	check(prefs.get_value("audio","music")==true and prefs.get_value("audio","enabled")==sound_before,"both audio choices persisted separately")
	game._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	check(game.music_player.stream_paused,"background pauses music")
	game._notification(Node.NOTIFICATION_APPLICATION_RESUMED)
	check(not game.music_player.stream_paused,"resume restores music")
	await revision07_ui()
	await inspection071_ui()
	await gestures072_ui()
	await formations08_ui()
	await formations081_ui()
	finish()
func finish():
	game.playing=false
	DirAccess.remove_absolute(game.prefs_path)
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute("user://touch_test_save.json"+suffix)
	for player in [game.music_player,game.sound_player,game.reaction_player,game.assault_player]:player.stop();player.stream=null
	await create_timer(0.3).timeout
	game.queue_free();await process_frame;await process_frame
	print("INPUT CHECKS: %d passed / %d total"%[checks-failures,checks]);quit(1 if failures else 0)
func revision07_ui():
	game.close_modal();game.engine.new_game();game.engine.pack.map.tiles.fill("plain");game.selected=-1;game.clear_preview()
	for n in range(game.engine.state.units.size()):game.engine.state.units[n].cell=[n*2,18]
	game.engine.state.units[8].cell=[4,4];game.engine.state.units[8].deployed=true
	game.engine.state.units[0].cell=[4,7];game.engine.state.units[4].cell=[4,10]
	game.map.focus=game.map.world(game.engine.index(Vector2i(4,7)));game.map.zoom=0.9;game.refresh();await process_frame
	await tap_cell(game.engine.unit_cell(game.engine.state.units[8]));await tap_cell(game.engine.unit_cell(game.engine.state.units[4]))
	check(game.context_detail.text==game.t("fire_blocked_friendly"),"friendly blocker explained without automatic marker")
	await tap_cell(game.engine.unit_cell(game.engine.state.units[4]));check(game.engine.state.shots==0,"retap cannot fire blocked gun")
	game.engine.pack.map.tiles[game.engine.unit_cell(game.engine.state.units[8])]="hill";game.refresh()
	check(game.context_detail.text==game.t("fire_confirm"),"elevated gun permits normal confirmation")
	await screenshot("1870_v081_tir_en_hauteur")
	await tap_cell(game.engine.unit_cell(game.engine.state.units[4]))
	check(game.engine.state.shots==1 and game.engine.state.units[0].strength==1000,"overhead shot spares friendly troops")
	await create_timer(1.3).timeout
	game.engine.state.units[0].morale="shaken";game.engine.state.units[0].cohesion=60;game.engine.state.units[0].entrenched=true
	game.selected=0;game.clear_preview();game.map.focus=game.map.world(game.engine.unit_cell(game.engine.state.units[0]));game.map.zoom=1.6;game.refresh();await process_frame
	check(game.unit_state.text=="Désorganisé · Retranché","morale and shelter share one readable line")
	check(game.unit_info.get_global_rect().end.x<game.unit_ap.get_global_rect().position.x,"strength and AP rectangles do not overlap")
	check(game.weapon_label.get_global_rect().end.x<game.unit_reaction.get_global_rect().position.x,"weapon and reaction rectangles do not overlap")
	await screenshot("1870_v081_fiche_desorganise_retranche")
	game.engine.state.side=1;game.end_side()
	check(not (game.context_label.text+game.context_detail.text).to_lower().contains("à vous de jouer"),"no duplicate player-turn message in footer")
	check(game.turn_label.text.contains("Vous"),"top band retains player turn")
	game.selected=9;game.engine.state.units[9].morale="shaken";game.engine.state.units[9].entrenched=true;game.engine.state.units[9].deployed=true;game.refresh();await process_frame
	for field in [game.unit_label,game.unit_info,game.unit_ap,game.unit_state,game.weapon_label,game.unit_reaction,game.terrain_label]:
		check(field.get_theme_font("font").get_string_size(field.text,HORIZONTAL_ALIGNMENT_LEFT,-1,field.get_theme_font_size("font_size")).x<=field.size.x,"sheet text fits: "+field.text)
	game.engine.state.finished=true;game.engine.state.owner=0;game.engine.state.scores=[6,0];game.show_result()
	check(game.engine.result_for(0).level=="minor_win" and game.result_reason(game.engine.result_for(0)).contains("pertes insuffisant"),"minor result explains missing military edge")
	await screenshot("1870_v081_resultat_mineur")
func inspection071_ui():
	game.close_modal();game.engine.new_game();game.selected=-1;game.clear_preview();game.map.combat_ttl=0;game.map.feedback_ttl=0
	game.engine.pack.map.tiles.fill("plain")
	for n in range(game.engine.state.units.size()):game.engine.state.units[n].cell=[n*2,18]
	game.engine.state.units[4].cell=[4,6]
	var enemy_cell=game.engine.unit_cell(game.engine.state.units[4]);game.engine.pack.map.tiles[enemy_cell]="village"
	game.map.focus=game.map.world(enemy_cell);game.map.zoom=1.6;game.refresh();await process_frame
	var before=game.engine.state.duplicate(true)
	await tap_cell(enemy_cell)
	check(game.selected==4 and game.unit_label.text==game.t("unit_1_0_short") and game.terrain_label.text==game.t("terrain_short_village"),"direct enemy inspection shows terrain and no INF prefix")
	check(not game.actions.assault.visible and not game.actions.entrench.visible and not game.actions.deploy.visible,"enemy inspection exposes no military orders")
	check(game.engine.state==before,"inspection does not mutate battle")
	await screenshot("1870_v081_ennemi_village")
	await tap_cell(enemy_cell)
	check(game.selected==-1 and not game.terrain_label.visible,"enemy retap clears sheet and terrain")
	game.engine.state.units[0].cell=[4,4];game.engine.pack.map.tiles[game.engine.unit_cell(game.engine.state.units[0])]="hill"
	game.map.focus=game.map.world(game.engine.index(Vector2i(4,5)));game.map.zoom=1.2;game.refresh();await process_frame
	await tap_cell(game.engine.unit_cell(game.engine.state.units[0]));await tap_cell(enemy_cell)
	check(game.terrain_label.text==game.t("terrain_short_village") and game.selected==0 and game.target==4,"target terrain replaces shooter terrain during aim")
	await screenshot("1870_v081_cible_village")
	await tap_cell(game.engine.unit_cell(game.engine.state.units[0]));await tap_cell(game.engine.unit_cell(game.engine.state.units[0]))
	check(game.terrain_label.text==game.t("terrain_short_hill") and game.target==-1,"returning to shooter restores its terrain")
	game.engine.state.units[9].cell=[5,6];game.engine.state.units[8].cell=[5,4];game.engine.state.units[9].deployed=true;game.engine.state.units[8].deployed=true
	game.selected=-1;game.clear_preview();game.map.zoom=1.8;game.refresh();await process_frame
	await screenshot("1870_v081_pions_drapeaux")
func gestures072_ui():
	game.close_modal();game.engine.new_game();game.engine.pack.map.tiles.fill("plain");game.selected=-1;game.clear_preview();game.map.combat_ttl=0;game.map.feedback_ttl=0;game.map.cancel_interaction()
	for n in range(game.engine.state.units.size()):game.engine.state.units[n].cell=[n*2,18]
	game.engine.state.units[0].cell=[4,4];game.engine.state.units[4].cell=[4,6]
	game.engine.state.units[4].morale="shaken";game.engine.state.units[4].cohesion=60;game.engine.state.units[4].entrenched=true
	var own_cell=game.engine.unit_cell(game.engine.state.units[0]);var enemy_cell=game.engine.unit_cell(game.engine.state.units[4])
	game.engine.pack.map.tiles[enemy_cell]="village"
	game.map.focus=game.map.world(game.engine.index(Vector2i(4,5)));game.map.zoom=1.4;game.refresh();await process_frame
	check(not game.actions.undo.visible,"undo hidden without reversible action")
	await tap_cell(own_cell)
	check(game.unit_flag.visible and game.unit_flag.texture==game.FLAGS[0] and game.unit_label.text=="Infanterie 1","French flag replaces camp suffix")
	await tap_cell(enemy_cell)
	check(game.unit_flag.visible and game.unit_flag.texture==game.FLAGS[1] and game.unit_label.text=="Infanterie 1","target German flag replaces camp suffix")
	check(game.unit_flag.get_global_rect().end.x<game.unit_label.get_global_rect().position.x and game.unit_label.get_global_rect().end.x<game.terrain_label.get_global_rect().position.x,"flag name terrain do not overlap")
	var before=game.engine.state.duplicate(true)
	var center=game.map.screen(enemy_cell)+game.map.position
	var d_point=center+Vector2(-12,0)*game.map.zoom
	var shovel_point=center+Vector2(21,3)*game.map.zoom
	await touch(d_point,true);await create_timer(0.65).timeout
	check(game.map.help_tip.visible and game.map.help_title.text==game.t("tip_shaken_title"),"holding D opens disorganization explanation")
	check(not game.map.busy(),"help does not count as combat animation")
	await screenshot("1870_v081_aide_desorganise")
	await touch(d_point,false)
	check(game.engine.state==before and game.selected==0 and game.target==4,"long press on already targeted enemy cannot fire or change selection")
	check(game.map.help_tip.visible,"explanation remains briefly after release")
	await touch(shovel_point,true);await create_timer(0.65).timeout;await touch(shovel_point,false)
	check(game.map.help_tip.visible and game.map.help_title.text==game.t("tip_entrenched_title"),"holding shovel opens shelter explanation")
	check(game.engine.state==before,"shovel help cannot spend AP or change shelter")
	await screenshot("1870_v081_aide_retranchement")
	var tip_rect=Rect2(game.map.help_tip.position,game.map.help_tip.size)
	check(Rect2(Vector2.ZERO,game.map.size).encloses(tip_rect),"help stays inside map")
	check(game.map.help_body.get_line_count()*game.map.help_body.get_line_height()<=game.map.help_body.size.y,"help text fits bubble")
	# Drag and pinch must cancel a pending help without releasing a tap.
	await touch(d_point,true);await drag(d_point+Vector2(45,0),Vector2(45,0));await create_timer(0.65).timeout;await touch(d_point+Vector2(45,0),false)
	check(not game.map.help_tip.visible and game.engine.state==before and game.target==4,"drag cancels hold without firing")
	game.map.focus=game.map.world(game.engine.index(Vector2i(4,5)));game.refresh();await process_frame
	center=game.map.screen(enemy_cell)+game.map.position;d_point=center+Vector2(-12,0)*game.map.zoom
	await touch(d_point,true,0);await touch(d_point+Vector2(100,0),true,1);await create_timer(0.65).timeout
	await touch(d_point,false,0);await touch(d_point+Vector2(100,0),false,1)
	check(not game.map.help_tip.visible and game.engine.state==before and game.target==4,"second finger cancels hold and suppresses tap")
	await touch(d_point,true);await create_timer(0.2).timeout;game._notification(Node.NOTIFICATION_APPLICATION_PAUSED);game._notification(Node.NOTIFICATION_APPLICATION_RESUMED);await touch(d_point,false)
	check(not game.map.help_tip.visible and not game.map.press_pending and game.engine.state==before,"interruption cancels pending gesture")
	await touch(d_point,true)
	var cancel=InputEventScreenTouch.new();cancel.position=d_point;cancel.index=0;cancel.pressed=false;cancel.canceled=true;Input.parse_input_event(cancel);await process_frame
	check(game.engine.state==before and not game.map.press_pending,"cancelled touch never confirms shot")
	# Holding with a physical mouse uses the same safe gesture.
	var press_event=InputEventMouseButton.new();press_event.position=d_point;press_event.global_position=d_point;press_event.pressed=true;press_event.button_index=MOUSE_BUTTON_LEFT;Input.parse_input_event(press_event)
	await create_timer(0.65).timeout
	press_event=InputEventMouseButton.new();press_event.position=d_point;press_event.global_position=d_point;press_event.pressed=false;press_event.button_index=MOUSE_BUTTON_LEFT;Input.parse_input_event(press_event);await process_frame
	check(game.map.help_tip.visible and game.engine.state==before,"mouse hold opens help without attack")
	game.map.help_ttl=0.05;await create_timer(0.15).timeout
	check(not game.map.help_tip.visible,"help hides after timeout")
	# A following ordinary tap still confirms once, using the original shooter.
	await tap_cell(enemy_cell)
	check(game.engine.state.shots==1 and game.engine.state.events[-1].shooter==0,"normal tap after long press still fires once from original shooter")
	check(not game.actions.undo.visible,"undo hidden after irreversible combat")
	await create_timer(1.3).timeout
	game.engine.new_game();game.selected=-1;game.clear_preview();game.map.combat_ttl=0;game.map.feedback_ttl=0;game.map.focus=game.map.world(game.engine.unit_cell(game.engine.state.units[0]));game.refresh()
	await tap_cell(game.engine.unit_cell(game.engine.state.units[0]))
	var destination=game.engine.index(Vector2i(11,8))
	await tap_cell(destination);await tap_cell(destination)
	check(game.actions.undo.visible and not game.actions.undo.disabled,"undo appears after reversible move")
	await press("undo");check(not game.actions.undo.visible,"undo hides after use")
	await tap_cell(game.engine.unit_cell(game.engine.state.units[0]));check(not game.unit_flag.visible,"flag hidden with empty sheet")

func formations08_ui():
	game.close_modal();game.engine.new_game();game.selected=-1;game.clear_preview();game.map.combat_ttl=0;game.map.feedback_ttl=0;game.map.cancel_interaction();game.ai_enabled=false
	game.engine.pack.map.tiles.fill("plain")
	for n in range(game.engine.state.units.size()):game.engine.state.units[n].cell=[n*2,18]
	game.engine.state.units[0].cell=[4,4];game.engine.state.units[4].cell=[4,7]
	var start=game.engine.unit_cell(game.engine.state.units[0]);game.map.focus=game.map.world(game.engine.index(Vector2i(4,6)));game.map.zoom=1.0;game.refresh();await process_frame
	await tap_cell(start)
	check(game.formation_button.visible and game.formation_button.text==game.t("formation_button")%game.t("formation_line") and not game.formation_button.disabled,"own infantry shows line control")
	check(game.unit_state.get_global_rect().end.x<game.formation_button.get_global_rect().position.x,"morale and formation do not overlap")
	await tap(game.formation_button.get_global_rect().get_center())
	check(is_instance_valid(game.modal) and find_button(game.modal,game.t("formation_line")).disabled,"current choice disabled")
	check(game.engine.state.units[0].ap==16,"opening costs no AP")
	await screenshot("1870_v081_choix_formations")
	await press("formation_column")
	check(not is_instance_valid(game.modal) and game.engine.formation(0)=="column" and game.engine.state.units[0].ap==12,"column costs one PA")
	check(game.formation_button.text==game.t("formation_button")%game.t("formation_column") and game.unit_ap.text.contains("3 / 4"),"sheet reflects formation and AP")
	var destination=game.engine.index(Vector2i(5,4));await tap_cell(destination)
	check(game.context_label.text.contains("0,75") and game.weapon_label.text.contains("0,75"),"route and terrain show column cost")
	await tap_cell(destination)
	check(game.engine.state.units[0].ap==9 and game.actions.undo.visible,"column movement uses three quarters")
	await press("undo");check(game.engine.state.units[0].ap==12 and game.engine.formation(0)=="column","undo preserves chosen formation")
	await tap(game.formation_button.get_global_rect().get_center());await press("formation_skirmish")
	check(game.engine.formation(0)=="skirmish" and game.engine.state.units[0].ap==8 and not game.actions.undo.visible,"second change charged and clears undo")
	var before=game.engine.state.duplicate(true);game.saver.save_game(game.engine)
	var restored=load("res://war_engine/core/engine.gd").new(game.engine.pack)
	check(game.saver.load_game(restored) and restored.state==before,"UI save exact restore")
	game.engine.state.units[0].morale="shaken";game.engine.state.units[0].cohesion=60;game.engine.state.units[0].entrenched=true;game.refresh();await process_frame
	check(game.unit_state.get_theme_font("font").get_string_size(game.unit_state.text,HORIZONTAL_ALIGNMENT_LEFT,-1,game.unit_state.get_theme_font_size("font_size")).x<=game.unit_state.size.x,"long morale fits")
	await screenshot("1870_v081_fiche_tirailleurs")
	game.engine.state.units[4].formation="column";await tap_cell(game.engine.unit_cell(game.engine.state.units[4]))
	check(not game.formation_button.visible and game.formation_label.visible and game.formation_label.text==game.t("formation_column"),"enemy formation read only")
	check(game.selected==0 and game.target==4,"own shooter retained")
	await tap_cell(start);await tap_cell(start)
	game.engine.state.units[0].ap=3;game.refresh();check(game.formation_button.disabled,"disabled below 1 PA")
	game.engine.state.units[0].ap=16;game.engine.state.units[0].morale="routed";game.refresh();check(game.formation_button.disabled,"disabled routed")
	game.selected=8;game.clear_preview();game.refresh();check(not game.formation_button.visible and not game.formation_label.visible,"battery has no formation control")
	game.selected=0;game.engine.state.finished=true;game.refresh();check(not game.formation_button.visible and game.formation_label.visible,"postbattle read only")

func formations081_ui():
	game.close_modal();game.engine.pack.rules.formations.initial="column";game.engine.new_game();game.selected=-1;game.clear_preview();game.map.combat_ttl=0;game.map.feedback_ttl=0;game.map.cancel_interaction();game.ai_enabled=false
	var start=game.engine.unit_cell(game.engine.state.units[0]);game.map.focus=game.map.world(start);game.refresh();await process_frame
	check(game.engine.formation(0)=="column" and game.engine.formation(4)=="column","both camps start column")
	await tap_cell(start)
	check(game.formation_button.visible and not game.formation_button.disabled and game.formation_button.text==game.t("formation_button")%game.t("formation_column"),"central button shows initial column")
	var rect=game.formation_button.get_global_rect()
	check(rect.size.x>=226 and rect.size.y>=49 and rect.position.x>=game.footer.global_position.x+486,"formation touch target enlarged and central")
	check(game.formation_label.visible and game.formation_label.text==game.t("formation_column"),"sheet retains read-only current formation")
	for key in ["undo","rally","assault","entrench","deploy","end_turn","next"]:
		check(not game.actions[key].visible or not rect.intersects(game.actions[key].get_global_rect()),"formation does not overlap "+key)
	await screenshot("1870_v081_bouton_formation")
	await tap(rect.get_center());check(is_instance_valid(game.modal) and find_button(game.modal,game.t("formation_column")).disabled,"large central button opens correct choice")
	await press("close");check(game.engine.state.units[0].ap==16 and game.engine.formation(0)=="column","closing without change free")
	await tap(rect.get_center());await press("formation_line")
	check(game.engine.formation(0)=="line" and game.engine.state.units[0].ap==12 and game.formation_label.text==game.t("formation_line"),"line change central button one PA")
	await tap(rect.get_center());await press("formation_skirmish")
	check(game.formation_button.get_theme_font("font").get_string_size(game.formation_button.text,HORIZONTAL_ALIGNMENT_LEFT,-1,18).x+24<=game.formation_button.size.x,"longest button text fits")
	game.engine.state.units[0].entrenched=true;game.engine.state.units[0].morale="shaken";game.refresh()
	check(game.actions.rally.visible and not game.formation_button.get_global_rect().intersects(game.actions.rally.get_global_rect()),"rally and formation accessible together")
	await screenshot("1870_v081_formation_ralliement")

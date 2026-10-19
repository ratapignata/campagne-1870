extends "res://tests/test_ai_compat0833.gd"
var sound_events=[]
func _initialize():call_deferred("run")
func content(game):
	var result=""
	for n in game.modal_box.find_children("*","RichTextLabel",true,false):result+=n.text
	return result
func run():
	root.size=Vector2i(1280,720)
	var game=load("res://main.tscn").instantiate();root.add_child(game);game.ai_enabled=false;game.music_player.stop();game.sound_enabled=false
	game.scenario_choice="v42_lot8";game.show_camp_choice();await process_frame
	check(game.saved_scenario("v42_lot8").is_empty(),"new V42 menu has no invalid legacy lookup")
	game.new_game(0);game.ai_enabled=false;game.music_player.stop();var e=game.engine
	check(e.state.units.size()==95 and game.active_scenario()=="v42_lot8","menu loads isolated V42 scenario")
	game.has_save=false
	check(not game.saved_scenario("v42_lot8").is_empty(),"existing V42 save found from another scenario")
	check(game.saver.path=="user://save_v42_lot8.json","V42 has separate save slot")
	for u in e.state.units:
		check(game.texts.has(u.name_key) and game.texts.has(str(u.name_key)+"_short"),"readable unit name "+str(u.id))
	var supply_button=false
	for b in game.find_children("*","Button",true,false):
		if b.text.contains("Carte ravit"):supply_button=true
	check(not supply_button,"supply map button removed")
	var depot=e.pack.rules.support.supply_sources[0][0]
	game.on_cell(e.index(Vector2i(int(depot[0]),int(depot[1]))))
	check(game.map.supply_overlay_source==0 and not game.map.supply_overlay_cells.is_empty(),"supply wagon opens coverage without footer button")
	game.on_cell(e.index(Vector2i(int(depot[0]),int(depot[1]))))
	check(game.map.supply_overlay_source==-2,"second wagon activation hides coverage")
	e.apply_losses(0,17);e.apply_losses(34,23);e.end_side();e.end_side()
	game.show_journal();await process_frame;var journal=content(game)
	check(journal.contains("Fin T1") and journal.contains("17") and not journal.contains("23"),"journal history with enemy losses hidden")
	e.state.human_side=1;game.show_journal();await process_frame;journal=content(game)
	check(journal.contains("23") and not journal.contains("17"),"opposite human camp has symmetric fog masking")
	e.state.finished=true;game.show_journal();await process_frame;journal=content(game)
	check(journal.contains("17") and journal.contains("23"),"finished battle reveals totals")
	e.state.finished=false;e.state.human_side=0;game.close_modal()
	game.map.fire_sound.connect(func(cannon,reaction):sound_events.append([cannon,reaction]))
	for cannon in [false,true]:
		var event=e.combat_event(0,34,"fire");event.reaction=true;event.reaction_cannon=not cannon
		game.map.animate_fire(event,"Test",cannon);check(game.map.busy(),"animation starts")
		game.map._process(game.map.combat_duration*0.4)
		check(sound_events[-1]==[not cannon,true],"reaction sound synchronized")
		game.map._process(2.0);check(not game.map.busy(),"animation completes")
	check(sound_events.size()==4,"one attack and reaction sound per animation")
	game.queue_free();await process_frame
	print("LOT8 UI ",checks-failures,"/",checks);quit(1 if failures else 0)

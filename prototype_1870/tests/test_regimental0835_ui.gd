extends SceneTree
var checks=0
var failures=0
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL "+label)
func _initialize():call_deferred("run")
func run():
	root.size=Vector2i(1280,720)
	var game=load("res://main.tscn").instantiate();root.add_child(game);game.ai_enabled=false;game.music_player.stop();game.sound_enabled=false
	await process_frame
	game.scenario_choice="historical";game.show_camp_choice();await process_frame
	var buttons=game.modal_box.find_children("*","Button",true,false);var good=true
	for b in buttons:
		good=good and game.modal_box.get_global_rect().encloses(b.get_global_rect())
		for other in buttons:
			if b!=other:good=good and not b.get_global_rect().intersects(other.get_global_rect())
	check(good,"three scenario buttons fit without overlap")
	for side in [0,1]:
		game.scenario_choice="historical";game.new_game(side);game.ai_enabled=false
		var e=game.engine
		check(game.active_scenario()=="historical" and e.state.human_side==side,"new historical trial camp "+str(side))
		check(e.validate(e.state) and e.state.units.size()==81 and e.pack.map.tiles.size()==600,"valid 600 tile scenario")
		check(e.objective_definitions().size()==3 and e.pack.rules.turns==18,"3 objectives 18 turns")
		check(game.saver.path=="user://save_regimental0835.json","separate save")
		var own=0 if side==0 else 34
		check("QG" in game.unit_heading(own),"HQ name in infantry title")
		for n in range(e.state.units.size()):
			if e.alive(n) and e.cavalry(n) and int(e.state.units[n].side)==side:check("QG" in game.unit_heading(n),"HQ name in cavalry title")
		var supported=true
		for n in range(e.state.units.size()):
			if e.alive(n):supported=supported and e.state.units[n].command_ok and e.state.units[n].supply_ok
		check(supported,"all forces initially commanded and supplied")
		if side==1:e.end_side()
		var cannon=-1
		for n in range(e.state.units.size()):
			if e.alive(n) and int(e.state.units[n].side)==side and e.artillery(n):cannon=n;break
		game.on_cell(e.unit_cell(e.state.units[cannon]));check(game.selected==cannon,"cannon selectable")
		check(e.toggle_deployment(cannon),"cannon deploys");game.refresh();check(not game.map.fire_cells.is_empty(),"fire overlay on historical terrain")
		game.persist();var saved=game.saved_scenario("historical");check(not saved.is_empty() and saved.engine.state==e.state,"save roundtrip")
	game.scenario_choice="classic";game.new_game(0);game.ai_enabled=false
	check(game.active_scenario()=="classic" and game.saver.path=="user://save_classic_v0835.json","classic unaffected")
	game.scenario_choice="three";game.new_game(0);game.ai_enabled=false
	check(game.active_scenario()=="three" and game.saver.path=="user://save_three_v0835.json","three objectives unaffected")
	game.scenario_choice="historical";game.resume_scenario();game.ai_enabled=false
	check(game.active_scenario()=="historical" and game.engine.state.human_side==1,"resume trial after other scenarios")
	game.playing=false;game.queue_free();await process_frame
	var reopened=load("res://main.tscn").instantiate();root.add_child(reopened);reopened.ai_enabled=false;reopened.music_player.stop();await process_frame
	check(reopened.has_save and reopened.active_scenario()=="historical" and reopened.engine.state.human_side==1,"restart loads trial")
	reopened.playing=false;reopened.queue_free();await process_frame
	# Audio playback is retired asynchronously by AudioServer after node deletion.
	await create_timer(0.1).timeout
	print("REGIMENTAL UI 0835 ",checks-failures,"/",checks);call_deferred("quit",1 if failures else 0)

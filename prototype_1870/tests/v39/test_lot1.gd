extends "res://tests/test_ai_compat0833.gd"
const Map=preload("res://war_engine/presentation/map_view.gd")
const Cartography=preload("res://war_engine/presentation/cartography.gd")
func _initialize():call_deferred("run")
func run():
	var raw=FileAccess.get_file_as_string("res://packs/1870/regimental_trial.json");var p=JSON.parse_string(raw)
	var e=Rules.new(p);e.new_game(0,"normal")
	check(e.state.ai_difficulty=="medium","Normal uses unchanged medium ID")
	for alias in ["easy","Facile","medium","Moyen","NORMAL"]:
		e.new_game(0,alias);check(e.state.ai_difficulty=="medium","Normal mapping "+alias)
	for alias in ["hard","Difficile"]:
		e.new_game(0,alias);check(e.state.ai_difficulty=="hard","Hard mapping "+alias)
	check(p.rules.turns==20 and p.rules.minutes==30 and p.rules.start_hour==8,"20 half-hour turns")
	e.new_game(0,"medium")
	for k in range(36):e.end_side()
	check(e.state.turn==19 and not e.state.finished,"continues after turn 18")
	for k in range(4):e.end_side()
	check(e.state.turn==20 and e.state.finished and e.validate(e.state),"ends at turn 20 with valid state")
	check(8+20*30/60==18,"end time 18:00")
	e.state.scores=[20*int(e.objective_value_total()),0]
	var result=e.result_for(0)
	check(is_equal_approx(result.parts[0][1],20.0),"full duration remains 20 points")
	check(p.rules.victory.final_control==60 and p.rules.victory.military==20 and p.rules.victory.duration==20,"60/20/20 unchanged")
	var save=Store.new("user://lot1.json",raw.sha256_text(),p.save_migrations);check(save.save_game(e),"save final 20-turn battle")
	var copy=Rules.new(p);check(save.load_game(copy),"save loads")
	check(JSON.parse_string(JSON.stringify(copy.state))==JSON.parse_string(JSON.stringify(e.state)),"save roundtrip, JSON numeric representation")
	# Actual delivered V37/V38 save uses the unchanged V38 scenario fingerprint.
	var old=Store.new("res://tests/results/0837/full_final_save.json",raw.sha256_text(),p.save_migrations)
	check(old.load_game(copy),"actual old completed save imported")
	check(copy.state.finished and copy.battle_turn_limit()==18,"completed old battle stays completed with old denominator")
	var old_hash=p.save_migrations.keys()[0]
	var old_save=Store.new("user://lot1_old.json",old_hash);e.new_game(0,"medium");e.state.turn=11;e.state.ai_difficulty="easy"
	check(old_save.save_game(e),"create old ongoing slot")
	var migrated=Store.new(old_save.path,raw.sha256_text(),p.save_migrations)
	check(migrated.load_game(copy) and copy.state.turn==11 and copy.battle_turn_limit()==20 and copy.state.ai_difficulty=="medium","ongoing old game migrates to Normal and 20 turns")
	var map=Map.new();map.engine=e;map.size=Vector2(1280,448);var curve=Cartography.river_curve(map);var before=JSON.stringify(p)
	for z in [.42,.72,1.18,2.3]:
		map.zoom=z;map.focus=curve.sample_baked(curve.get_baked_length()/2)
		var fs=clampi(int(23*z),20,38);var width=map.RIVER_FONT.get_string_size("Sauer",HORIZONTAL_ALIGNMENT_LEFT,-1,fs).x/z
		var centers=Cartography.name_centers(map,curve,width)
		check(centers.size()==2,"two visible river labels at zoom "+str(z))
		check(centers.size()<2 or centers[1]-centers[0]>width,"labels do not overlap")
	check(before==JSON.stringify(p),"map geometry unchanged");map.free()
	root.size=Vector2i(1280,720)
	var game=load("res://main.tscn").instantiate();root.add_child(game);game.ai_enabled=false;game.music_player.stop();game.sound_enabled=false
	game.show_camp_choice();var levels=[]
	for b in game.modal_box.find_children("*","Button",true,false):
		if b.text in ["NORMAL","DIFFICILE","Facile","Moyen"]:levels.append(b.text)
	check(levels==["NORMAL","DIFFICILE"],"only two difficulty buttons")
	game.engine=e;game.map.engine=e;e.state.turn=20;game.refresh()
	check(game.score_label.text.contains("20 / 20") and game.score_label.text.contains("17:30"),"turn 20 HUD")
	e.state.finished=true;game.refresh();check(game.score_label.text.contains("18:00"),"final clock")
	game.queue_free();await process_frame
	print("V39 LOT1 ",checks-failures,"/",checks);quit(1 if failures else 0)

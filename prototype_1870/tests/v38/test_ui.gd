extends "res://tests/test_ai_compat0833.gd"
func _initialize():call_deferred("run")
func run():
	root.size=Vector2i(1280,720)
	var game=load("res://main.tscn").instantiate();root.add_child(game);game.ai_enabled=false;game.music_player.stop();game.sound_enabled=false;game.close_modal()
	var p=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial.json"));var e=Rules.new(p);e.new_game(0,"medium");game.engine=e;game.map.engine=e
	e.state.turn=18;e.state.finished=true
	e.state.battle_history=[{"kind":"capture","turn":3,"side":1,"objective":"froeschwiller"},{"kind":"surrender","turn":4,"side":0,"unit":e.state.units[0].id,"prisoners":300}]
	game.show_result();await process_frame
	var details=false;var details_rect=Rect2();var others=[]
	for b in game.modal_box.find_children("*","Button",true,false):
		if b.text==game.t("battle_details"):details=true;details_rect=b.get_global_rect()
		else:others.append(b.get_global_rect())
	check(details,"end report has details button")
	var fits=details_rect.size.y>=44
	for rect in others:
		if details_rect.intersects(rect):fits=false
	check(fits,"details touch target is at least 44 pixels and does not overlap existing buttons")
	game.show_battle_details();await process_frame
	var content=""
	for node in game.modal_box.find_children("*","RichTextLabel",true,false):content+=node.text
	check(content.contains("Tour 3") and content.contains("Tour 4") and content.contains("300 prisonniers"),"objective chronology and capitulation shown")
	check(content.contains(game.t("goal_historical_froeschwiller")),"named objectives shown")
	e.state.erase("battle_history");game.show_battle_details();await process_frame;content=""
	for node in game.modal_box.find_children("*","RichTextLabel",true,false):content+=node.text
	check(content.contains(game.t("battle_details_legacy")),"legacy save report openly states missing history")
	check(game.t("isolation_count").contains("retraite légale"),"isolation help states conditional surrender")
	check(game.t("command_effect_strict").contains("3 PA") and game.t("command_effect_strict").contains("2 PA"),"strict support help explains AP ceilings")
	e=Rules.new(JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/prototype.json")));e.state.finished=true;game.engine=e;game.map.engine=e
	game.show_battle_details();await process_frame;content=""
	for node in game.modal_box.find_children("*","RichTextLabel",true,false):content+=node.text
	check(content.contains(game.t("objective")),"legacy single objective without name key has safe fallback")
	e.state.finished=false;game.close_modal();game.show_battle_details();check(game.modal==null,"battle history cannot be opened during ongoing battle")
	game.queue_free();await process_frame;game=null;e=null
	print("V38 UI ",checks-failures,"/",checks);call_deferred("quit",1 if failures else 0)

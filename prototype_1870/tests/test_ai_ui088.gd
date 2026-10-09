extends "res://tests/test_formation_button_ui.gd"
const Rules088=preload("res://war_engine/core/engine.gd")
const Store088=preload("res://war_engine/platform/save_store.gd")
func run():
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute("user://save_v086.json"+suffix)
	var raw=FileAccess.get_file_as_string("res://packs/1870/prototype.json");var old=Rules088.new(JSON.parse_string(raw));old.state.erase("ai_difficulty");old.state.erase("ai_style");old.state.units[0].ap=9
	var store=Store088.new("user://save_v086.json",raw.sha256_text());store.save_game(old)
	game=load("res://main.tscn").instantiate();game.prefs_path="user://ai_ui088.cfg";root.add_child(game);game.ai_enabled=false
	await process_frame
	check(game.has_save and game.engine.state.ai_difficulty=="legacy" and game.engine.state.units[0].ap==9,"existing 087 save continues with previous AI and preserved PA")
	game.show_camp_choice();await process_frame
	check(game.difficulty_choice=="medium","medium selected by default")
	for difficulty in ["easy","medium","hard"]:
		await press("difficulty_"+difficulty)
		check(game.difficulty_choice==difficulty,"touch selects "+difficulty)
		check(game.engine.state.ai_difficulty=="legacy","selection does not alter current saved battle")
		for other in ["easy","medium","hard"]:
			var b=find_button(game,game.t("difficulty_"+other));check(b!=null and b.size.y>=48,"large difficulty touch target "+other)
	await screenshot("1870_v088_choix_ia")
	await press("choose_france")
	check(game.engine.state.ai_difficulty=="hard" and game.engine.state.human_side==0 and game.playing,"camp confirmation starts hard battle")
	var restart=load("res://main.tscn").instantiate();restart.prefs_path="user://ai_ui088.cfg";root.add_child(restart);restart.ai_enabled=false
	check(restart.has_save and restart.engine.state==game.engine.state and restart.difficulty_choice=="hard","restart restores exact battle and chosen difficulty")
	for player in [restart.music_player,restart.sound_player,restart.reaction_player,restart.assault_player]:player.stop();player.stream=null
	restart.queue_free();await process_frame
	game.show_menu();await screenshot("1870_v088_menu");game.resume()
	game.ai_enabled=true;game.end_side();game._process(1.0)
	check(game.ai_thread!=null,"AI thinking starts on worker thread")
	var before=game.engine.state.duplicate(true);game.show_menu()
	await create_timer(0.8).timeout
	check(game.engine.state==before,"menu pauses commands while worker finishes")
	game.difficulty_choice="easy";game.new_game(0);game.ai_enabled=false
	var fresh=game.engine.state.duplicate(true);await create_timer(0.4).timeout
	check(game.engine.state==fresh and game.engine.state.ai_difficulty=="easy","new battle discards old pending AI decision")
	game.difficulty_choice="hard";game.new_game(1);game.ai_enabled=true;game._process(1.0);game.app_suspended=true
	var suspended=game.engine.state.duplicate(true);await create_timer(0.8).timeout
	check(game.engine.state==suspended,"application suspension applies no AI commands")
	game.app_suspended=false
	var frames=0
	while game.engine.state==suspended and frames<180:await process_frame;frames+=1
	check(game.engine.state!=suspended,"AI resumes and executes a command")
	game.ai_enabled=false;game.playing=false;game.set_process(false)
	for player in [game.music_player,game.sound_player,game.reaction_player,game.assault_player]:player.stop();player.stream=null
	await create_timer(0.3).timeout;game.queue_free();await process_frame;await process_frame;game=null
	print("AI UI 088: %d / %d passed"%[checks-failures,checks]);quit(1 if failures else 0)

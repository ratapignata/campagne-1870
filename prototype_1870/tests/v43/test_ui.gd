extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const Store=preload("res://war_engine/platform/save_store.gd")
var checks=0
var failures=0
var sounds=[]
func check(ok:bool,what:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",what)
func scene():
 var game=load("res://main.tscn").instantiate();root.add_child(game);game.ai_enabled=false;game.music_player.stop();game.sound_enabled=false;return game
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(1280,720);var game=scene()
 check(game.active_scenario()=="v43" and game.scenario_choice=="v43","V43 is the default current prototype")
 game.show_camp_choice();await process_frame;var labels=[]
 for node in game.modal_box.find_children("*","Button",true,false):
  labels.append(node.text)
  check(not node.text.contains("V42") and not node.text.contains("Classique") and not node.text.contains("Facile"),"obsolete prototype/difficulty not offered")
 check(labels.has(game.t("difficulty_medium")) and labels.has(game.t("difficulty_hard")),"Normal and Difficile remain available")
 for side in [0,1]:
  game.new_game(side);game.ai_enabled=false;game.music_player.stop();var e=game.engine
  check(e.pack.id=="regimental_trial_v43" and e.state.units.size()==95 and e.state.human_side==side,"current V43 scenario starts for each camp")
  check(e.pack.rules.turns==20 and e.pack.rules.assault.infantry_strength_exponent==0.9 and e.validate(e.state),"20 turns, variant B and valid initial state")
  check(game.saver.path=="user://save_v43.json","V43 save independent of archived V42")
  var tir=false
  for b in game.find_children("*","Button",true,false):
   if b.text.strip_edges().to_upper()=="TIRER":tir=true
  check(not tir,"no TIRER button")
 game.map.fire_sound.connect(func(cannon,reaction):sounds.append([cannon,reaction]))
 for cannon in [true,false]:
  var e=game.engine;var event=e.combat_event(0,34,"fire");event.reaction=true;event.reaction_cannon=not cannon
  game.map.animate_fire(event,"Test",cannon);check(is_equal_approx(game.map.combat_duration,1.15*(0.6 if int(e.state.side)!=int(e.state.human_side) else 1.0)),"existing shot/reaction total duration unchanged")
  game.map._process(game.map.combat_duration*0.4);check(sounds[-1]==[not cannon,true],"unchanged defensive reaction animation and sound")
  game.map._process(2.0);check(not game.map.busy(),"animation ends normally")
 check(sounds.size()==4,"one shot and one reaction sound each")
 game.playing=false;game.queue_free();await process_frame
 # Force an old preference and a physical V42 save, then exercise the real application restart migration.
 var old_raw=FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v42_lot8.json");var old=Rules.new(JSON.parse_string(old_raw));old.new_game(1,"hard");old.state.seed=187037;old.end_side();old.end_side()
 var old_store=Store.new("user://save_v42_lot8.json",old_raw.sha256_text());check(old_store.save_game(old),"physical V42 Lot 8 save created")
 var prior=FileAccess.get_file_as_string(old_store.path)
 for suffix in ["",".bak"]:
  if FileAccess.file_exists("user://save_v43.json"+suffix):DirAccess.remove_absolute("user://save_v43.json"+suffix)
 var prefs=ConfigFile.new();prefs.set_value("game","scenario","v42_lot8");prefs.save("user://preferences.cfg")
 game=scene()
 check(game.has_save and game.active_scenario()=="v43" and game.engine.state.ai_difficulty=="hard" and game.engine.state.human_side==1,"actual startup upgrades V42 to V43 with camp and difficulty preserved")
 check(JSON.parse_string(JSON.stringify(game.engine.state))==JSON.parse_string(JSON.stringify(old.state)),"actual migration preserves all saved state")
 check(FileAccess.get_file_as_string(old_store.path)==prior,"V42 save remains byte-identical")
 game.playing=false;game.queue_free();await process_frame
 var f=FileAccess.open("user://ui_v43_report.json",FileAccess.WRITE);f.store_string(JSON.stringify({"checks":checks,"failures":failures},"\t"));f.close()
 print("V43 UI ",checks-failures,"/",checks);quit(1 if failures else 0)

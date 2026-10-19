extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
var failures=0
var checks=0
func check(ok: bool,label: String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL: "+label)
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(1280,720)
 var game=load("res://main.tscn").instantiate();root.add_child(game);game.ai_enabled=false;game.sound_enabled=false;game.music_enabled=false;game.music_player.stop()
 await process_frame
 var p=game.engine.pack.duplicate(true)
 p.objectives=[{"id":"a","name_key":"test_goal_a","cell":[4,4],"points":3},{"id":"b","name_key":"test_goal_b","cell":[12,4],"points":2},{"id":"c","name_key":"test_goal_c","cell":[20,4],"points":1}]
 game.engine=Rules.new(p);game.map.engine=game.engine;game.texts.test_goal_a="Objectif A";game.texts.test_goal_b="Objectif B";game.texts.test_goal_c="Objectif C"
 game.selected=-1
 for o in game.engine.objective_definitions():
  game.inspected=game.engine.objective_cell(o);game.show_terrain_info()
  check(game.unit_label.text.begins_with(game.t(o.name_key)),"objective name "+o.id)
 game.map.queue_redraw();await process_frame
 check(game.map.engine.objective_definitions().size()==3,"map receives all three objectives")
 game.engine.state.finished=true;game.show_result();await process_frame
 var labels=game.find_children("*","Label",true,false);var duration_found=false
 for entry in labels:
  if entry.text.contains("/ 60 points"):duration_found=true
 check(duration_found,"result uses actual weighted duration maximum")
 var legacy_raw=FileAccess.get_file_as_string("res://packs/1870/legacy0818.json")
 var store=preload("res://war_engine/platform/save_store.gd").new("user://multi_legacy0818.json",legacy_raw.sha256_text())
 var legacy=Rules.new(JSON.parse_string(legacy_raw));legacy.state.erase("objective_owners")
 check(store.save_game(legacy),"original v0818 state written")
 check(store.load_game(legacy),"original v0818 state restored with original pack")
 print("MULTI UI: ",checks," checks, ",failures," failures (headless)")
 game.queue_free();await process_frame
 quit(1 if failures else 0)

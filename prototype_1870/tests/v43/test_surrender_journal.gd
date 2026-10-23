extends SceneTree
const Store=preload("res://war_engine/platform/save_store.gd")
const Rules=preload("res://war_engine/core/engine.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func run():
 var game=load("res://main.tscn").instantiate();root.add_child(game);game.ai_enabled=false;game.sound_enabled=false;game.music_player.stop();game.new_game(0);game.ai_enabled=false;game.music_player.stop();var e=game.engine
 var own=e.unit_index("fr_1");var seen=e.unit_index("pru_55");var hidden=e.unit_index("pru_57")
 for n in [seen,hidden]:
  var u=e.state.units[n];u.pending=false;u.strength=u.initial_strength;u.casualties=0;u.prisoners=0;u.ap=16;u.done=false
 for pos in e.neighbours(e.unit_cell(e.state.units[own])):
  if e.unit_at(pos)<0:
   e.state.units[seen].cell=[e.cell(pos).x,e.cell(pos).y];break
 e.state.units[hidden].cell=[29,19];e.refresh_intel()
 check(e.visible_to(0,seen) and not e.visible_to(0,hidden),"visible and hidden fixtures")
 e.surrender(seen);var name=game.t(e.state.units[seen].name_key);var lines=game.surrender_journal_lines()
 check(lines.size()==1 and name in str(lines),"witnessed enemy surrender named immediately")
 check(e.state.support_events[-1].known_names.has("0"),"visibility captured before unit removal")
 e.surrender(hidden);var hidden_name=game.t(e.state.units[hidden].name_key)
 check(hidden_name not in str(game.surrender_journal_lines()),"unseen enemy surrender not leaked")
 e.surrender(own);check(game.t(e.state.units[own].name_key) in str(game.surrender_journal_lines()),"own surrender always present")
 check(game.surrender_journal_lines().size()==2,"history and support duplicates removed")
 var store=Store.new("user://journal.json","journal");var copy=Rules.new(e.pack)
 check(store.save_game(e) and store.load_game(copy),"surrender metadata save roundtrip valid")
 check(copy.state.support_events==e.state.support_events,"visibility metadata retained")
 e.state.finished=true;check(hidden_name in str(game.surrender_journal_lines()) and game.surrender_journal_lines().size()==3,"finished game shows all capitulations")
 for event in e.state.support_events:event.erase("known_names")
 for event in e.state.battle_history:event.erase("known_names")
 check(game.surrender_journal_lines().size()==3,"legacy histories without visibility metadata remain usable at battle end")
 e.state.finished=false;game.show_journal();await process_frame;check(is_instance_valid(game.modal),"journal opens")
 game.playing=false;game.queue_free();await process_frame;print("SURRENDER JOURNAL ",checks-failures,"/",checks);quit(1 if failures else 0)

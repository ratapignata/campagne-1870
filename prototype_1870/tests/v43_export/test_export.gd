extends "res://tests/v43/test_ui.gd"
func _initialize():call_deferred("run_export")
func canonical(value):return JSON.parse_string(JSON.stringify(value))
func run_export():
 root.size=Vector2i(1280,720);var game=scene();game.new_game(0);game.ai_enabled=false;game.music_player.stop();game.persist()
 var before_menu=FileAccess.get_file_as_bytes(game.saver.path)
 var backup_before_menu=FileAccess.get_file_as_bytes(game.saver.path+".bak") if FileAccess.file_exists(game.saver.path+".bak") else PackedByteArray()
 game.show_menu();await process_frame
 check(FileAccess.get_file_as_bytes(game.saver.path)==before_menu,"opening export menu leaves original unchanged")
 var backup_exists=FileAccess.file_exists(game.saver.path+".bak")
 check((FileAccess.get_file_as_bytes(game.saver.path+".bak") if backup_exists else PackedByteArray())==backup_before_menu,"opening export menu does not rotate backup")
 var found=false
 for b in game.modal_box.find_children("*","Button",true,false):
  if b.text=="Exporter la sauvegarde":
   found=true;check(not b.disabled and b.size.y>=44,"export menu button enabled and touch size");check(Rect2(Vector2.ZERO,game.size).encloses(b.get_global_rect()),"export button fits screen")
 check(found,"export menu action present")
 var e=game.engine;var store=game.saver;var original=FileAccess.get_file_as_bytes(store.path);var backup=FileAccess.get_file_as_bytes(store.path+".bak") if FileAccess.file_exists(store.path+".bak") else PackedByteArray()
 # An unsaved setting must be included rather than exporting the stale on-disk slot.
 e.state.seed=430012;e.state.ai_difficulty="hard";e.state.ai_style=1
 var state=canonical(e.state);var previous=canonical(e.previous);var snap=store.export_snapshot(e,{"test":"full-state"});var destination="user://exported_current.json"
 check(not snap.is_empty() and store.export_copy(destination,snap),"JSON export written and verified")
 check(store.read_slot(destination).state==state and store.read_slot(destination).previous==previous,"all current and previous fields serialized exactly")
 var restored=Rules.new(e.pack);var imported=Store.new(destination,store.fingerprint,store.migrations)
 check(imported.load_game(restored) and restored.validate(restored.state),"export reload through real save loader")
 check(canonical(restored.state)==state and canonical(restored.previous)==previous,"round trip preserves complete state, fog, networks, units and AI")
 check(FileAccess.get_file_as_bytes(store.path)==original and FileAccess.get_file_as_bytes(store.path+".bak")==backup,"live save and backup byte identical after export")
 check(canonical(e.state)==state and canonical(e.previous)==previous,"export does not mutate running game")
 for suffix in ["",".bak",".tmp"]:
  check(not store.export_copy(store.path+suffix,snap),"protected destination rejected: "+suffix)
 check(not store.export_copy("user://no-such-directory/out.json",snap),"unwritable destination handled safely")
 check(not store.export_copy("user://bad.json","{}"),"bad snapshot rejected")
 # Actual callback path, cancellation, and Android focus/pause autosave suppression.
 game.export_in_progress=true;game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT);game._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
 check(FileAccess.get_file_as_bytes(store.path)==original and FileAccess.get_file_as_bytes(store.path+".bak")==backup,"Android picker pause/focus cannot rotate original save")
 game._notification(Node.NOTIFICATION_APPLICATION_RESUMED)
 game.complete_save_export(false,PackedStringArray(),0,snap)
 check(not game.export_in_progress and FileAccess.get_file_as_bytes(store.path)==original,"cancel leaves original unchanged")
 game.complete_save_export(true,PackedStringArray(["user://callback_export.json"]),0,snap)
 check(store.read_slot("user://callback_export.json").state==state,"UI completion writes readable export")
 await process_frame
 for text_label in game.modal_box.find_children("*","Label",true,false):
  check(Rect2(Vector2.ZERO,game.size).encloses(text_label.get_global_rect()),"export notice fits smartphone viewport")
 for b in game.modal_box.find_children("*","Button",true,false):
  if b.text=="Retour au menu":b.pressed.emit();break
 check(FileAccess.get_file_as_bytes(store.path)==original and FileAccess.get_file_as_bytes(store.path+".bak")==backup,"closing export notice leaves save and backup unchanged")
 game.export_current_save();await process_frame
 var picker=game.find_children("*","FileDialog",true,false)
 check(picker.size()==1 and picker[0].visible,"real menu action opens desktop save-document picker")
 if picker.size()==1:picker[0].canceled.emit()
 await process_frame
 check(not game.export_in_progress and FileAccess.get_file_as_bytes(store.path)==original,"picker cancellation releases export guard and preserves original")
 # A legal movement produces a genuine undo snapshot and fog changes to preserve.
 game.close_modal();e.state.side=0
 var moved=false
 for n in range(e.state.units.size()):
  if not e.can_act(n):continue
  var reach=e.reach(n)
  for dest in reach.costs:
   if int(dest)==e.unit_cell(e.state.units[n]) or e.unit_at(dest)>=0:continue
   var path=[int(dest)]
   while reach.parents.has(path[0]):path.push_front(reach.parents[path[0]])
   if e.move(n,path) in ["moved","discovered","capture"]:moved=true;break
  if moved:break
 check(moved,"legal game movement for second export")
 snap=store.export_snapshot(e);check(store.export_copy(destination,snap),"post-move current state export")
 state=canonical(e.state);previous=canonical(e.previous);restored=Rules.new(e.pack)
 check(imported.load_game(restored) and canonical(restored.state)==state and canonical(restored.previous)==previous,"post-move fog and undo round trip")
 check(FileAccess.get_file_as_bytes(store.path)==original and FileAccess.get_file_as_bytes(store.path+".bak")==backup,"unsaved movement exported without touching original")
 game.playing=false;game.queue_free();await process_frame
 var f=FileAccess.open("user://export_report.json",FileAccess.WRITE);f.store_string(JSON.stringify({"checks":checks,"failures":failures},"\t"));f.close()
 print("V43 EXPORT ",checks-failures,"/",checks);quit(1 if failures else 0)

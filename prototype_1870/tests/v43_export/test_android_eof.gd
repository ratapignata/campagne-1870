extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const Store=preload("res://war_engine/platform/save_store.gd")
class EOFFile:
 extends RefCounted
 var inner
 var corrupt=false
 func store_string(s):inner.store_string(s.substr(0,20) if corrupt else s)
 func flush():inner.flush()
 func get_error():return ERR_FILE_EOF
 func close():inner.close()
class AndroidStore:
 extends "res://war_engine/platform/save_store.gd"
 var corrupt=false
 func open_export_file(location:String):
  var handle=FileAccess.open(location,FileAccess.WRITE)
  if handle==null:return null
  var wrapped=EOFFile.new();wrapped.inner=handle;wrapped.corrupt=corrupt;return wrapped
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 var pack=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json"));var e=Rules.new(pack);e.new_game(0,"hard")
 var store=AndroidStore.new("user://save_v43.json","android-eof")
 check(store.save_game(e),"initial save")
 check(store.save_game(e),"backup created")
 var before=FileAccess.get_file_as_bytes(store.path);var backup=FileAccess.get_file_as_bytes(store.path+".bak");var state=e.state.duplicate(true)
 var snapshot=store.export_snapshot(e,{"test":"Android EOF at end of successful write"})
 check(store.export_copy("user://export_eof.json",snapshot),"EOF from a completed write succeeds after read-back")
 var copy=Rules.new(pack);var exported=Store.new("user://export_eof.json","android-eof")
 check(exported.load_game(copy) and JSON.stringify(copy.state)==JSON.stringify(e.state),"full exported game reloads identically")
 store.corrupt=true
 check(not store.export_copy("user://truncated.json",snapshot),"EOF with truncated content rejected")
 check(not store.export_copy(store.path,snapshot),"original destination rejected")
 check(not store.export_copy(store.path+".bak",snapshot),"backup destination rejected")
 check(FileAccess.get_file_as_bytes(store.path)==before and FileAccess.get_file_as_bytes(store.path+".bak")==backup,"original and backup byte-identical after success and failure")
 check(e.state==state,"live game unchanged")
 print("ANDROID EXPORT EOF ",checks-failures,"/",checks);quit(1 if failures else 0)

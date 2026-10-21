extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const Save=preload("res://war_engine/platform/save_store.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func canonical(value):return JSON.parse_string(JSON.stringify(value))
func _initialize():
 var outer=JSON.parse_string(FileAccess.get_file_as_string(OS.get_cmdline_user_args()[0]));var raw=FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json");var p=JSON.parse_string(raw);var e=Rules.new(p)
 e.state=outer.state if outer.has("state") else JSON.parse_string(outer.payload).state;e.normalize()
 check(e.validate(e.state) and e.state.units.size()==95 and e.state.turn==12,"late 95-unit T12 state valid")
 var slot=Save.new("user://late_original.json",raw.sha256_text(),p.get("save_migrations",{}))
 check(slot.save_game(e) and slot.save_game(e),"late original and backup created")
 var original=FileAccess.get_file_as_bytes(slot.path);var backup=FileAccess.get_file_as_bytes(slot.path+".bak")
 var cuts=0
 for u in e.state.units:
  if u.strength>0 and not u.command_ok and not u.supply_ok:cuts+=1
 check(cuts>0 and not e.state.contacts[0].is_empty() and not e.state.loss_history.is_empty(),"fixture contains double cut, fog contacts and chronological loss history")
 e.state.ai_style=1-int(e.state.ai_style);var before=canonical(e.state)
 check(slot.export_copy("user://late_export.json",slot.export_snapshot(e)),"late current unsaved state exported")
 var copy=Rules.new(p);var imported=Save.new("user://late_export.json",raw.sha256_text(),p.get("save_migrations",{}))
 check(imported.load_game(copy) and copy.validate(copy.state),"late export reload valid")
 check(canonical(copy.state)==before,"all late battle state round trips exactly")
 check(FileAccess.get_file_as_bytes(slot.path)==original and FileAccess.get_file_as_bytes(slot.path+".bak")==backup,"late original and backup unchanged byte for byte")
 var f=FileAccess.open("user://late_export_report.json",FileAccess.WRITE);f.store_string(JSON.stringify({"checks":checks,"failures":failures,"double_cut_units":cuts,"turn":e.state.turn,"units":e.state.units.size()},"\t"));f.close()
 print("LATE EXPORT ",checks-failures,"/",checks);quit(1 if failures else 0)

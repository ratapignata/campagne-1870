extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const Store=preload("res://war_engine/platform/save_store.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 for version in ["01","02","03"]:verify(version)
 print("PREVIOUS EXPERIMENT SAVES ",checks-failures,"/",checks);quit(1 if failures else 0)
func verify(version: String):
 var location="res://tests/graphics/fixtures/essai"+version+"_slot.json"
 var raw=FileAccess.get_file_as_string(location);var before=raw.sha256_text()
 var pack=FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json")
 var old=Store.new(location,pack.sha256_text());var data=old.read_slot(location)
 check(not data.is_empty(),"real prior experimental save is readable")
 if data.is_empty():return
 var engine=Rules.new(JSON.parse_string(pack))
 check(old.load_game(engine),"experimental 04 loads prior save")
 # normalize() keeps JSON values while converting internal keys/numeric containers.
 check(JSON.parse_string(JSON.stringify({"state":engine.state,"previous":engine.previous}))==data,"all serialized current/undo state fields retained")
 check(engine.validate(engine.state),"loaded state remains valid")
 var copy=Store.new("user://previous_experiment_"+version+"_copy.json",pack.sha256_text())
 check(copy.save_game(engine),"safe new snapshot can be written")
 check(copy.read_slot(copy.path)==data,"read-back preserves the complete old payload")
 check(FileAccess.get_file_as_string(location).sha256_text()==before,"original fixture never overwritten")

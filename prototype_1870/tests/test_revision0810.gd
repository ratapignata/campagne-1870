extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const Store=preload("res://war_engine/platform/save_store.gd")
var checks=0
var failures=0
func check(ok: bool,message: String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL "+message)
func _initialize():
	var raw=FileAccess.get_file_as_string("res://packs/1870/prototype.json")
	var p=JSON.parse_string(raw);p.rules.fog.enabled=false;p.map.tiles.fill("plain")
	var e=Rules.new(p)
	for n in range(e.state.units.size()):check(e.state.units[n].ap==(20 if e.cavalry(n) else 16),"initial AP for unit %d"%n)
	check(e.validate(e.state),"5 PA state validates")
	var bad=e.state.duplicate(true);bad.units[0].ap=20;check(not e.validate(bad),"infantry cannot gain cavalry budget")
	bad=e.state.duplicate(true);bad.units[10].ap=21;check(not e.validate(bad),"cavalry cannot exceed 5 PA")
	var n=10;var start=e.unit_cell(e.state.units[n]);var dest=e.index(Vector2i(10,11))
	check(e.move(n,e.path_to(n,dest))=="moved" and e.state.units[n].ap==18,"cavalry move costs half PA in open ground")
	check(e.undo() and e.state.units[n].ap==20 and e.unit_cell(e.state.units[n])==start,"undo restores 5 PA")
	e.state.units[4].cell=[10,11];e.refresh_intel()
	check(e.assault_cost(n)==8 and e.assault(n,4).status=="ok" and e.state.units[n].ap<=12,"charge remains 2 PA")
	e.end_side();check(e.state.units[11].ap==20,"Prussian next turn receives 5 PA")
	e.end_side();check(e.state.units[10].ap==20,"French next turn receives 5 PA")
	var store=Store.new("user://test0810.json",raw.sha256_text());check(store.save_game(e),"save 5 PA")
	var loaded=Rules.new(p);check(store.load_game(loaded) and loaded.state==e.state,"load 5 PA exactly")
	var old=Rules.new(JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/legacy089.json")))
	check(old.state.units[10].ap==16 and old.validate(old.state),"legacy budget remains 4 PA")
	var view=e.observation(0,[11]);var simulated=Rules.new(view.pack);simulated.state=view.state;check(simulated.max_ap(simulated.unit_index("cavalry_0"))==20,"AI observation retains cavalry budget")
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute("user://test0810.json"+suffix)
	print("REVISION 0810: %d/%d passed"%[checks-failures,checks]);quit(1 if failures else 0)

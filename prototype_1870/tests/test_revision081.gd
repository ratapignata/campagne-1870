extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const Store=preload("res://war_engine/platform/save_store.gd")
var checks=0
var failures=0
func check(ok: bool,msg: String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL: "+msg)
func _initialize():
	var raw=FileAccess.get_file_as_string("res://packs/1870/legacy084.json");var p=JSON.parse_string(raw);var e=Rules.new(p)
	for camp in [0,1]:
		e.new_game(camp)
		for n in range(e.state.units.size()):
			check(e.formation(n)==("none" if e.artillery(n) else "column") and e.state.units[n].ap==16,"initial formation and free full PA camp %d unit %d"%[camp,n])
	var oldraw=FileAccess.get_file_as_string("res://tests/fixtures/prototype08.json");var oldp=JSON.parse_string(oldraw)
	check(oldraw.sha256_text()==p.save_compatibility[0].pack_hash,"08 fingerprint exact")
	check(p.rules.morale==oldp.rules.morale and p.rules.victory==oldp.rules.victory and p.weapons==oldp.weapons,"morale victory and weapons unchanged")
	check(p.rules.formations.types==oldp.rules.formations.types,"formation effects unchanged")
	var old=Rules.new(oldp);old.new_game(1);old.state.units[1].formation="skirmish";old.state.units[2].formation="column";old.state.units[1].entrenched=true
	old.move(0,old.path_to(0,old.index(Vector2i(11,8))))
	var oldstore=Store.new("user://legacy08_081_test.json",oldraw.sha256_text());oldstore.save_game(old)
	var oldbytes=FileAccess.get_file_as_bytes(oldstore.path);var fresh=Rules.new(p);var save=Store.new("user://current081_test.json",raw.sha256_text())
	check(save.import_compatible(fresh,[{"path":oldstore.path,"pack_hash":oldraw.sha256_text()}]),"08 import succeeds")
	check(fresh.state==old.state and fresh.previous==old.previous,"existing 08 formations state and undo untouched")
	check(fresh.formation(0)=="line" and fresh.formation(1)=="skirmish" and fresh.formation(2)=="column","no forced column when continuing")
	check(FileAccess.get_file_as_bytes(oldstore.path)==oldbytes,"original file preserved")
	var again=Rules.new(p);check(save.load_game(again) and again.state==fresh.state,"081 reload exact")
	check(fresh.undo() and fresh.formation(0)=="line","imported undo preserves original line")
	fresh.new_game(0);check(fresh.formation(0)=="column" and fresh.formation(4)=="column","new game resets to column after import")
	save.save_game(fresh);again=Rules.new(p);check(save.load_game(again) and again.state==fresh.state,"new column save exact reload")
	var original=Rules.new(JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/prototype07.json")))
	for u in original.state.units:u.erase("formation")
	fresh.state=original.state.duplicate(true);fresh.normalize();check(fresh.formation(0)=="line" and fresh.formation(8)=="none","pre08 missing formation defaults still line")
	for path in [oldstore.path,save.path]:
		for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(path+suffix)
	print("REVISION081 CHECKS: %d passed / %d"%[checks-failures,checks]);quit(1 if failures else 0)

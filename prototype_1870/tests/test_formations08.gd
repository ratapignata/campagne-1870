extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const Store=preload("res://war_engine/platform/save_store.gd")
const Brain=preload("res://war_engine/ai/tactical_ai.gd")
const Legacy=preload("res://war_engine/ai/legacy_ai.gd")
var checks=0
var failures=0
func check(ok: bool,msg: String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL: "+msg)
func setup(p):
	var e=Rules.new(p.duplicate(true));e.pack.map.tiles.fill("plain")
	for n in range(e.state.units.size()):e.state.units[n].cell=[n*2,18]
	e.state.units[0].cell=[4,4];e.state.units[4].cell=[4,6]
	return e
func damage(e,a=0,b=4):
	var rng=RandomNumberGenerator.new();rng.seed=1870
	return e.shot_loss(a,b,rng)
func _initialize():
	var raw=FileAccess.get_file_as_string("res://tests/fixtures/prototype08.json");var p=JSON.parse_string(raw);var e=setup(p)
	check(e.formation(0)=="line" and e.formation(8)=="none","initial forms")
	var before=e.state.duplicate(true)
	check(not e.change_formation(0,"line") and not e.change_formation(0,"bad") and e.state==before,"same and invalid atomic")
	check(not e.change_formation(4,"column") and not e.change_formation(8,"line") and e.state==before,"enemy and artillery rejected")
	e.state.units[0].morale="routed";check(not e.change_formation(0,"column"),"routed rejected");e.state.units[0].morale="stable"
	e.state.units[0].ap=3;check(not e.change_formation(0,"column") and e.state.units[0].ap==3,"low AP rejected")
	e.state.units[0].ap=16;e.state.units[0].entrenched=true
	check(e.change_formation(0,"column") and e.state.units[0].ap==12,"change costs one AP")
	check(e.state.units[0].entrenched and e.state.units[0].cohesion==100 and e.state.units[0].reactions==1,"change preserves shelter morale reactions")
	var start=e.unit_cell(e.state.units[0]);var dest=e.index(Vector2i(5,4));var route=e.path_to(0,dest)
	check(e.preview(0,dest).cost==3 and e.path_cost(route,0)==3,"column preview three quarters")
	check(e.move(0,route)=="moved" and e.state.units[0].ap==9,"column actual move")
	check(e.undo() and e.state.units[0].ap==12 and e.formation(0)=="column" and e.state.units[0].entrenched,"undo preserves formation and shelter")
	for item in [["road",2],["plain",3],["hill",5],["village",5],["forest",6],["water",-1]]:
		e.pack.map.tiles[dest]=item[0];check(e.movement_cost(0,dest)==item[1],"column terrain "+item[0])
	e.pack.map.tiles[dest]="plain";e.move(0,e.path_to(0,dest));check(e.change_formation(0,"skirmish") and e.previous.is_empty(),"formation clears previous undo")
	e.state.units[0].ap=4;check(e.change_formation(0,"line") and e.state.units[0].done and e.state.units[0].ap==0,"exact AP exhaustion")
	e=setup(p);var baseline=damage(e);e.state.units[0].formation="column";check(damage(e)<baseline,"column weaker fire")
	e.state.units[0].formation="line";e.state.units[4].formation="column";check(damage(e)>baseline,"column exposed")
	e.state.units[4].formation="skirmish";check(damage(e)<baseline,"skirmish protected")
	e.state.units[4].formation="line";e.state.units[0].formation="skirmish";check(damage(e)<baseline,"skirmish weaker fire")
	check(is_equal_approx(e.assault_power(0,false),700.0) and is_equal_approx(e.assault_power(0,true),850.0),"skirmish contact factors")
	check(e.weapon(0).range==3 and e.weapon(4).range==2,"weapon ranges unchanged")
	e.state.units[0].formation="line";e.state.units[4].formation="skirmish"
	var result=e.fire(0,4);check(result.status=="ok" and result.event.reaction and e.state.units[4].reactions==0 and result.event.return_loss>0,"reaction still shared budget")
	e=setup(p);e.state.units[0].cell=[4,5];e.state.units[0].formation="column";result=e.assault(0,4);check(result.status=="ok" and result.event.reaction and result.event.return_loss>0,"assault defensive fire and contact")
	e=setup(p);e.change_formation(0,"skirmish");e.end_side();e.end_side();check(e.formation(0)=="skirmish","formation persists turns")
	var saver=Store.new("user://formation08_test.json",raw.sha256_text());check(saver.save_game(e),"save succeeds")
	var restored=setup(p);check(saver.load_game(restored) and restored.validate(restored.state) and JSON.parse_string(JSON.stringify(restored.state))==JSON.parse_string(JSON.stringify(e.state)),"save exact restore")
	var broken=e.state.duplicate(true);broken.units[0].formation="bad";check(not e.validate(broken),"invalid infantry save rejected")
	broken=e.state.duplicate(true);broken.units[8].formation="line";check(not e.validate(broken),"invalid battery save rejected")
	var oldraw=FileAccess.get_file_as_string("res://tests/fixtures/prototype07.json");check(oldraw.sha256_text()==p.save_compatibility[0].pack_hash,"old exact pack fingerprint")
	var old=Rules.new(JSON.parse_string(oldraw));old.move(0,old.path_to(0,old.index(Vector2i(11,8))));restored=Rules.new(p)
	for u in old.state.units:u.erase("formation")
	for u in old.previous.units:u.erase("formation")
	var legacy=Store.new("user://legacy07_form_test.json",oldraw.sha256_text());legacy.save_game(old)
	var legacy_bytes=FileAccess.get_file_as_string(legacy.path)
	check(saver.import_compatible(restored,[{"path":legacy.path,"pack_hash":oldraw.sha256_text()}]),"legacy import")
	check(restored.formation(0)=="line" and restored.formation(8)=="none" and restored.state.units[0].ap==old.state.units[0].ap,"legacy defaults and AP")
	check(restored.undo() and restored.formation(0)=="line" and restored.state.units[0].ap==16,"legacy undo normalized")
	check(FileAccess.get_file_as_string(legacy.path)==legacy_bytes,"legacy source untouched")
	check(p.weapons[ e.state.units[9].weapon ].base_losses==131,"Krupp slight increase")
	var brain=Brain.new();e=setup(p);e.state.units[0].formation="column";e.state.units[4].cell=[4,5]
	check(Legacy.new().desired_formation(e,0)=="line","AI line at contact")
	e.state.units[4].cell=[24,18];var view=e.observation(0,[]);before=view.duplicate(true);var decision=brain.choose(view)
	check(view==before and decision.has("kind"),"AI observation not mutated")
	for path in [saver.path,legacy.path]:
		for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(path+suffix)
	print("FORMATIONS08 CHECKS: %d passed / %d"%[checks-failures,checks]);quit(1 if failures else 0)

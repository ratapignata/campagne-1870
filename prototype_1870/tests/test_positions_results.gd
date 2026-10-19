extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const Store=preload("res://war_engine/platform/save_store.gd")
var checks=0
var failures=0
func check(ok:bool,msg:String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL: "+msg)
func scene(p):
	var data=p.duplicate(true);data.map.tiles.fill("plain");var e=Rules.new(data)
	for n in range(e.state.units.size()):e.state.units[n].cell=[n*2,18]
	e.state.units[0].cell=[5,5];e.state.units[4].cell=[5,6];e.state.seed=123
	return e
func attrition(e,side,amount,prisoner=false):
	for u in e.state.units:
		if int(u.side)!=side:continue
		var loss=mini(int(u.strength),amount);u.strength-=loss;amount-=loss;u["prisoners" if prisoner else "casualties"]+=loss
func _initialize():
	var raw=FileAccess.get_file_as_string("res://tests/fixtures/prototype08.json");var p=JSON.parse_string(raw);var e=scene(p)
	check(e.entrench(0) and e.state.units[0].ap==8 and e.state.units[0].entrenched,"dig costs two PA")
	var snapshot=e.state.duplicate(true)
	check(not e.entrench(0) and e.state==snapshot,"cannot stack shelter")
	check(not e.entrench(4),"cannot dig enemy unit")
	var before=e.shot_loss(4,0,e.combat_rng());e.state.units[0].entrenched=false
	var exposed=e.shot_loss(4,0,e.combat_rng())
	check(before<exposed and absf(float(before)/exposed-.75)<.02,"shelter reduces fire by 25 percent")
	var power=e.assault_power(0,true);e.state.units[0].entrenched=true
	check(is_equal_approx(e.assault_power(0,true),power*1.25),"shelter increases contact defence")
	check(e.assault_power(0,false)==1000,"shelter gives no attack bonus")
	var shot=e.fire(0,4)
	check(shot.status=="ok" and shot.event.reaction and e.state.units[0].entrenched,"can fire and receive reaction from shelter")
	e=scene(p);e.entrench(0);snapshot=e.state.duplicate(true)
	check(e.move(0,[])!="moved" and e.state==snapshot,"invalid move keeps shelter")
	var path=e.path_to(0,e.index(Vector2i(4,5)))
	check(e.move(0,path)=="moved" and not e.state.units[0].entrenched,"move abandons shelter")
	check(e.undo() and e.state.units[0].entrenched and e.state.units[0].ap==8,"undo restores shelter and PA")
	e.end_side();e.end_side();check(e.state.units[0].entrenched,"shelter persists between turns")
	e.state.units[0].ap=16;var assault=e.assault(0,4)
	check(assault.status=="ok" and not e.state.units[0].entrenched,"assault abandons shelter")
	e=scene(p);e.entrench(0);e.retreat(0);check(not e.state.units[0].entrenched,"retreat abandons shelter")
	e=scene(p);e.entrench(0);e.apply_losses(0,450);check(e.state.units[0].morale=="routed" and not e.state.units[0].entrenched,"rout removes shelter")
	e=scene(p);e.state.units[0].ap=4;check(e.entrench_status(0)=="no_ap" and not e.entrench(0),"insufficient PA")
	e=scene(p);e.state.units[0].morale="routed";check(not e.entrench(0),"routed unit cannot dig")
	e=scene(p);e.pack.map.tiles[e.unit_cell(e.state.units[0])]="bridge";check(e.entrench_status(0)=="terrain","no shelter on bridge")
	e=scene(p);check(e.entrench_status(8)=="limbered","limbered battery cannot dig")
	e.toggle_deployment(8);check(e.entrench(8) and e.state.units[8].ap==4,"deployed battery can dig")
	check(e.toggle_deployment(8) and not e.state.units[8].entrenched,"limber abandons shelter")
	e=scene(p);e.entrench(0);var save=Store.new("user://positions05.json",raw.sha256_text());save.save_game(e);var restored=Rules.new(e.pack)
	check(save.load_game(restored) and restored.state==e.state,"shelter survives exact save reload")
	e.state.finished=true;check(not e.entrench(1),"no digging after battle")
	# Counter-battery reaction: no AP needed, one reaction, posture/range/LOS enforced.
	e=scene(p);e.state.units[8].cell=[12,5];e.state.units[9].cell=[12,8]
	e.state.units[8].deployed=true;e.state.units[9].deployed=true;e.state.units[9].ap=0;e.state.units[9].done=true
	shot=e.fire(8,9)
	check(shot.status=="ok" and shot.event.reaction_cannon and shot.event.reaction and shot.event.return_loss>0,"cannon returns fire with zero PA")
	check(e.reaction_status(9,8)=="spent","one cannon reaction per opposing turn")
	e.end_side();check(e.state.units[9].reactions==0,"reaction not refreshed during own turn")
	e.end_side();check(e.reaction_status(9,8)=="ok","reaction refreshed for next opposing turn")
	e.state.units[9].deployed=false;check(e.reaction_status(9,8)=="limbered","limbered cannon cannot react")
	e.state.units[9].deployed=true;e.state.units[9].cell=[25,8];check(e.reaction_status(9,8)=="range","distant cannon cannot react")
	e.state.units[9].cell=[12,8];e.pack.map.tiles[e.index(Vector2i(12,6))]="forest";check(e.reaction_status(9,8)=="blocked_cover","blocked cannon cannot react")
	# Import actual 0.4 schema, without entrenchment fields; never alter source save.
	var oldraw=FileAccess.get_file_as_string("res://tests/fixtures/prototype04.json");var oldpack=JSON.parse_string(oldraw)
	check(oldraw.sha256_text()==p.save_compatibility[3].pack_hash,"migration fingerprint matches shipped pack")
	var old=Rules.new(oldpack);old.new_game(1);old.end_side();old.state.units[4].reactions=0;old.state.units[4].quiet=false
	for u in old.state.units:u.erase("entrenched")
	var legacy=Store.new("user://legacy04_test.json",oldraw.sha256_text());legacy.save_game(old)
	var oldbytes=FileAccess.get_file_as_bytes("user://legacy04_test.json");var expected=old.state.duplicate(true)
	for u in expected.units:u.entrenched=false
	restored=Rules.new(p);save=Store.new("user://import05_test.json",raw.sha256_text())
	check(save.import_compatible(restored,[{"path":"user://legacy04_test.json","pack_hash":oldraw.sha256_text()}]) and restored.validate(restored.state) and JSON.parse_string(JSON.stringify(restored.state))==JSON.parse_string(JSON.stringify(expected)),"import normalizes shelter while preserving camp turn reactions")
	check(FileAccess.get_file_as_bytes("user://legacy04_test.json")==oldbytes,"source save untouched")
	var resumed=Rules.new(p);check(save.load_game(resumed) and resumed.validate(resumed.state) and JSON.parse_string(JSON.stringify(resumed.state))==JSON.parse_string(JSON.stringify(expected)),"imported save reloads in new format")
	check(not save.import_compatible(resumed,[{"path":"user://legacy04_test.json","pack_hash":"wrong"}]),"wrong historical fingerprint rejected")
	for path_name in ["positions05","legacy04_test","import05_test"]:
		for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute("user://"+path_name+".json"+suffix)
	print("POSITIONS/RESULTS CHECKS: %d passed / %d"%[checks-failures,checks]);quit(1 if failures else 0)

extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const Store=preload("res://war_engine/platform/save_store.gd")
var checks=0
var failures=0
func check(ok:bool,msg:String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL: "+msg)
func fixture(p):
	var e=Rules.new(p);e.pack.map.tiles.fill("plain")
	for n in range(e.state.units.size()):e.state.units[n].cell=[n*2,18]
	e.state.units[8].cell=[4,4];e.state.units[8].deployed=true;e.state.units[4].cell=[4,10]
	return e
func terrain(e,y,key):e.pack.map.tiles[e.index(Vector2i(4,y))]=key
func loss(e,side,amount):
	for u in e.state.units:
		if int(u.side)!=side:continue
		var n=mini(amount,int(u.strength));u.strength-=n;u.casualties+=n;amount-=n
func _initialize():
	var raw=FileAccess.get_file_as_string("res://tests/fixtures/prototype08.json");var p=JSON.parse_string(raw);var e=fixture(p)
	e.state.units[0].cell=[4,7]
	check(e.fire_status(8,4)=="blocked_friendly","flat friendly screen blocks gun")
	var before=e.state.duplicate(true);check(e.fire(8,4).status=="blocked_friendly" and e.state==before,"blocked fire atomic")
	terrain(e,4,"hill");check(e.fire_status(8,4)=="ok","French elevated gun fires above low friends")
	e.state.units[0].cell=[4,9];check(e.fire_status(8,4)=="ok","near target friend safe with configured margin")
	terrain(e,9,"hill");check(e.fire_status(8,4)=="blocked_terrain","crest friend blocks")
	terrain(e,9,"plain");e.pack.rules.line_of_fire.friendly_clearance=0.34
	check(e.fire_status(8,4)=="blocked_friendly","insufficient safe clearance blocks")
	e.pack.rules.line_of_fire.friendly_clearance=0.2;e.pack.rules.line_of_fire.elevated_artillery_overhead=false
	check(e.fire_status(8,4)=="blocked_friendly","overhead option respected")
	e=fixture(p);terrain(e,4,"hill");terrain(e,7,"hill");check(e.fire_status(8,4)=="blocked_terrain","crest masks hidden low target")
	terrain(e,10,"hill");check(e.fire_status(8,4)=="ok","same high target visible over intermediate equal hill")
	e.pack.terrains.lowhill=e.pack.terrains.hill.duplicate(true);e.pack.terrains.lowhill.elevation=1.0;terrain(e,7,"lowhill");terrain(e,10,"plain")
	check(e.fire_status(8,4)=="ok","low crest below direct line clear")
	terrain(e,7,"forest");check(e.fire_status(8,4)=="blocked_cover","forest above line masks target")
	terrain(e,7,"plain");terrain(e,10,"village");check(e.fire_status(8,4)=="ok","target village remains targetable")
	e.state.units[5].cell=[4,7];check(e.fire_status(8,4)=="blocked_unit","intermediate enemy blocks")
	e=fixture(p);e.state.units[0].cell=[4,4];e.state.units[8].cell=[0,18];e.state.units[4].cell=[4,7];e.state.units[1].cell=[4,5];terrain(e,4,"hill")
	check(e.fire_status(0,4)=="blocked_friendly","infantry cannot fire over friends")
	e=fixture(p);e.state.side=1;e.state.units[9].cell=[4,4];e.state.units[9].deployed=true;e.state.units[8].cell=[0,19];e.state.units[4].cell=[4,7];e.state.units[0].cell=[4,10];terrain(e,4,"hill")
	check(e.fire_status(9,0)=="ok","Krupp uses same overhead geometry")
	e.state.side=0;e.state.units[9].ap=0;check(e.reaction_status(9,0)=="ok","cannon reaction uses same geometry without AP")
	terrain(e,4,"plain");check(e.reaction_status(9,0)=="blocked_friendly","level cannon reaction blocked")
	e=Rules.new(p);e.state.finished=true;e.state.owner=0;e.state.scores=[6,0]
	check(e.result_for(0).level=="minor_win" and e.result_for(1).level=="minor_loss","objective alone is minor both perspectives")
	loss(e,1,424);check(e.result_for(0).level=="minor_win","just below ten percent military edge minor")
	loss(e,1,1);check(e.result_for(0).level=="major_win" and e.result_for(1).level=="major_loss","exact ten point military edge major")
	loss(e,0,1);check(e.result_for(0).level=="minor_win","own losses reduce net advantage")
	e=Rules.new(p);e.state.finished=true;e.state.scores=[6,0];loss(e,1,2000)
	check(e.result_for(0).level=="minor_win" and e.result_for(0).reason=="no_objective","military and duration alone cannot give major")
	e.state.owner=0;check(e.result_for(0).level=="major_win","all three conditions give major")
	e=Rules.new(p);e.state.finished=true;e.state.owner=0;e.state.scores=[0,6];loss(e,1,425)
	check(e.result_for(0).level=="minor_win" and e.result_for(0).reason=="score_close","24 point score margin insufficient")
	loss(e,1,107);check(e.result_for(0).level=="major_win","score above twenty five with other conditions major")
	e=Rules.new(p);e.state.finished=true;e.state.owner=1;e.state.scores=[0,6];loss(e,0,425)
	check(e.result_for(1).level=="major_win" and e.result_for(0).level=="major_loss","German victory symmetric")
	before=e.state.duplicate(true);e.result_for(0);check(e.state==before,"result computation pure")
	e=Rules.new(p)
	for u in e.state.units:
		if u.side==1:u.initial_strength*=2;u.strength*=2
	e.state.finished=true;e.state.owner=0;e.state.scores=[6,0];loss(e,0,425);loss(e,1,1700)
	check(e.result_for(0).level=="major_win","unequal armies compare percentages not raw totals")
	var oldraw=FileAccess.get_file_as_string("res://tests/fixtures/prototype06.json")
	check(oldraw.sha256_text()==p.save_compatibility[1].pack_hash,"exact shipped 06 fingerprint")
	var old=Rules.new(JSON.parse_string(oldraw));old.new_game(1);old.state.side=0;old.state.owner=1;old.state.scores=[1,2];old.state.units[1].entrenched=true;old.state.units[4].reactions=0
	old.move(0,old.path_to(0,old.index(Vector2i(11,8))))
	var oldstore=Store.new("user://legacy06_test.json",oldraw.sha256_text());oldstore.save_game(old)
	var bytes=FileAccess.get_file_as_bytes("user://legacy06_test.json");var fresh=Rules.new(p);var save=Store.new("user://current07_test.json",raw.sha256_text())
	check(save.import_compatible(fresh,[{"path":"user://legacy06_test.json","pack_hash":oldraw.sha256_text()}]),"06 save imports")
	check(fresh.state==old.state and fresh.previous==old.previous and not fresh.previous.is_empty(),"migration retains exact state and undo")
	check(FileAccess.get_file_as_bytes("user://legacy06_test.json")==bytes,"original save unchanged")
	var again=Rules.new(p);check(save.load_game(again) and again.state==fresh.state and again.previous==fresh.previous,"07 exact reload")
	check(fresh.undo() and fresh.state==old.previous,"imported undo works")
	for path in ["legacy06_test","current07_test"]:
		for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute("user://"+path+".json"+suffix)
	print("REVISION07 CHECKS: %d passed / %d"%[checks-failures,checks]);quit(1 if failures else 0)

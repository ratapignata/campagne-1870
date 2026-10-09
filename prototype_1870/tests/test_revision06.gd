extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const Store=preload("res://war_engine/platform/save_store.gd")
var checks=0
var failures=0
func check(ok:bool,msg:String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL: "+msg)
func loss(e,side,amount,prisoners=false):
	for u in e.state.units:
		if int(u.side)!=side:continue
		var n=mini(amount,int(u.strength));u.strength-=n;u["prisoners" if prisoners else "casualties"]+=n;amount-=n
func _initialize():
	var raw=FileAccess.get_file_as_string("res://tests/fixtures/prototype08.json");var p=JSON.parse_string(raw);var e=Rules.new(p)
	check(e.result_for(0).level=="pending","pending before finish")
	e.state.finished=true;check(e.result_for(0).level=="draw","no control no losses is draw")
	e.state.owner=0;e.state.scores=[1,4];loss(e,0,979);loss(e,1,1963);loss(e,1,1868,true)
	var before=e.state.duplicate(true);var r=e.result_for(0)
	check(r.level=="major_win" and e.result_for(1).level=="major_loss","supplied example plus final French control reverses old defeat")
	check(is_equal_approx(r.parts[0][0],40.0) and is_equal_approx(r.parts[0][1],20.0/6.0),"objective components correct")
	check(is_equal_approx(r.parts[0][2],40.0*3831.0/4250.0),"military component includes prisoners")
	check(e.state==before,"result evaluation is pure")
	e.state.owner=-1;check(e.result_for(0).level=="minor_win","military advantage can win without final objective in this example")
	e.state.owner=1;check(e.result_for(0).level=="minor_loss","enemy final control can outweigh military advantage")
	e=Rules.new(p);e.state.finished=true;e.state.owner=0;e.state.scores=[0,6]
	check(e.result_for(0).level=="minor_win","late recapture beats full previous duration at equal losses")
	e.state.owner=-1;e.state.scores=[6,0];check(e.result_for(0).level=="minor_win","duration matters when other factors tie")
	e.state.scores=[0,0];loss(e,0,3000);loss(e,1,3000)
	check(e.result_for(0).level=="draw","equal losses preserve draw")
	e=Rules.new(p);e.state.finished=true;e.state.owner=-1;e.state.scores=[0,0]
	e.pack.rules.victory.military=100;loss(e,1,212)
	check(e.result_for(0).level=="draw","below five point gap draw")
	loss(e,1,1);check(e.result_for(0).level=="minor_win","just above five point gap minor")
	loss(e,1,849);check(e.result_for(0).level=="minor_win","just below twenty five point gap minor")
	loss(e,1,1);check(e.result_for(0).level=="minor_win","large score without final objective remains minor")
	e=Rules.new(p);e.state.finished=true
	for u in e.state.units:u.morale="routed"
	check(e.result_for(0).level=="draw","routed survivors not counted as military losses")
	# Ownership persists across evacuation and rout, changing only on valid capture.
	e=Rules.new(p);e.pack.map.tiles.fill("plain");e.state.units[0].cell=[15,8]
	check(e.move(0,e.path_to(0,e.objective()))=="capture" and e.state.owner==0,"capture claims objective")
	check(not e.undo(),"capture remains irreversible")
	e.move(0,e.path_to(0,e.index(Vector2i(14,8))));e.end_side();e.end_side()
	check(e.unit_at(e.objective())==-1 and e.state.owner==0 and e.state.scores==[1,0],"vacated objective retains owner and scores")
	e.state.units[0].morale="routed";e.end_side();e.end_side();check(e.state.owner==0 and e.state.scores==[2,0],"owner's rout elsewhere does not neutralize objective")
	e.state.side=1;e.state.units[4].cell=[15,10]
	check(e.move(4,e.path_to(4,e.objective()))=="capture" and e.state.owner==1,"enemy entry recaptures immediately")
	e.end_side();check(e.state.scores==[2,1],"recaptured objective scores for enemy")
	# Morale boundary is now around 35%, with shock rout separated at 40%.
	e=Rules.new(p);e.apply_losses(0,240);check(e.state.units[0].morale=="stable","24 percent no early disorder or rout")
	e.apply_losses(0,110);check(e.state.units[0].morale=="stable","35 percent boundary remains stable at cohesion 65")
	e.apply_losses(0,10);check(e.state.units[0].morale=="shaken","36 percent accumulated becomes disorganized")
	e.end_side();e.end_side();e.end_side();e.end_side();check(e.state.units[0].morale=="stable","one quiet cycle recovers disorder")
	e=Rules.new(p);e.apply_losses(0,390);check(e.state.units[0].morale=="shaken","39 percent single hit disorganizes without rout")
	e=Rules.new(p);e.apply_losses(0,400);check(e.state.units[0].morale=="routed","40 percent single hit routs")
	# Actual shipped 0.5 fingerprint and state migration, including finished result.
	var oldraw=FileAccess.get_file_as_string("res://tests/fixtures/prototype05.json");check(oldraw.sha256_text()==p.save_compatibility[2].pack_hash,"shipped 05 fingerprint exact")
	var old=Rules.new(JSON.parse_string(oldraw));old.new_game(1);old.state.owner=0;old.state.scores=[1,4];old.state.finished=true;old.state.units[1].entrenched=true;old.state.units[4].reactions=0
	var oldstore=Store.new("user://legacy05_test.json",oldraw.sha256_text());oldstore.save_game(old)
	var bytes=FileAccess.get_file_as_bytes("user://legacy05_test.json");var fresh=Rules.new(p);var save=Store.new("user://current06_test.json",raw.sha256_text())
	check(save.import_compatible(fresh,[{"path":"user://legacy05_test.json","pack_hash":oldraw.sha256_text()}]) and fresh.state==old.state,"05 migration preserves owner scores camp shelter and reaction")
	check(fresh.result_for(1).level=="minor_loss","finished imported battle without military edge remains minor")
	check(FileAccess.get_file_as_bytes("user://legacy05_test.json")==bytes,"05 source save unchanged")
	var again=Rules.new(p);check(save.load_game(again) and again.state==fresh.state,"06 exact reload")
	for path in ["legacy05_test","current06_test"]:
		for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute("user://"+path+".json"+suffix)
	print("REVISION06 CHECKS: %d passed / %d"%[checks-failures,checks]);quit(1 if failures else 0)

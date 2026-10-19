extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const Store=preload("res://war_engine/platform/save_store.gd")
const AI=preload("res://war_engine/ai/tactical_ai.gd")
var checks=0
var failures=0
var data: Dictionary
func check(ok: bool,message: String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL: "+message)
func fixture(fog=false):
	var p=data.duplicate(true);p.rules.fog.enabled=fog;p.map.tiles.fill("plain");p.map.elevations.fill(0)
	var e=Rules.new(p)
	for n in range(e.state.units.size()):e.state.units[n].cell=[n*2,1]
	return e
func put(e,n:int,i:int):e.state.units[n].cell=[e.cell(i).x,e.cell(i).y]
func dispatch(e,d:Dictionary)->bool:
	var n=e.unit_index(str(d.get("unit","")))
	match d.kind:
		"end":e.end_side();return true
		"move":return e.move(n,d.path) in ["moved","capture","discovered"]
		"fire":return e.fire(n,e.unit_index(d.target)).status=="ok"
		"assault":return e.assault(n,e.unit_index(d.target)).status=="ok"
		"formation":return e.change_formation(n,d.formation)
		"rally":return e.rally(n)
		"rest":return e.rest(n)
		"entrench":return e.entrench(n)
		"deploy","limber":return e.toggle_deployment(n)
	return false
func _initialize():
	data=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/legacy0818.json"))
	var e=Rules.new(data)
	check(e.validate(e.state),"initial scenario valid")
	check(e.state.units.size()==12 and e.state.owner==0,"six units per camp and French initial objective")
	var bridges=0
	for edge in data.map.river_edges:
		var a=int(edge.a);var b=int(edge.b)
		check(e.distance(a,b)==1,"river lies on a shared hex boundary")
		if edge.bridge:bridges+=1
		else:
			check(e.edge_allowed(0,a,b) and not e.edge_allowed(8,a,b) and not e.edge_allowed(10,a,b),"every unbridged edge: infantry only")
	check(bridges==1,"one bridge, no engineering")
	var a=349;var b=379
	for fog in [false,true]:
		e=fixture(fog);put(e,0,a);e.refresh_intel()
		var before=e.state.duplicate(true);var cost=e.movement_cost(0,b)+8
		check(e.path_cost([a,b],0)==cost,"ford exact two PA extra")
		check(e.preview(0,b).route==[a,b],"ford preview reaches far bank")
		check(e.move(0,[a,b]) in ["moved","discovered"],"ford legal both fog modes")
		check(e.state.units[0].river_halt and e.state.units[0].ap==16-cost,"halt movement but preserve remaining AP")
		check(e.reach(0).costs.is_empty() and e.move(0,[b,409])=="river_halt","no second movement after crossing")
		var saver=Store.new("user://river0814_"+str(fog)+".json","river-test")
		check(saver.save_game(e),"save crossing")
		var restored=fixture(fog);check(saver.load_game(restored) and restored.state==e.state,"restore exact crossing state")
		check(restored.reach(0).costs.is_empty(),"reloading cannot bypass halt")
		if not fog:check(restored.undo() and JSON.parse_string(JSON.stringify(restored.state))==JSON.parse_string(JSON.stringify(before)),"undo also restores movement permission")
		e.end_side();check(e.state.units[0].river_halt,"enemy turn does not release movement")
		e.end_side();check(not e.state.units[0].river_halt and not e.reach(0).costs.is_empty(),"next own turn releases halt")
		e=fixture(fog);put(e,0,a);e.refresh_intel();before=e.state.duplicate(true)
		check(e.move(0,[a,b,409])=="river" and before==e.state,"reject forged multi-step crossing atomically")
		check(not e.reach(0).parents.has(409) or e.path_to(0,409).size()>3,"reachable routes cannot continue after ford")
		e.state.units[0].ap=cost-1;check(e.move(0,[a,b])=="no_ap","insufficient PA rejected")
	for n in [8,10]:
		e=fixture();put(e,n,a);var before=e.state.duplicate(true)
		check(e.move(n,[a,b])=="river" and before==e.state,"mounted/cannon cannot ford")
		put(e,n,382);var cost=e.movement_cost(n,412)
		check(e.move(n,[382,412])=="moved" and e.state.units[n].ap==e.max_ap(n)-cost and not e.state.units[n].river_halt,"bridge normal cost and no halt")
		check(e.move(n,[412,442])=="moved","movement can continue after bridge")
	e=fixture();put(e,0,a);put(e,4,b)
	check(e.assault_status(0,4)=="river","no assault over unbridged river")
	check(e.fire_status(0,4)=="ok" and e.fire(0,4).event.reaction,"river permits fire and reaction")
	e=fixture();put(e,0,382);put(e,4,412)
	check(e.assault_status(0,4)=="ok","bridge assault remains possible")
	e.state.units[0].river_halt=true;check(e.assault_status(0,4)=="river","crossing halt also prevents assault movement")
	var own=e.observation(0);check(own.state.units[0].river_halt,"own movement status exposed to AI")
	var view=e.observation(1,[0]);var old=JSON.stringify(view);e.state.units[0].river_halt=false
	check(JSON.stringify(e.observation(1,[0]))==old,"enemy crossing status remains private")
	var legacy=Rules.new(JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/legacy0813.json")))
	check(legacy.river_links.is_empty() and legacy.validate(legacy.state),"previous scenario remains supported")
	var ai=AI.new();ai.profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
	if not "--quick" in OS.get_cmdline_user_args():
		for level in ["easy","medium","hard"]:
			e=Rules.new(data);e.new_game(0,level);e.state.seed=123;e.state.ai_style=0
			var count=0;var good=true;var crossings=0;var shots=0;var started=Time.get_ticks_msec()
			while not e.state.finished and count<700:
				count+=1;var d=ai.choose(e.observation(int(e.state.side)))
				if d.kind=="move" and e.path_has_river(d.path):crossings+=1
				if d.kind=="fire":shots+=1
				if not dispatch(e,d) or not e.validate(e.state):printerr("Invalid AI decision ",level," ",d);good=false;break
			check(good and e.state.finished and count<700,"complete legal battle: "+level)
			check(shots>0,"AI battle engages: "+level)
			print("BATTLE ",level," decisions=",count," crossings=",crossings," shots=",shots," milliseconds=",Time.get_ticks_msec()-started," scores=",e.state.scores)
	print("SAUER 0814: ",checks-failures," / ",checks," passed");quit(1 if failures else 0)

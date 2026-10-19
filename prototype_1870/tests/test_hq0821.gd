extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const Store=preload("res://war_engine/platform/save_store.gd")
const AI=preload("res://war_engine/ai/tactical_ai.gd")
const Legacy=preload("res://war_engine/ai/legacy_ai.gd")
var checks=0
var failures=0
func check(ok: bool,msg: String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL "+msg)
func fresh():
	return Rules.new(JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/prototype.json")))
func arena():
	var e=fresh();e.pack.rules.fog.enabled=false;e.pack.map.tiles.fill("plain");e.pack.map.elevations.fill(0);e.river_links={}
	for n in range(e.state.units.size()):e.state.units[n].cell=[28,n]
	e.state.units[12].cell=[5,5];e.state.units[0].cell=[5,4];e.state.units[0].formation="line";e.state.units[4].cell=[5,6];e.state.units[4].formation="line"
	e.refresh_support();return e
func _initialize():
	for name in ["prototype","three_objectives"]:
		var e=Rules.new(JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/"+name+".json")))
		check(e.state.units.size()==14 and e.validate(e.state),name+" two additional QG, valid state")
		for side in [0,1]:
			var n=e.unit_index("hq_"+str(side))
			check(e.headquarters(n) and e.state.units[n].is_hq and e.state.units[n].strength==150 and e.max_ap(n)==16,"QG data side "+str(side))
			check(not e.state.units[0 if side==0 else 4].is_hq,"regiment no longer holds QG")
		var graph={}
		for edge in e.pack.map.road_edges:
			var a=int(edge[0]);var b=int(edge[1]);check(e.distance(a,b)==1 and not e.open_river(a,b),"valid road edge")
			if not graph.has(a):graph[a]=[]
			if not graph.has(b):graph[b]=[]
			graph[a].append(b);graph[b].append(a)
		var todo=[int(e.pack.map.road_edges[0][0])];var seen={todo[0]:true}
		for a in todo:
			for b in graph[a]:
				if not seen.has(b):seen[b]=true;todo.append(b)
		for side in e.pack.rules.support.supply_sources:
			for c in side:check(seen.has(e.index(Vector2i(c[0],c[1]))),"wagon connected to same road network")
	var e=arena();e.state.units[0].cell=[5,5];e.state.units[12].cell=[5,4]
	var reg=e.shot_loss(0,4,e.combat_rng());e.state.units[0].cell=[5,4];e.state.units[12].cell=[5,5]
	var small=e.shot_loss(12,4,e.combat_rng())
	check(small>0 and small<float(reg)*0.20,"QG fire far weaker than regiment")
	check(e.formation_status(12,"column")!="ok","escort has no formation micro-management")
	var r=e.fire(12,4);check(r.status=="ok" and r.event.loss>0 and r.event.reaction and r.event.return_loss>0,"QG shoots and suffers reaction")
	e=arena();e.state.side=1;e.state.units[12].ap=0;e.state.units[12].done=true
	r=e.fire(4,12);check(r.status=="ok" and r.event.reaction and r.event.return_loss>0 and r.event.return_loss<r.event.loss,"QG defends by weak reaction even without PA")
	e=fresh();e.state.units[12].morale="routed";e.refresh_support()
	check(not e.state.units[0].command_ok and e.state.units[0].command_reason=="no_hq" and e.state.command_hq.sauer_test_0=="hq_0","routed QG cuts command, never transfers to regiment")
	check(e.rally(12) and e.state.units[0].command_ok,"actual QG rally immediately restores command")
	e.state.units[12].strength=0;e.state.units[12].casualties=150;e.refresh_support()
	check(not e.state.units[0].command_ok and e.state.units[0].ap==16,"destroyed QG cuts link without AP penalty")
	var save=Store.new("user://hq0821_test.json","hq0821");check(save.save_game(e),"write dead QG save")
	var other=fresh();check(save.load_game(other) and other.state==e.state,"exact dead QG save resume")
	e=arena();var snapshot=e.state.duplicate(true);var a=e.unit_cell(e.state.units[12]);var b=e.index(Vector2i(4,5))
	check(e.move(12,[a,b])=="moved" and e.undo() and e.state==snapshot,"QG movement and undo")
	e=fresh();e.pack.map.tiles.fill("plain");e.pack.map.elevations.fill(0)
	for n in range(e.state.units.size()):e.state.units[n].cell=[28,n]
	e.state.units[0].cell=[5,5];e.state.units[13].cell=[5,6];e.refresh_intel()
	var report=e.contact(13,0);check(report.type=="hq" and report.exact_strength==150,"adjacent enemy HQ identified with exact strength")
	check(e.validate(e.state),"HQ contact saves validate")
	e.state.units[13].cell=[5,8];e.refresh_intel();report=e.contact(13,0)
	if int(report.get("level",0))==1:
		var view=e.observation(0)
		for u in view.state.units:
			if u.id=="hq_1":check(view.pack.weapons[u.weapon].get("unit_type","")!="hq","unidentified HQ role not leaked through weapon")
	e=fresh();var view=e.observation(0);check(not view.state.command_hq.has("sauer_test_1"),"enemy QG command map withheld")
	var goal=Legacy.new().target_goal(e,12)
	check(goal!=e.objective() and e.cell(goal).y<e.cell(e.objective()).y,"AI QG seeks support position behind formation")
	for difficulty in ["easy","medium","hard"]:
		e.new_game(0,difficulty);var ai=AI.new();ai.profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
		check(not ai.choose(e.observation(0)).is_empty(),"AI decision "+difficulty)
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute("user://hq0821_test.json"+suffix)
	print("HQ 0821 ",checks-failures,"/",checks)
	quit(1 if failures else 0)

extends "res://tests/test_ai_compat0833.gd"
const Map=preload("res://war_engine/presentation/map_view.gd")
const Cartography=preload("res://war_engine/presentation/cartography.gd")
func _initialize():
	profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
	data=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial.json"))
	var e=Rules.new(data);e.new_game(0,"medium");e.state.seed=187037;e.state.ai_style=0
	var report=JSON.parse_string(FileAccess.get_file_as_string("res://tests/results/0837/full_battle_report.json"))
	for k in range(74):check(dispatch(e,report.actions[k].decision),"reproduce V37 artillery cycle prefix "+str(k))
	var ai=bot();var view=e.observation(1);var before=view.duplicate(true);var action=ai.choose(view)
	check(action.kind=="limber" and action.unit=="art_pr_Sandrart0","reproduce actual audited relocation decision")
	check(view==before,"relocation planning leaves observation unchanged")
	check(dispatch(e,action),"attelage legal and paid")
	var n=e.unit_index(action.unit);var ap=int(e.state.units[n].ap);var start=e.unit_cell(e.state.units[n]);var pending=ai.relocation.duplicate(true)
	var next=ai.choose(e.observation(1))
	check(next.kind=="move" and next.unit==action.unit,"next decision carries out relocation instead of redeploying")
	check(dispatch(e,next) and e.unit_cell(e.state.units[n])!=start and int(e.state.units[n].ap)<ap,"real movement consumes AP and changes cell")
	ai.relocation=pending;check(ai.continue_relocation(e).is_empty(),"stale relocation rejected after movement")
	ai.relocation=pending;e.state.turn+=1;check(ai.continue_relocation(e).is_empty(),"old-turn intention rejected")
	var p=data.duplicate(true);p.map.tiles.fill("plain");p.map.elevations.fill(0);p.map.river_edges=[];p.map.road_edges=[];var units=[]
	for pair in [[57,[4,4]],[56,[2,4]],[52,[7,4]],[66,[9,4]]]:
		var u=p.units[pair[0]].duplicate(true);u.cell=pair[1];u.arrival_turn=1;units.append(u)
	p.units=units;e=Rules.new(p);e.new_game(0,"hard");e.state.units[0].deployed=true;e.refresh_support();e.refresh_intel()
	view=e.observation(0);var simulated=Rules.new(view.pack,view.state);var observed_before=simulated.state.duplicate(true)
	ai=bot();ai.settings=profiles.hard;ai.hard_planning=true
	check(ai.threat(simulated,0)>0,"hard detects visible cavalry move-plus-charge threat at distance three")
	check(simulated.state==observed_before,"threat forecast restores simulation state")
	ai.hard_planning=false;check(ai.threat(simulated,0)==0,"medium threat model unchanged")
	e=Rules.new(data);e.new_game(0,"hard");var incoming=e.observation(0).own_reinforcements
	check(not incoming.is_empty(),"own scheduled reinforcements available to planner")
	for item in incoming:check(int(e.state.units[e.unit_index(item.id)].side)==0,"no opposing reinforcement schedule exposed")
	check(not e.observation(1).state.has("battle_history"),"history removed from sanitized observations")
	e.state.battle_history=[{"kind":"capture","turn":1,"side":0,"objective":"froeschwiller"},{"kind":"surrender","turn":1,"side":1,"unit":e.state.units[34].id,"prisoners":100}]
	var store=Store.new("user://v38_history.json","v38-history");check(store.save_game(e),"new save with optional history accepted")
	var copy=Rules.new(data);check(store.load_game(copy) and copy.state==e.state,"history survives exact save roundtrip")
	var legacy=e.state.duplicate(true);legacy.erase("battle_history");check(e.validate(legacy),"V35-V37 saves without history accepted")
	var invalid=e.state.duplicate(true);invalid.battle_history=[{"kind":"capture","turn":1,"side":7,"objective":"froeschwiller"}];check(not e.validate(invalid),"invalid history owner rejected")
	invalid=e.state.duplicate(true);invalid.battle_history=[{"kind":"surrender","turn":1,"side":0,"unit":"unknown","prisoners":1}];check(not e.validate(invalid),"unknown capitulated unit rejected")
	invalid=e.state.duplicate(true);invalid.battle_history=[{"kind":"surrender","turn":1,"side":0,"unit":e.state.units[34].id,"prisoners":100}];check(not e.validate(invalid),"capitulation cannot name opposing unit as friendly")
	invalid=e.state.duplicate(true);invalid.battle_history=[{"kind":"surrender","turn":1,"side":1,"unit":e.state.units[34].id,"prisoners":100},{"kind":"surrender","turn":1,"side":1,"unit":e.state.units[34].id,"prisoners":100}];check(not e.validate(invalid),"duplicate whole-unit capitulations rejected")
	var map=Map.new();map.engine=e;var pack_before=JSON.stringify(e.pack);var curve=Cartography.river_curve(map)
	check(curve.get_point_count()==60,"Sauer curve follows all 59 connected public river segments")
	check(curve.get_baked_length()>1500,"river curve spans original map")
	check(Cartography.name_center(map,curve)>0,"name finds public-map clearance")
	map.size=Vector2(1280,448);map.focus=map.world(e.index(Vector2i(16,9)))
	for zoom in [.42,.72,1.18,2.3]:
		map.zoom=zoom;var anchor=map.screen(e.index(Vector2i(6,2)));var expected=map.screen(e.index(Vector2i(6,1)))-anchor
		var text_size=map.font.get_string_size("Vers Reichshoffen",HORIZONTAL_ALIGNMENT_LEFT,-1,maxi(11,int(16*zoom)))
		var old_text=anchor+Vector2(0,-38)*zoom;old_text.x=clampf(old_text.x-text_size.x/2,8,maxf(8,map.size.x-text_size.x-8))
		var old_start=Vector2(old_text.x+text_size.x/2,old_text.y+8);var old_tip=old_start+expected
		var geometry=map.reichshoffen_geometry(anchor,text_size)
		check(geometry.text.is_equal_approx(old_text+expected),"actual text layout moved exactly one map hex at zoom "+str(zoom))
		check(geometry.start.is_equal_approx(old_start+expected) and geometry.tip.is_equal_approx(old_tip+expected),"both arrow endpoints move with text at zoom "+str(zoom))
		check((geometry.tip-geometry.start).is_equal_approx(expected),"arrow orientation and length preserved at zoom "+str(zoom))
	check(JSON.stringify(e.pack)==pack_before,"cartographic helpers leave scenario and terrain untouched")
	map.free();map=null;curve=null;ai=null;simulated=null;e=null;copy=null
	print("V38 STABILIZATION ",checks-failures,"/",checks);quit(1 if failures else 0)

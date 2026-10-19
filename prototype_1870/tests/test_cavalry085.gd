extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const Store=preload("res://war_engine/platform/save_store.gd")
const AI=preload("res://war_engine/ai/tactical_ai.gd")
var checks=0
var failures=0
var data: Dictionary
func check(ok: bool,msg: String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL: "+msg)
func scenario():
	var p=data.duplicate(true);p.map.tiles.fill("plain");var e=Rules.new(p)
	for n in range(e.state.units.size()):e.state.units[n].cell=[n*2,18]
	e.state.units[10].cell=[5,5];e.state.units[4].cell=[5,6];e.state.units[4].formation="line";e.state.seed=123
	return e
func strength(e,n,v):e.state.units[n].strength=v;e.state.units[n].casualties=e.state.units[n].initial_strength-v
func _initialize():
	data=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/legacy085.json"))
	var e=Rules.new(data)
	check(e.state.units.size()==12 and e.cavalry(10) and e.cavalry(11),"one cavalry per camp appended, old unit indices preserved")
	check(e.validate(e.state),"new cavalry scenario is valid")
	check(e.formation(10)=="none" and e.formation(0)=="column","mounted cavalry and initial infantry columns")
	check(e.formation_status(10,"line")=="cavalry" and not e.change_formation(10,"line"),"no infantry formation for cavalry")
	check(e.entrench_status(10)=="cavalry" and not e.entrench(10),"mounted troops cannot entrench")
	for terrain in ["plain","road","forest","hill","village","bridge","water"]:
		e.pack.map.tiles[0]=terrain
		check(e.movement_cost(10,0)==int(data.unit_types.cavalry.movement_costs.get(terrain,-1)),"movement "+terrain)
	e=scenario();var before=e.state.duplicate(true)
	check(e.fire(10,4).status=="no_fire" and e.state==before,"no voluntary mounted fire and no side effects")
	check(e.reaction_status(11,0)=="no_fire","no magical mounted return volley")
	var path=e.path_to(10,e.index(Vector2i(5,3)));var ap=int(e.state.units[10].ap)
	check(e.path_cost(path,10)==4 and e.move(10,path)=="moved" and e.state.units[10].ap==ap-4,"two plain cells cost 1 AP")
	check(e.undo() and e.state==before,"undo restores cavalry and state")
	e=scenario();e.state.units[10].ap=11;before=e.state.duplicate(true)
	check(e.assault(10,4).status=="no_ap" and e.state==before,"charge below 3 AP rejected atomically")
	e.state.units[10].ap=12;e.state.units[4].cell=[5,7]
	check(e.assault_status(10,4)=="range","charge only adjacent")
	e.state.units[4].cell=[5,6];e.state.units[10].morale="routed"
	check(e.assault_status(10,4)=="routed","no charge in rout")
	e=scenario();var ev=e.assault(10,4).event
	check(ev.kind=="charge" and ev.reaction and ev.return_loss>0 and ev.loss>0,"charge logs defensive volley and bilateral contact")
	check(ev.outcome=="repulsed","fresh line repels unsupported charge")
	check(e.state.assaults==1 and e.state.shots==0 and e.validate(e.state),"charge counts once and preserves state")
	e=scenario();strength(e,4,450);e.state.units[4].morale="shaken";e.state.units[4].cohesion=55;var goal=e.unit_cell(e.state.units[4]);e.pack.objective.cell=[5,6]
	ev=e.assault(10,4).event
	check(ev.outcome=="taken" and e.unit_cell(e.state.units[10])==goal and e.state.owner==0,"charge exploits weak disorganized infantry and captures objective")
	check(e.state.units[10].ap==4 and not e.undo(),"successful charge costs 3 AP and cannot undo")
	var store=Store.new("user://cavalry085_test.json","cavalry085");check(store.save_game(e),"charge save written")
	var copy=Rules.new(e.pack);check(store.load_game(copy) and copy.state==e.state,"charge, reactions, casualties and position reload exactly")
	e=scenario();var open_power=e.attack_power_against(10,4);var defence=e.defence_power_against(4,10)
	for terrain in ["forest","village","hill","bridge"]:
		e.pack.map.tiles[e.unit_cell(e.state.units[4])]=terrain
		check(e.attack_power_against(10,4)<open_power,"charge terrain penalty "+terrain)
	e.pack.map.tiles[e.unit_cell(e.state.units[4])]="plain";e.state.units[4].entrenched=true
	check(e.defence_power_against(4,10)>defence,"entrenchment protects from charge")
	e.state.units[4].entrenched=false;e.state.units[4].morale="shaken"
	check(e.defence_power_against(4,10)<defence,"disorganization reduces resistance")
	e=scenario();e.pack.weapons.dreyse.base_losses=900;ev=e.assault(10,4).event
	check(ev.outcome=="repulsed" and ev.loss==0,"defensive volley can stop charge before contact")
	e=scenario();e.state.units[4].cell=[8,18];e.state.units[9].cell=[5,6];e.state.units[9].deployed=true;ev=e.assault(10,9).event
	check(ev.reaction and ev.reaction_cannon and ev.return_loss>0,"deployed artillery fires against charge")
	e=scenario();e.state.units[4].cell=[8,18];e.state.units[11].cell=[5,6];ev=e.assault(10,11).event
	check(not ev.reaction and ev.return_loss>0 and ev.loss>0,"cavalry duel has contact losses without fictitious gunfire")
	e=scenario();e.state.side=1;e.state.units[11].cell=[5,5];e.state.units[10].cell=[20,18];e.state.units[0].cell=[5,6];e.state.units[4].cell=[8,18];strength(e,0,450);e.state.units[0].morale="shaken";ev=e.assault(11,0).event
	check(ev.kind=="charge" and ev.outcome=="taken" and e.validate(e.state),"Prussian cavalry follows same rules")
	# AI must prefer a viable charge, and must not choose one against a fresh line.
	e=scenario()
	for n in range(e.state.units.size()):
		if int(e.state.units[n].side)==0 and n!=10:e.state.units[n].done=true
	var ai=AI.new();var visible=[4,5,6,7,9,11];var choice=ai.choose(e.observation(0,visible))
	check(choice.kind!="assault","AI avoids fresh line charge")
	strength(e,4,450);e.state.units[4].morale="shaken";choice=ai.choose(e.observation(0,visible))
	check(choice.kind=="assault" and choice.unit=="cavalry_0" and choice.target=="1_0","AI charges vulnerable adjacent target")
	# Both new and legacy scenarios remain save-compatible with their own content hashes.
	var legacy=Rules.new(JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/legacy084.json")))
	check(legacy.state.units.size()==10 and legacy.validate(legacy.state),"legacy scenario retains original units")
	store=Store.new("user://legacy085_test.json","legacy084");legacy.move(0,legacy.path_to(0,legacy.index(Vector2i(12,7))))
	store.save_game(legacy);var legacy_copy=Rules.new(legacy.pack)
	check(store.load_game(legacy_copy) and legacy_copy.state==legacy.state,"legacy position, AP and reversible move preserved")
	# A full AI-vs-AI battle must finish without invalid commands or hangs.
	e=Rules.new(data);e.state.seed=123;var steps=0
	while not e.state.finished and steps<300:
		steps+=1;visible=[]
		for n in range(e.state.units.size()):
			if e.alive(n) and int(e.state.units[n].side)!=int(e.state.side):visible.append(n)
		choice=ai.choose(e.observation(int(e.state.side),visible));var n=e.unit_index(str(choice.get("unit","")));var ok=true
		match choice.kind:
			"end":e.end_side()
			"move":ok=e.move(n,choice.path) in ["moved","capture"]
			"fire":ok=e.fire(n,e.unit_index(choice.target)).status=="ok"
			"assault":ok=e.assault(n,e.unit_index(choice.target)).status=="ok"
			"formation":ok=e.change_formation(n,choice.formation)
			"rally":ok=e.rally(n)
			"entrench":ok=e.entrench(n)
			"deploy","limber":ok=e.toggle_deployment(n)
			_:ok=false
		if not ok or not e.validate(e.state):check(false,"AI battle command/state "+str(choice));break
	check(e.state.finished and steps<300,"AI completes six-turn cavalry exercise; commands="+str(steps))
	print("CAVALRY 085: %d / %d passed"%[checks-failures,checks]);quit(1 if failures else 0)

extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const Availability=preload("res://war_engine/presentation/unit_availability.gd")
const Store=preload("res://war_engine/platform/save_store.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func base():
	var p=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json"))
	p.map.tiles.fill("plain");p.map.elevations.fill(0);p.map.river_edges=[];p.map.road_edges=[];p.rules.fog.enabled=false
	var e=Rules.new(p);e.new_game(0,"hard")
	for u in e.state.units:u.pending=false;u.strength=0;u.casualties=u.initial_strength;u.prisoners=0;u.done=true;u.ap=0
	return e
func activate(e,id: String,pos: Vector2i,ap: int):
	var n=e.unit_index(id);var u=e.state.units[n]
	u.cell=[pos.x,pos.y];u.strength=u.initial_strength;u.casualties=0;u.prisoners=0;u.pending=false;u.done=false;u.ap=ap
	u.morale="stable";u.cohesion=100;u.entrenched=false;u.formation="line";u.deployed=false;u.rallied=false;u.river_halt=false;u.command_ok=true;u.supply_ok=true
	return n
func blocked(e,n):
	for cell in e.neighbours(e.unit_cell(e.state.units[n])):e.pack.map.tiles[cell]="water"
func assess(e,n,expected: bool,label):
	var before=JSON.stringify(e.state);var previous=JSON.stringify(e.previous);var a=Availability.new();a.update(e)
	check(a.usable.get(n,false)==expected,label)
	check(a.exhausted.get(n,false)==not expected,"check exactly opposes usability: "+label)
	check(JSON.stringify(e.state)==before and JSON.stringify(e.previous)==previous,"read-only: "+label)
	for key in a.usable:check(int(e.state.units[key].side)==int(e.state.human_side),"enemy AP never classified")
	return a
func _initialize():call_deferred("run")
func run():
	var e=base();var n=activate(e,"fr_9",Vector2i(14,9),2)
	assess(e,n,false,"0.5 AP infantry on plain is exhausted")
	check(e.state.units[n].ap==2 and not e.state.units[n].done and e.state.units[n].reactions>0,"check consumes no AP and keeps defensive budget")
	var start=e.unit_cell(e.state.units[n]);var dest=e.neighbours(start)[0];e.road_links[e.river_key(start,dest)]=true
	assess(e,n,true,"0.5 AP infantry can still use a road")
	var path=e.path_to(n,dest);check(path.size()==2 and e.move(n,path) in ["moved","capture","discovered"],"existing engine really accepts that road movement")
	assess(e,n,false,"moving uses the last half AP")
	e=base();n=activate(e,"fr_25",Vector2i(14,9),2);assess(e,n,true,"0.5 AP cavalry can still move on plain")
	e.state.units[n].ap=1;assess(e,n,false,"0.25 AP cavalry cannot move on plain or fire for free")
	start=e.unit_cell(e.state.units[n]);dest=e.neighbours(start)[0];e.road_links[e.river_key(start,dest)]=true
	assess(e,n,true,"0.25 AP cavalry can still move along a road")
	e=base();n=activate(e,"fr_9",Vector2i(14,9),4);blocked(e,n)
	assess(e,n,true,"a formation change alone prevents the check")
	e.state.units[n].river_halt=true;assess(e,n,true,"ford stop still permits a legal formation change")
	e.pack.rules.formations.types={"line":e.pack.rules.formations.types.line};assess(e,n,false,"blocked infantry with no other legal action is checked even at 1 AP")
	# Two road steps, passing through an occupied friendly cell, reach a free endpoint.
	e=base();n=activate(e,"fr_25",Vector2i(14,9),2);var friend=activate(e,"fr_1",Vector2i(15,9),0)
	e.pack.map.tiles.fill("water")
	for c in [Vector2i(14,9),Vector2i(15,9),Vector2i(16,9)]:e.pack.map.tiles[e.index(c)]="plain"
	var mid=e.unit_cell(e.state.units[friend]);dest=e.index(Vector2i(16,9));start=e.unit_cell(e.state.units[n])
	e.road_links[e.river_key(start,mid)]=true;e.road_links[e.river_key(mid,dest)]=true
	assess(e,n,true,"movement through friends to a free endpoint still counts")
	check(e.move(n,e.path_to(n,dest)) in ["moved","capture","discovered"],"engine accepts the friendly transit route")
	# Only a shot remains: no movement, shelter, formation change, rally or assault.
	e=base();n=activate(e,"fr_9",Vector2i(14,9),8);blocked(e,n);e.state.units[n].entrenched=true
	e.pack.rules.formations.types={"line":e.pack.rules.formations.types.line}
	var foe=activate(e,"pru_36",Vector2i(16,9),16)
	check(e.fire_status(n,foe)=="ok","shoot-only fixture is legal")
	assess(e,n,true,"a legal shot alone prevents the check")
	check(e.fire(n,foe).status=="ok","existing fire really executes")
	# Cavalry cannot use fire(ap=0) to bypass the check or isolation restriction.
	e=base();n=activate(e,"fr_25",Vector2i(14,9),8);blocked(e,n);foe=activate(e,"pru_36",Vector2i(15,9),16);e.pack.map.tiles[e.unit_cell(e.state.units[foe])]="plain"
	check(e.assault_status(n,foe)=="ok" and e.assault_cost(n)==8,"2 AP charge remains legal")
	assess(e,n,true,"a legal charge alone prevents the check")
	e.state.units[n].command_ok=false;e.state.units[n].supply_ok=false
	check(e.assault_status(n,foe)=="isolated","double-cut charge still prohibited")
	assess(e,n,false,"isolated blocked cavalry cannot pretend to have a charge")
	e=base();n=activate(e,"fr_9",Vector2i(14,9),8);e.state.units[n].morale="routed";e.state.units[n].cohesion=10
	assess(e,n,true,"rally alone remains an available action")
	e.state.units[n].rallied=true;assess(e,n,false,"routed unit that cannot rally is exhausted")
	e=base();n=activate(e,"qg_fr_Raoult",Vector2i(14,9),8);blocked(e,n)
	assess(e,n,true,"entrenchment alone remains an action")
	check(e.entrench(n),"existing engine accepts entrenchment");assess(e,n,false,"entrenchment spends the remaining AP")
	e=base();n=activate(e,"art_fr_Raoult0",Vector2i(14,9),4);blocked(e,n)
	assess(e,n,true,"deployment alone remains an action")
	check(e.toggle_deployment(n),"existing deployment executes")
	e.state.units[n].ap=2;e.state.units[n].done=false
	assess(e,n,false,"deployed cannon with 0.5 AP cannot act, even with a reaction ready")
	foe=activate(e,"pru_36",Vector2i(16,9),16);e.state.side=1
	check(e.reaction_status(n,foe)=="ok","check never disables a legal defensive cannon reaction")
	e=base();n=activate(e,"fr_9",Vector2i(14,9),2);assess(e,n,false,"isolated budget fixture before reopening")
	e.state.units[n].ap=4;assess(e,n,true,"check clears as soon as an action becomes possible")
	e.state.side=1;var a=assess(e,n,true,"opposing phase does not automatically check all own units")
	check(a.count==0,"next-unit count disabled during opposing phase")
	e.state.side=0;e.state.units[n].done=true;assess(e,n,false,"an explicitly held unit stays done")
	# A checked unit can regain an action when another unit frees a path.
	e=base();n=activate(e,"qg_fr_Raoult",Vector2i(14,9),4)
	var ring=e.neighbours(e.unit_cell(e.state.units[n]))
	for k in range(ring.size()):activate(e,"fr_"+str(k+2),e.cell(ring[k]),16)
	assess(e,n,false,"friendly ring leaves no affordable free endpoint")
	var blocker=e.unit_index("fr_2");var vacated=false
	for cell in e.neighbours(e.unit_cell(e.state.units[blocker])):
		if e.unit_at(cell)<0 and e.distance(cell,e.unit_cell(e.state.units[n]))>1:
			vacated=e.move(blocker,e.path_to(blocker,cell)) in ["moved","capture","discovered"];break
	check(vacated,"ally really vacates a neighbouring cell through legal movement")
	assess(e,n,true,"check clears when an ally opens a passage")
	check(e.state.units[n].ap==4 and not e.state.units[n].done,"reopening never grants AP or resets the unit")
	# Counterfactual hidden occupants cannot change a player's visible marker.
	e=base();n=activate(e,"fr_25",Vector2i(14,9),2);e.pack.rules.fog.enabled=true
	e.vision_cache=[{"levels":{}},{"levels":{}}];var first=Availability.new();first.update(e)
	foe=activate(e,"pru_36",Vector2i(15,9),16);var second=Availability.new();second.update(e)
	check(first.usable==second.usable and first.exhausted==second.exhausted,"unseen enemy occupancy does not leak through check")
	var raw=FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json");e=Rules.new(JSON.parse_string(raw));e.new_game(0,"hard")
	n=e.unit_index("fr_9");e.state.units[n].ap=2;a=Availability.new();a.update(e)
	var saver=Store.new("user://availability.json",raw.sha256_text());var restored=Rules.new(e.pack)
	check(saver.save_game(e) and saver.load_game(restored),"half-AP state saves and reloads")
	var after=Availability.new();after.update(restored)
	check(a.usable==after.usable and restored.state.units[n].ap==2,"check recomputed on reload with all remaining AP preserved")
	# Compare the short-circuit search against the unchanged full engine reach.
	var rng=RandomNumberGenerator.new();rng.seed=1870431510
	for id in ["fr_9","fr_25","art_fr_Raoult0","qg_fr_Raoult"]:
		e=base();n=activate(e,id,Vector2i(14,9),16)
		for budget in [1,2,3,4,8,12,16]:
			for variant in range(8):
				for pos in range(600):e.pack.map.tiles[pos]=["plain","plain","forest","road","water"][rng.randi_range(0,4)]
				e.pack.map.tiles[e.unit_cell(e.state.units[n])]="plain";e.road_links.clear()
				for pos in e.neighbours(e.unit_cell(e.state.units[n])):
					if rng.randi_range(0,1)==0:e.road_links[e.river_key(pos,e.unit_cell(e.state.units[n]))]=true
				for friend_id in ["fr_2","fr_3","fr_4","fr_5","fr_6","fr_7"]:e.state.units[e.unit_index(friend_id)].strength=0
				if variant>=4:
					var nearby=e.neighbours(e.unit_cell(e.state.units[n]))
					for k in range(nearby.size()):activate(e,"fr_"+str(k+2),e.cell(nearby[k]),0)
				e.state.units[n].ap=budget;e.state.units[n].deployed=e.artillery(n) and variant==0;e.state.units[n].river_halt=variant==1
				var expected=false
				for oracle_cell in e.reach(n).costs:
					if oracle_cell!=e.unit_cell(e.state.units[n]) and e.path_unit_at(oracle_cell)<0:expected=true;break
				check(Availability.has_move(e,n)==expected,"movement matches real engine reach, "+id+" budget "+str(budget)+" variant "+str(variant))
	print("UNIT AVAILABILITY 10 ",checks-failures,"/",checks);quit(1 if failures else 0)

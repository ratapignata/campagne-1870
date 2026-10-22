extends "res://war_engine/core/rules_base.gd"
# Generic combat, morale and formation rules; values live in the content pack.
const Support=preload("res://war_engine/core/support.gd")
const Intel=preload("res://war_engine/core/intel.gd")
var vision_cache: Array=[]
var physical_lines=false
var resolving_surrenders=false
static func normalize_difficulty(value: String) -> String:
	# Keep medium as the stable internal ID: its V38 profile is unchanged.
	return "hard" if value.to_lower() in ["hard","difficile"] else "medium"
func new_game(human: int=0,difficulty: String="medium") -> void:
	super.new_game();state.human_side=human;state.assaults=0
	state.support_events=[];state.support_serial=0
	state.battle_history=[];state.loss_history=[]
	state.ai_difficulty=normalize_difficulty(difficulty);state.ai_style=int(randi()%2)
	for u in state.units:
		u.isolation_turns=0;u.morale="stable";u.cohesion=100;u.casualties=0;u.prisoners=0;u.rallied=false;u.reactions=int(pack.rules.combat.reactions);u.quiet=true;u.entrenched=false;u.formation="none" if bool(pack.weapons[u.weapon].get("requires_deployment",false)) or pack.weapons[u.weapon].get("unit_type","")=="cavalry" else str(pack.rules.get("formations",{}).get("initial",pack.rules.get("formations",{}).get("default","line")))
	for u in state.units:
		u.pending=int(u.get("arrival_turn",1))>1
		if u.pending:u.strength=0;u.ap=0;u.done=true
	for n in range(state.units.size()):
		if headquarters(n):state.units[n].formation="line"
	if support_enabled():
		for u in state.units:
			u.attacked=false;u.supply_interrupted=false;u.ammo_level=0;u.ammo_spent=0;u.supply_ok=true;u.command_ok=true;u.encircled=false
		update_support(0);update_support(1)
	vision_cache=[];state.contacts=[{},{}];state.revealed=[[],[]];refresh_intel()
func normalize() -> void:
	super.normalize()
	for snapshot in state.get("loss_history",[]):
		if not snapshot.has("losses") and snapshot.has("casualties"):
			snapshot.losses=snapshot.casualties
		snapshot.erase("casualties")
		snapshot.turn=int(snapshot.turn)
		for key in ["losses","prisoners"]:
			for side in [0,1]:snapshot[key][side]=int(snapshot[key][side])
	for event in state.get("battle_history",[]):
		for key in ["turn","side","prisoners"]:
			if event.has(key):event[key]=int(event[key])
	for key in ["support_serial","surrender_serial"]:
		if state.has(key):state[key]=int(state[key])
	for event in state.get("support_events",[]):
		for key in ["serial","turn","side","prisoners"]:event[key]=int(event[key])
		for k in range(event.cell.size()):event.cell[k]=int(event.cell[k])
	for u in state.units:
		if u.has("turn_ap_limit"):u.turn_ap_limit=int(u.turn_ap_limit)
		if u.has("isolation_turns"):u.isolation_turns=int(u.isolation_turns)
	state.ai_difficulty=normalize_difficulty(str(state.get("ai_difficulty","legacy")));state.ai_style=int(state.get("ai_style",0))
	state.human_side=int(state.get("human_side",0));state.assaults=int(state.get("assaults",0))
	for u in state.units:
		u.entrenched=bool(u.get("entrenched",false))
		if support_enabled():
			u.attacked=bool(u.get("attacked",not u.get("quiet",true)));u.supply_interrupted=bool(u.get("supply_interrupted",false))
			u.ammo_level=int(u.get("ammo_level",0));u.ammo_spent=int(u.get("ammo_spent",0))
			for key in ["supply_ok","command_ok"]:u[key]=bool(u.get(key,true))
			u.encircled=bool(u.get("encircled",false))
			if u.has("command_distance"):u.command_distance=int(u.command_distance)
		u.formation=str(u.get("formation","none" if bool(pack.weapons[u.weapon].get("requires_deployment",false)) or pack.weapons[u.weapon].get("unit_type","")=="cavalry" else pack.rules.get("formations",{}).get("default","line")))
		for key in ["cohesion","casualties","prisoners","reactions"]:u[key]=int(u.get(key,100 if key=="cohesion" else 0))
	for event in state.events:
		for key in ["prisoners","return_loss","attacker_prisoners"]:event[key]=int(event[key])
		for key in ["from","to","retreat","attacker_retreat","advance"]:
			for k in range(event[key].size()):event[key][k]=int(event[key][k])
	for records in state.get("contacts",[]):
		for report in records.values():
			for key in ["level","low","high","number","turn"]:report[key]=int(report[key])
			for key in ["exact_strength","exact_power"]:
				if report.has(key):report[key]=int(report[key])
			report.cell=[int(report.cell[0]),int(report.cell[1])]
	for revealed in state.get("revealed",[]):
		for k in range(revealed.size()):revealed[k]=int(revealed[k])
	vision_cache=[]
	if not state.units.is_empty() and state.units[0].has("morale"):
		refresh_support(false);refresh_intel()
func support_enabled() -> bool:return bool(pack.rules.get("support",{}).get("enabled",false))
func headquarters(n: int) -> bool:
	return n>=0 and n<state.units.size() and weapon(n).get("unit_type","")=="hq"
func fixed_hq() -> bool:
	return support_enabled() and bool(pack.rules.support.get("fixed_hq",false))
func assign_hq(side: int) -> void:
	if not fixed_hq():return
	if not state.has("command_hq"):state.command_hq={}
	if pack.rules.support.get("separate_hq",false):
		for n in range(state.units.size()):
			if int(state.units[n].side)==side and headquarters(n):state.command_hq[str(state.units[n].command_group)]=str(state.units[n].id)
		return
	var groups={}
	for n in range(state.units.size()):
		var u=state.units[n]
		if int(u.side)!=side or not alive(n) or u.morale=="routed":continue
		var group=str(u.get("command_group",str(side)))
		if not groups.has(group):groups[group]=[]
		groups[group].append(n)
	for group in groups:
		var old=unit_index(str(state.command_hq.get(group,"")))
		if groups[group].has(old):continue
		var preferred=unit_index(str(pack.rules.support.get("preferred_hq",{}).get(group,""))) if not state.command_hq.has(group) else -1
		var chosen=preferred if groups[group].has(preferred) else int(groups[group][0])
		if preferred<0:
			for n in groups[group]:
				if not artillery(n) and not cavalry(n):chosen=n;break
		state.command_hq[group]=str(state.units[chosen].id)
func strict_links() -> bool:return support_enabled() and bool(pack.rules.support.get("strict_links",false))
func support_budget(n: int) -> int:
	var base=super.max_ap(n);var u=state.units[n]
	if not strict_links() or u.get("command_ok",true):return base
	return mini(base,int(pack.rules.support.get("isolated_ap",8))) if not u.get("supply_ok",true) else maxi(0,base-int(pack.rules.support.get("uncommanded_ap_penalty",4)))
func max_ap(n: int) -> int:
	return int(state.units[n].get("turn_ap_limit",super.max_ap(n))) if strict_links() else super.max_ap(n)
func support_event(n: int,kind: String,amount: int=0):
	if not state.has("support_events"):state.support_events=[]
	state.support_serial=int(state.get("support_serial",0))+1
	var u=state.units[n]
	state.support_events.append({"serial":state.support_serial,"turn":state.turn,"side":u.side,"unit":u.id,"name_key":u.name_key,"kind":kind,"prisoners":amount,"cell":u.cell.duplicate()})
	if kind=="surrender" and state.has("battle_history"):
		state.battle_history.append({"turn":state.turn,"side":u.side,"unit":u.id,"kind":kind,"prisoners":amount})
		if state.battle_history.size()>512:state.battle_history.pop_front()
	if state.support_events.size()>256:state.support_events.pop_front()
func surrender(n: int) -> int:
	if not alive(n):return 0
	var u=state.units[n];var count=int(u.strength)
	u.prisoners+=count;u.strength=0;u.ap=0;u.done=true;u.deployed=false;u.entrenched=false;u.reactions=0
	if int(state.active)==n:state.active=-1
	state.surrender_serial=int(state.get("surrender_serial",0))+1
	previous={};state.undo_reason="surrender";support_event(n,"surrender",count)
	return count
func resolve_surrenders():
	if not strict_links() or resolving_surrenders or state.finished:return
	resolving_surrenders=true
	for _pass in range(state.units.size()):
		var changed=false
		for n in range(state.units.size()):
			if alive(n) and state.units[n].morale=="routed" and not state.units[n].get("command_ok",true) and retreat_route(n).is_empty():surrender(n);changed=true
		if not changed:break
		update_support(0);update_support(1)
	resolving_surrenders=false
func refresh_support(resolve: bool=true) -> void:
	if fixed_hq():update_support(0);update_support(1)
	if resolve:resolve_surrenders()
func update_support(side: int) -> void:
	if not support_enabled():return
	assign_hq(side)
	if fixed_hq():
		for u in state.units:
			if int(u.side)==side:u.is_hq=false
	var reports=Support.assess_side(self,side)
	for n in reports:
		if strict_links() and (state.units[n].get("command_ok",true) and not reports[n].command_ok or state.units[n].get("supply_ok",true) and not reports[n].supply_ok):support_event(n,"cut")
		for key in reports[n]:state.units[n][key]=reports[n][key]
		if reports[n].supply_ok or reports[n].command_ok:state.units[n].isolation_turns=0
		if fixed_hq() and not reports[n].supply_ok:state.units[n].supply_interrupted=true
func ammo_factor(n: int) -> float:
	if not support_enabled():return 1.0
	return float(pack.rules.support.ammo_factors[int(state.units[n].get("ammo_level",0))])
func spend_ammo(n: int) -> void:
	if not support_enabled() or not bool(weapon(n).get("can_fire",true)):return
	var u=state.units[n];u.ammo_spent+=1
	if u.ammo_spent>=int(pack.rules.support.salvos_per_level):
		u.ammo_level=mini(2,u.ammo_level+1);u.ammo_spent=0
func rally_cost(n: int) -> int:
	var extra=int(pack.rules.support.rally_extra_ap) if support_enabled() and not state.units[n].get("command_ok",true) else 0
	return int(pack.rules.morale.rally_ap)+extra
func relaxed_supply() -> bool:
	return support_enabled() and pack.rules.support.get("recovery_mode","")=="no_voluntary_attack"
func rest_status(n: int) -> String:
	if not support_enabled() or not can_act(n) or cavalry(n):return "invalid"
	var u=state.units[n]
	if u.morale=="routed":return "routed"
	if int(u.ammo_level)==0 and int(u.ammo_spent)==0:return "full"
	if not u.supply_ok:return "cut"
	if u.get("attacked",false) if relaxed_supply() else not u.quiet:return "fired"
	if not relaxed_supply() and enemy_distance(n,unit_cell(u))<=1:return "danger"
	return "ok"
func rest(n: int) -> bool:
	return hold(n) if rest_status(n)=="ok" else false
func fog_enabled() -> bool:return bool(pack.rules.get("fog",{}).get("enabled",false))
func refresh_intel() -> void:
	if not fog_enabled():return
	if not state.has("contacts"):state.contacts=[{},{}]
	if not state.has("revealed"):state.revealed=[[],[]]
	vision_cache=[Intel.compute(self,0),Intel.compute(self,1)]
	for side in [0,1]:
		var view=vision_cache[side];var records=state.contacts[side]
		for key in records.keys():
			# A muzzle-flash revelation is not continuous visual observation.
			if not view.observed.has(key):
				records[key].erase("exact_strength");records[key].erase("exact_power")
			var c=records[key].cell;var pos=index(Vector2i(int(c[0]),int(c[1])))
			if view.searched.has(str(pos)) and not view.levels.has(key):records.erase(key)
		for key in view.levels:
			records[key]=Intel.report(self,int(key),int(view.levels[key]),records.get(key,{}).has("exact_strength") or view.adjacent.has(key))
func visible_to(side: int,n: int) -> bool:
	if not alive(n):return false
	if not fog_enabled() or state.finished or int(state.units[n].side)==side:return true
	if vision_cache.is_empty():refresh_intel()
	return vision_cache[side].levels.has(str(n))
func cell_visible(side: int,i: int) -> bool:
	if not fog_enabled() or state.finished:return true
	if vision_cache.is_empty():refresh_intel()
	return vision_cache[side].cells.has(str(i))
func known_unit_at(i: int,side: int) -> int:
	var n=unit_at(i)
	return n if visible_to(side,n) else -1
func line_unit_at(i: int,shooter: int) -> int:
	return unit_at(i) if physical_lines or not fog_enabled() or shooter<0 else known_unit_at(i,int(state.units[shooter].side))
func first_interceptor(shooter: int,target: int) -> int:
	var a=unit_cell(state.units[shooter]);var b=unit_cell(state.units[target]);var steps=distance(a,b)
	for k in range(1,steps):
		for sign_value in [-1.0,1.0]:
			var offset=Vector3(0.00001,0.00001,-0.00002)*sign_value
			var pos=round_hex((cube(a)+offset).lerp(cube(b)+offset,float(k)/steps));var occupant=unit_at(pos)
			if occupant>=0 and int(state.units[occupant].side)!=int(state.units[shooter].side):return occupant
	return -1
func path_unit_at(i: int) -> int:return known_unit_at(i,int(state.side)) if fog_enabled() else unit_at(i)
func contact(n: int,side: int) -> Dictionary:
	if not fog_enabled():return {}
	return state.contacts[side].get(str(n),{})
func contact_at(i: int,side: int) -> int:
	if not fog_enabled():return -1
	for key in state.contacts[side]:
		var c=state.contacts[side][key].cell
		if index(Vector2i(int(c[0]),int(c[1])))==i:return int(key)
	return -1
func intel_signature(side: int) -> Dictionary:
	var value=state.contacts[side].duplicate(true)
	for record in value.values():record.erase("turn")
	return value
func undo() -> bool:
	var result=super.undo()
	if result:refresh_intel()
	return result
func cavalry(n: int) -> bool:
	return n>=0 and n<state.units.size() and weapon(n).get("unit_type","")=="cavalry"
func unit_profile(n: int) -> Dictionary:
	return pack.get("unit_types",{}).get(weapon(n).get("unit_type",""),{}) if alive(n) else {}
func assault_cost(n: int) -> int:
	return int(unit_profile(n).get("charge_ap",pack.rules.assault.ap))
# Variant B is opt-in per scenario and applies symmetrically to infantry melee only.
# Normalization keeps 1000 men at V42 power; shooting and cavalry never use it.
func melee_strength(n: int,other: int,strength: float) -> float:
	var cfg=pack.rules.assault
	if not cfg.has("infantry_strength_exponent") or n<0 or other<0:return strength
	if cavalry(n) or artillery(n) or headquarters(n) or cavalry(other) or artillery(other) or headquarters(other):return strength
	var reference=float(cfg.get("infantry_strength_reference",1000.0))
	return reference*pow(maxf(0.0,strength)/reference,float(cfg.infantry_strength_exponent))
func attack_power_against(n: int,target: int) -> float:
	var power=assault_power(n,false)*melee_strength(n,target,float(state.units[n].strength))/maxf(1.0,float(state.units[n].strength))
	if cavalry(n):
		var cfg=unit_profile(n);var from_terrain=pack.map.tiles[unit_cell(state.units[n])];var to_terrain=pack.map.tiles[unit_cell(state.units[target])]
		power*=minf(float(cfg.charge_terrain.get(from_terrain,1.0)),float(cfg.charge_terrain.get(to_terrain,1.0)))
	return power
func defence_power_against(n: int,attacker: int) -> float:
	var power=assault_power(n,true)*melee_strength(n,attacker,float(state.units[n].strength))/maxf(1.0,float(state.units[n].strength))
	if cavalry(attacker) and not artillery(n) and not cavalry(n) and state.units[n].morale=="stable":power*=float(unit_profile(attacker).get("orderly_infantry_defence",1.0))
	return power
func formation(n: int) -> String:
	if not alive(n) or artillery(n) or cavalry(n):return "none"
	return str(state.units[n].get("formation",pack.rules.get("formations",{}).get("default","line")))
func formation_factor(n: int,key: String) -> float:
	return float(pack.rules.get("formations",{}).get("types",{}).get(formation(n),{}).get(key,1.0))
func movement_cost(n: int,i: int) -> int:
	var base=cost(i)
	if base<0:return base
	if cavalry(n):return int(unit_profile(n).get("movement_costs",{}).get(pack.map.tiles[i],base))
	return maxi(1,ceili(base*formation_factor(n,"move")))
func road_movement_cost(n: int) -> int:
	var base=int(pack.terrains.road.cost)
	if cavalry(n):return int(unit_profile(n).get("movement_costs",{}).get("road",base))
	return maxi(1,ceili(base*formation_factor(n,"move")))
func formation_status(n: int,value: String) -> String:
	if not alive(n) or state.finished or int(state.units[n].side)!=int(state.side):return "invalid"
	if artillery(n):return "artillery"
	if headquarters(n):return "invalid"
	if cavalry(n):return "cavalry"
	if not pack.rules.get("formations",{}).get("types",{}).has(value):return "invalid"
	if formation(n)==value:return "already"
	if state.units[n].morale=="routed":return "routed"
	if not can_act(n) or int(state.units[n].ap)<int(pack.rules.formations.change_ap):return "no_ap"
	return "ok"
func change_formation(n: int,value: String) -> bool:
	if formation_status(n,value)!="ok":return false
	var u=state.units[n];u.formation=value;u.ap-=int(pack.rules.formations.change_ap);u.done=u.ap<=0
	state.active=n if not u.done else -1;previous={};state.undo_reason="formation";refresh_intel();return true
func actionable(n: int) -> bool:
	return can_act(n) and (state.units[n].morale!="routed" or rally_status(n)=="ok")
func available_count() -> int:
	var total=0
	for n in range(state.units.size()):
		if actionable(n):total+=1
	return total
func reach(n: int,unlimited: bool=false) -> Dictionary:
	if alive(n) and state.units[n].morale=="routed":return {"costs":{},"parents":{}}
	return super.reach(n,unlimited)
func move(n: int,path: Array) -> String:
	if alive(n) and state.units[n].morale=="routed":return "routed"
	if not fog_enabled():
		var result=super.move(n,path)
		if result in ["moved","capture"]:state.units[n].entrenched=false;refresh_support()
		return result
	if not can_act(n) or path.size()<2 or int(path[0])!=unit_cell(state.units[n]):return "invalid"
	var u=state.units[n]
	if u.deployed:return "deployed"
	if u.get("river_halt",false):return "river_halt"
	var total=0
	for k in range(1,path.size()):
		var next=int(path[k])
		if next<0 or next>=width*height or distance(int(path[k-1]),next)!=1 or cost(next)<0:return "invalid"
		var known=path_unit_at(next)
		if known>=0 and (int(state.units[known].side)!=int(u.side) or k==path.size()-1):return "occupied"
		var step=step_cost(n,int(path[k-1]),next)
		if step<0 or (open_river(int(path[k-1]),next) and k<path.size()-1):return "river"
		if open_river(int(path[k-1]),next) and known>=0:return "occupied"
		total+=step
	if total>int(u.ap):return "no_ap"
	var before=state.duplicate(true);var own_before=intel_signature(int(u.side));var other_before=intel_signature(1-int(u.side))
	var travelled=0;var pending_cost=0;var discovered=false;var captured=false
	for k in range(1,path.size()):
		var next=int(path[k]);var occupant=unit_at(next)
		if occupant>=0 and int(state.units[occupant].side)!=int(u.side):break
		pending_cost+=step_cost(n,int(path[k-1]),next)
		if occupant>=0:continue
		for revealed in state.revealed:revealed.erase(n)
		u.cell=[cell(next).x,cell(next).y];u.ap-=pending_cost;pending_cost=0;travelled+=1;u.entrenched=false
		if open_river(int(path[k-1]),next):u.river_halt=true
		if capture_objective(next,int(u.side)):captured=true
		refresh_intel()
		if intel_signature(int(u.side))!=own_before:discovered=true;break
	if travelled==0:return "occupied"
	u.done=u.ap<=0;state.active=n if not u.done else -1;state.moves+=1
	refresh_support()
	var enemy_changed=intel_signature(1-int(u.side))!=other_before
	var enemy_lock=enemy_changed and not bool(pack.rules.get("undo_player_discovery_only",false))
	var surrendered=int(state.get("surrender_serial",0))!=int(before.get("surrender_serial",0))
	previous=before if not captured and not discovered and not enemy_lock and not surrendered else {}
	state.undo_reason="surrender" if surrendered else "capture" if captured else "discovery" if discovered else "information" if enemy_lock else "available"
	return "discovered" if discovered else "capture" if captured else "moved"
func toggle_deployment(n: int) -> bool:
	if alive(n) and state.units[n].morale=="routed":return false
	var changed=super.toggle_deployment(n)
	if changed:state.units[n].entrenched=false;refresh_intel()
	return changed
func fire_cell_status(shooter: int,destination: int) -> String:
	if alive(shooter) and not bool(weapon(shooter).get("can_fire",true)):return "no_fire"
	if alive(shooter) and state.units[shooter].morale=="routed":return "routed"
	return super.fire_cell_status(shooter,destination)
func artillery_fire_cells(shooter: int) -> Dictionary:
	var cells={}
	if not alive(shooter) or not can_act(shooter) or cavalry(shooter) or headquarters(shooter):return cells
	if not artillery(shooter):
		for j in range(state.units.size()):
			if fire_status(shooter,j)=="ok":cells[unit_cell(state.units[j])]=true
		return cells
	var side=int(state.units[shooter].side)
	for i in range(width*height):
		var occupant=known_unit_at(i,side)
		if occupant>=0 and int(state.units[occupant].side)==side:continue
		if fire_cell_status(shooter,i)=="ok":cells[i]=true
	return cells
func fire_status(shooter: int,target: int) -> String:
	if alive(shooter) and alive(target) and not visible_to(int(state.units[shooter].side),target):return "hidden"
	if alive(shooter) and not bool(weapon(shooter).get("can_fire",true)):return "no_fire"
	if alive(shooter) and state.units[shooter].morale=="routed":return "routed"
	return super.fire_status(shooter,target)
# A reaction has its own budget; AP and activation state do not disable defence.
func reaction_status(defender: int,attacker: int) -> String:
	if state.finished or not alive(defender) or not alive(attacker):return "invalid"
	if not bool(weapon(defender).get("can_fire",true)):return "no_fire"
	var a=state.units[defender];var b=state.units[attacker]
	if int(a.side)==int(b.side) or int(a.side)==int(state.side):return "friendly"
	if a.morale=="routed":return "routed"
	if int(a.reactions)<=0:return "spent"
	if artillery(defender) and not a.deployed:return "limbered"
	if distance(unit_cell(a),unit_cell(b))>int(weapon(defender).range):return "range"
	physical_lines=true
	var line=line_status(unit_cell(a),unit_cell(b))
	physical_lines=false
	if line!="ok":return line
	return "ok"
func combat_rng() -> RandomNumberGenerator:
	var rng=RandomNumberGenerator.new();rng.seed=int(state.seed)+state.events.size()*7919
	return rng
func shot_loss(shooter: int,target: int,rng: RandomNumberGenerator,factor: float=1.0) -> int:
	var a=state.units[shooter];var b=state.units[target];var w=weapon(shooter)
	var d=distance(unit_cell(a),unit_cell(b));var terrain=pack.terrains[pack.map.tiles[unit_cell(b)]]
	var morale_factor=float(pack.rules.morale.shaken_fire) if a.morale=="shaken" else 1.0
	var target_factor=(float(pack.rules.combat.battery_target_factor) if artillery(target) else 1.0)*formation_factor(target,"fire_received")*formation_factor(shooter,"fire")
	target_factor*=float(unit_profile(target).get("fire_received",1.0))
	if b.get("entrenched",false):target_factor*=float(pack.rules.entrenchment.fire_received)
	var roll=rng.randf_range(1.0-float(w.variance),1.0+float(w.variance))
	return mini(int(b.strength),maxi(1,roundi(float(w.base_losses)*float(a.strength)/float(a.initial_strength)*float(w.distance_factors[d-1])*float(terrain.fire_received)*roll*morale_factor*factor*target_factor*ammo_factor(shooter))))
func apply_losses(n: int,loss: int) -> void:
	var u=state.units[n];loss=mini(loss,int(u.strength))
	if loss<=0:return
	u.strength-=loss;u.casualties+=loss;u.quiet=false
	u.cohesion=maxi(0,u.cohesion-maxi(1,roundi(float(loss)/u.initial_strength*float(pack.rules.morale.loss_shock))))
	if u.strength<=0:u.ap=0;u.done=true;u.entrenched=false;return
	var significant=float(u.casualties)/u.initial_strength>=float(pack.rules.morale.major_losses)
	var shock=float(loss)/u.initial_strength>=float(pack.rules.morale.single_shock)
	if u.morale=="routed" or shock or (significant and u.cohesion<int(pack.rules.morale.routed_below)):u.morale="routed"
	else:u.morale="shaken" if u.cohesion<int(pack.rules.morale.shaken_below) else "stable"
	if u.morale=="routed":u.entrenched=false
func reveal_combatants(shooter: int,target: int,close_contact: bool=false) -> void:
	if not fog_enabled():return
	for pair in [[shooter,target],[target,shooter]]:
		var side=int(state.units[pair[1]].side)
		if not state.revealed[side].has(pair[0]):state.revealed[side].append(pair[0])
	refresh_intel()
	if close_contact:
		for pair in [[shooter,target],[target,shooter]]:
			var side=int(state.units[pair[1]].side);var key=str(pair[0])
			if vision_cache[side].observed.has(key):state.contacts[side][key]=Intel.report(self,pair[0],int(vision_cache[side].levels[key]),true)
func combat_event(shooter: int,target: int,kind: String) -> Dictionary:
	reveal_combatants(shooter,target,distance(unit_cell(state.units[shooter]),unit_cell(state.units[target]))==1)
	var a=state.units[shooter];var b=state.units[target]
	return {"kind":kind,"turn":state.turn,"side":state.side,"shooter":shooter,"target":target,"loss":0,"return_loss":0,"reaction":false,"eliminated":false,"attacker_eliminated":false,"from":a.cell.duplicate(),"to":b.cell.duplicate(),"retreat":[],"attacker_retreat":[],"advance":[],"prisoners":0,"attacker_prisoners":0,"old_morale":b.morale,"new_morale":b.morale,"attacker_old_morale":a.morale,"attacker_new_morale":a.morale,"outcome":"exchange","cannon":artillery(shooter),"reaction_cannon":artillery(target)}
func record_retreat(n: int,event: Dictionary,attacker: bool=false) -> void:
	if not alive(n):return
	var flight=retreat(n)
	event["attacker_retreat" if attacker else "retreat"]=flight.route
	event["attacker_prisoners" if attacker else "prisoners"]=flight.prisoners
func finish_combat(event: Dictionary) -> Dictionary:
	var ap_before=int(state.units[event.shooter].prisoners);var bp_before=int(state.units[event.target].prisoners)
	refresh_support()
	event.attacker_prisoners+=int(state.units[event.shooter].prisoners)-ap_before;event.prisoners+=int(state.units[event.target].prisoners)-bp_before
	var a=state.units[event.shooter];var b=state.units[event.target]
	event.new_morale=b.morale;event.attacker_new_morale=a.morale
	event.eliminated=b.strength<=0;event.attacker_eliminated=a.strength<=0
	if event.kind in ["assault","charge"]:state.assaults+=1
	else:state.shots+=1
	state.active=event.shooter if alive(event.shooter) and not a.done else -1
	previous={};state.undo_reason="assault" if event.kind in ["assault","charge"] else "fire";state.events.append(event)
	if fog_enabled():
		refresh_intel();event.fog_names={}
		for side in [0,1]:
			var names=[]
			for n in [event.shooter,event.target]:
				names.append(state.units[n].name_key if int(state.units[n].side)==side else contact(n,side).get("name_key","fog_enemy_generic"))
			event.fog_names[str(side)]=names
	return {"status":"ok","event":event}
func fire(shooter: int,target: int) -> Dictionary:
	var status=fire_status(shooter,target)
	if status!="ok":return {"status":status}
	var intercepted=false
	if fog_enabled():
		physical_lines=true
		var actual=super.fire_status(shooter,target)
		physical_lines=false
		if actual=="blocked_unit":
			var blocker=first_interceptor(shooter,target)
			if blocker>=0:target=blocker;intercepted=true
		elif actual!="ok":return {"status":actual}
	var a=state.units[shooter];var b=state.units[target];var event=combat_event(shooter,target,"fire");var rng=combat_rng()
	if intercepted:event.intercepted=true
	# Both volleys are evaluated from the pre-exchange state, then applied together.
	event.loss=shot_loss(shooter,target,rng)
	if reaction_status(target,shooter)=="ok":
		event.reaction=true;event.return_loss=shot_loss(target,shooter,rng,float(pack.rules.combat.reaction_factor));b.reactions-=1;b.quiet=false;spend_ammo(target)
	a.ap-=int(weapon(shooter).ap);a.done=a.ap<=0;a.quiet=false;a.attacked=true;spend_ammo(shooter)
	apply_losses(target,event.loss);apply_losses(shooter,event.return_loss)
	if alive(target) and b.morale=="routed":record_retreat(target,event)
	if alive(shooter) and a.morale=="routed":record_retreat(shooter,event,true)
	return finish_combat(event)
func assault_status(attacker: int,target: int) -> String:
	if not can_act(attacker) or not alive(target) or attacker==target:return "invalid"
	var a=state.units[attacker];var b=state.units[target]
	if int(a.side)==int(b.side):return "friendly"
	if a.morale=="routed":return "routed"
	if strict_links() and not a.get("command_ok",true) and not a.get("supply_ok",true):return "isolated"
	if not visible_to(int(a.side),target):return "hidden"
	if artillery(attacker):return "artillery"
	if distance(unit_cell(a),unit_cell(b))!=1:return "range"
	if a.get("river_halt",false) or open_river(unit_cell(a),unit_cell(b)):return "river"
	if int(a.ap)<assault_cost(attacker):return "no_ap"
	return "ok"
func assault_power(n: int,defending: bool) -> float:
	var u=state.units[n];var cfg=pack.rules.assault
	var factor_key="assault_defence" if defending else "assault_attack"
	var result=float(u.strength)*formation_factor(n,factor_key)*float(unit_profile(n).get(factor_key,1.0))
	if u.morale=="shaken":result*=float(cfg.shaken_factor)
	elif u.morale=="routed":result*=float(cfg.routed_factor)
	if artillery(n):result*=float(cfg.battery_deployed if u.deployed else cfg.battery_limbered)
	if defending:
		var terrain=str(pack.map.tiles[unit_cell(u)])
		result*=float(unit_profile(n).get("terrain_assault_defence",{}).get(terrain,pack.terrains[terrain].assault_defence))
		if u.get("entrenched",false):result*=float(pack.rules.entrenchment.assault_defence)
	return result
func assault(attacker: int,target: int) -> Dictionary:
	var status=assault_status(attacker,target)
	if status!="ok":return {"status":status}
	var a=state.units[attacker];var b=state.units[target];var cfg=pack.rules.assault;var event=combat_event(attacker,target,"charge" if cavalry(attacker) else "assault");var rng=combat_rng()
	a.ap-=assault_cost(attacker);a.done=a.ap<=0;a.quiet=false;a.attacked=true;a.entrenched=false
	# Defensive volley consumes the same single reaction as return fire.
	if reaction_status(target,attacker)=="ok":
		event.reaction=true;event.return_loss=shot_loss(target,attacker,rng,float(pack.rules.combat.reaction_factor));b.reactions-=1;b.quiet=false;spend_ammo(target)
		apply_losses(attacker,event.return_loss)
	if not alive(attacker) or a.morale=="routed":
		if alive(attacker):record_retreat(attacker,event,true)
		event.outcome="repulsed";return finish_combat(event)
	var attack_power=attack_power_against(attacker,target);var defence_power=defence_power_against(target,attacker)
	var wins=attack_power*rng.randf_range(1.0-float(cfg.variance),1.0+float(cfg.variance))>defence_power
	var target_loss=mini(int(b.strength),maxi(1,roundi(attack_power*float(cfg.loss_rate)*(float(cfg.loser_loss) if wins else 1.0))))
	var attacker_loss=mini(int(a.strength),maxi(1,roundi(defence_power*float(cfg.loss_rate)*(1.0 if wins else float(cfg.loser_loss)))))
	event.loss=target_loss;event.return_loss+=attacker_loss
	apply_losses(target,target_loss);apply_losses(attacker,attacker_loss)
	# Melee can force withdrawal without automatically causing a rout.
	if alive(target) and (b.morale=="routed" or (wins and alive(attacker) and a.morale!="routed")):record_retreat(target,event)
	if alive(attacker) and (a.morale=="routed" or not wins):record_retreat(attacker,event,true)
	var destination=index(Vector2i(event.to[0],event.to[1]))
	if alive(attacker) and a.morale!="routed" and unit_at(destination)<0 and event.attacker_retreat.is_empty():
		event.advance=[unit_cell(a),destination];a.cell=event.to.duplicate();event.outcome="taken"
		capture_objective(destination,int(state.side))
	else:event.outcome="repulsed"
	return finish_combat(event)
func enemy_distance(n: int,pos: int) -> int:
	var result=width+height
	for j in range(state.units.size()):
		if alive(j) and int(state.units[j].side)!=int(state.units[n].side) and visible_to(int(state.units[n].side),j):result=mini(result,distance(pos,unit_cell(state.units[j])))
	return result
func rally_status(n: int) -> String:
	if not can_act(n):return "invalid"
	var u=state.units[n]
	if u.morale=="stable":return "stable"
	if u.rallied:return "rallied"
	if int(u.ap)<rally_cost(n):return "no_ap"
	if enemy_distance(n,unit_cell(u))<int(pack.rules.morale.rally_distance):return "danger"
	return "ok"
func rally(n: int) -> bool:
	if rally_status(n)!="ok":return false
	var u=state.units[n];u.morale="shaken" if u.morale=="routed" else "stable"
	u.cohesion=int(pack.rules.morale.rally_shaken) if u.morale=="shaken" else int(pack.rules.morale.rally_stable)
	u.ap-=rally_cost(n);u.done=u.ap<=0;u.rallied=true;previous={};state.undo_reason="rally"
	if pack.rules.get("support",{}).get("separate_hq",false):refresh_support()
	refresh_intel();return true
# A retreat corridor uses existing enemy ZOC and each unit's legal terrain edges.
# Only routed units without command need a corridor to their own rear.
func retreat_escape(n: int) -> Dictionary:
	var side=int(state.units[n].side);var blocked={};var cfg=pack.rules.support
	for j in range(state.units.size()):
		if not alive(j) or int(state.units[j].side)==side:continue
		var pos=unit_cell(state.units[j]);blocked[pos]=true
		if state.units[j].morale!="routed":
			for next in neighbours(pos):blocked[next]=true
	var distances={};var open=[]
	for pos in range(width*height):
		var c=cell(pos)
		var rear=c.y==int(cfg.rear_rows[side]) if cfg.has("rear_rows") else c.x==int(cfg.rear_columns[side])
		if rear and not blocked.has(pos) and cost(pos)>=0:distances[pos]=0;open.append(pos)
	while not open.is_empty():
		var current=int(open.pop_front())
		for next in neighbours(current):
			if blocked.has(next) or distances.has(next) or cost(next)<0 or not edge_allowed(n,next,current):continue
			distances[next]=int(distances[current])+1;open.append(next)
	return distances
func retreat_route(n: int) -> Array:
	var u=state.units[n];var start=unit_cell(u);var paths={start:[start]};var open=[start]
	var needs_escape=strict_links() and u.morale=="routed" and not u.get("command_ok",true)
	var escape=retreat_escape(n) if needs_escape else {}
	if needs_escape and escape.get(start,-1)==0:return [start]
	var initial_distance=enemy_distance(n,start);var best=-1;var best_score=-INF;var fallback=-1;var fallback_score=-INF
	while not open.is_empty():
		var current=int(open.pop_front());var path=paths[current]
		if path.size()>int(pack.rules.morale.retreat_steps):continue
		for next in neighbours(current):
			if paths.has(next) or cost(next)<0 or not edge_allowed(n,current,next) or (needs_escape and not escape.has(next)):continue
			var occupant=unit_at(next)
			if occupant>=0 and (not support_enabled() or int(state.units[occupant].side)!=int(u.side)):continue
			if not support_enabled() and enemy_distance(n,next)<enemy_distance(n,current):continue
			if open_river(current,next) and occupant>=0:continue
			paths[next]=path+[next]
			if not open_river(current,next):open.append(next)
			if occupant>=0:continue
			var safety=enemy_distance(n,next)
			var score=float(safety)*100.0-float(pack.terrains[pack.map.tiles[next]].fire_received)*10.0-paths[next].size()
			if safety>initial_distance and score>best_score:best=next;best_score=score
			if score>fallback_score:fallback=next;fallback_score=score
	if needs_escape:
		# The starting cell may lie in enemy ZOC, but the exit must be clear.
		var route_best=[];var route_score=INF
		for dest in paths:
			if dest==start or unit_at(dest)>=0 or not escape.has(dest):continue
			var legal=true
			for step in paths[dest].slice(1):
				if not escape.has(step):legal=false;break
			if not legal:continue
			if escape.has(start) and int(escape[dest])>=int(escape[start]):continue
			var score=float(escape[dest])*100.0+paths[dest].size()+float(pack.terrains[pack.map.tiles[dest]].fire_received)
			if score<route_score:route_score=score;route_best=paths[dest]
		return route_best
	if best<0 and support_enabled():best=fallback
	return paths[best] if best>=0 else []
func retreat(n: int) -> Dictionary:
	if strict_links() and alive(n) and state.units[n].morale=="routed":update_support(int(state.units[n].side))
	if fog_enabled():
		for revealed in state.revealed:revealed.erase(n)
	var u=state.units[n];var route=retreat_route(n)
	u.ap=0;u.done=true;u.deployed=false;u.entrenched=false;previous={};state.undo_reason="retreat"
	if route.is_empty() and support_enabled() and u.morale!="routed":
		u.cohesion=maxi(0,int(u.cohesion)-int(pack.rules.support.blocked_retreat_shock))
		if u.cohesion<int(pack.rules.morale.shaken_below):u.morale="shaken"
		return {"route":[],"prisoners":0}
	if route.is_empty():return {"route":[],"prisoners":surrender(n)}
	var dest=cell(route.back());u.cell=[dest.x,dest.y];return {"route":route,"prisoners":0}
func end_side() -> void:
	if state.finished:return
	refresh_support()
	if support_enabled():
		# A cut at either boundary prevents a free refill on immediate reconnection.
		var departing=Support.assess_side(self,int(state.side))
		for n in departing:
			if not departing[n].supply_ok:
				state.units[n].quiet=false;state.units[n].supply_interrupted=true
	if fog_enabled():state.revealed[int(state.side)]=[]
	# Snapshot after outgoing support resolution, before the next turn starts.
	if int(state.side)==1:
		if not state.has("loss_history"):state.loss_history=[]
		state.loss_history.append({"turn":int(state.turn),"losses":[losses(0),losses(1)],"prisoners":[prisoners(0),prisoners(1)]})
	super.end_side()
	if state.finished:return
	arrive_reinforcements()
	var old_supply={}
	if support_enabled():
		for n in range(state.units.size()):old_supply[n]=state.units[n].get("supply_ok",true)
		update_support(int(state.side))
	resolve_surrenders()
	for n in range(state.units.size()):
		var u=state.units[n]
		# Incoming defender receives one reaction for the new opposing turn.
		if int(u.side)!=int(state.side):u.reactions=int(pack.rules.combat.reactions);continue
		if strict_links() and alive(n):
			advance_isolation(n)
			if not alive(n):continue
			u.turn_ap_limit=support_budget(n);u.ap=mini(int(u.ap),int(u.turn_ap_limit));u.done=u.ap<=0
		u.rallied=false;u.river_halt=false
		var resupply_ready=u.quiet
		if relaxed_supply():resupply_ready=not u.get("attacked",false) and not u.get("supply_interrupted",false)
		else:
			for foe in state.units:
				if int(foe.strength)>0 and int(foe.side)!=int(u.side) and distance(unit_cell(u),unit_cell(foe))<=1:resupply_ready=false
		if support_enabled() and alive(n) and not cavalry(n) and u.morale!="routed" and resupply_ready and u.supply_ok and old_supply.get(n,false):
			u.ammo_level=maxi(0,int(u.ammo_level)-1);u.ammo_spent=0
		if alive(n) and u.morale=="shaken" and u.quiet and not (strict_links() and not u.command_ok and not u.supply_ok):
			var recovery=int(pack.rules.morale.quiet_recovery)
			if support_enabled() and not u.command_ok:recovery=roundi(recovery*float(pack.rules.support.isolated_recovery_factor))
			u.cohesion=mini(100,u.cohesion+recovery)
			if u.cohesion>=int(pack.rules.morale.shaken_below):u.morale="stable"
		u.quiet=true;u.attacked=false;u.supply_interrupted=false
		if alive(n) and u.morale=="routed" and (enemy_distance(n,unit_cell(u))<int(pack.rules.morale.rally_distance) or (strict_links() and not u.command_ok)):
			retreat(n)
			if alive(n) and enemy_distance(n,unit_cell(u))>=int(pack.rules.morale.rally_distance):u.ap=max_ap(n);u.done=false
	refresh_support();refresh_intel()
func arrive_reinforcements() -> void:
	state.reinforcements_arrived=0
	for n in range(state.units.size()):
		var u=state.units[n]
		if not u.get("pending",false) or int(u.side)!=int(state.side) or int(u.get("arrival_turn",1))>int(state.turn):continue
		var entry=unit_cell(u);var occupant=unit_at(entry)
		if occupant>=0:
			# V43.1: only an enemy-held entry may use an adjacent replacement.
			if not pack.rules.get("enemy_entry_adjacent_reinforcements",false) or int(state.units[occupant].side)==int(u.side):continue
			var destination=-1;var adjacent=neighbours(entry).duplicate();adjacent.sort()
			for pos in adjacent:
				if unit_at(pos)>=0 or movement_cost(n,pos)<0 or open_river(entry,pos) or not edge_allowed(n,entry,pos):continue
				destination=pos;break
			if destination<0:continue
			u.cell=[cell(destination).x,cell(destination).y]
		u.pending=false;u.strength=int(u.initial_strength);u.ap=max_ap(n);u.done=false
		state.reinforcements_arrived+=1
func losses(side: int) -> int:
	var total=0
	for u in state.units:
		if int(u.side)==side:total+=int(u.casualties)
	return total
func prisoners(side: int) -> int:
	var total=0
	for u in state.units:
		if int(u.side)==side:total+=int(u.prisoners)
	return total
func routed_count(side: int) -> int:
	var total=0
	for u in state.units:
		if int(u.side)==side and int(u.strength)>0 and u.morale=="routed":total+=1
	return total
func unit_index(id: String) -> int:
	for n in range(state.units.size()):
		if state.units[n].id==id:return n
	return -1
func observation(side: int,visible_enemies: Array=[]) -> Dictionary:
	var safe=state.duplicate(true);safe.events=[];safe.shots=0;safe.assaults=0;safe.seed=0;safe.moves=0;safe.units=[];safe.active=-1
	safe.erase("battle_history");safe.erase("loss_history")
	safe.erase("support_events");safe.erase("support_serial");safe.erase("surrender_serial");safe.erase("contacts");safe.erase("revealed");safe.erase("undo_reason")
	if safe.has("command_hq"):
		for group in safe.command_hq.keys():
			var leader=unit_index(str(safe.command_hq[group]))
			if leader<0 or int(state.units[leader].side)!=side:safe.command_hq.erase(group)
	for n in range(state.units.size()):
		var u=state.units[n]
		if not alive(n):continue
		if int(u.side)==side:safe.units.append(u.duplicate(true))
		elif (visible_to(side,n) if fog_enabled() else visible_enemies.has(n)):
			var known=u.duplicate(true);known.ap=0;known.done=true;known.cohesion=100 if u.morale=="stable" else 50;known.rallied=false;known.reactions=int(pack.rules.combat.reactions);known.quiet=false
			if fog_enabled():
				var report=contact(n,side)
				if int(report.get("level",1))<2:known.weapon=weapon(n).get("concealed_as",u.weapon)
				known.strength=int(report.exact_strength) if report.has("exact_strength") else maxi(1,roundi((int(report.low)+int(report.high))/2.0));known.initial_strength=known.strength;known.casualties=0;known.prisoners=0
				known.name_key=report.name_key;known.number=report.number;known.morale="stable" if report.morale=="unknown" else report.morale;known.cohesion=100 if known.morale=="stable" else 50
				known.formation=("none" if artillery(n) or cavalry(n) else "line") if report.formation=="unknown" else report.formation
				known.entrenched=report.entrenched;known.deployed=report.deployed
			for key in ["ammo_level","ammo_spent","supply_ok","command_ok","encircled","command_group","attacked","supply_interrupted","river_halt","is_hq","hq_id","command_distance","command_reason","supply_reason","turn_ap_limit","isolation_turns"]:known.erase(key)
			safe.units.append(known)
	var data=pack.duplicate(true);data.units=safe.units.duplicate(true)
	if fixed_hq():data.rules.support.preferred_hq=safe.get("command_hq",{}).duplicate()
	# A simulation receives only observed units; it cannot recompute hidden truth.
	if fog_enabled():data.rules.fog.enabled=false
	var incoming=[]
	for u in state.units:
		if int(u.side)==side and u.get("pending",false):incoming.append({"id":u.id,"cell":u.cell.duplicate(),"arrival_turn":int(u.get("arrival_turn",1))})
	return {"own_reinforcements":incoming,"pack":data,"state":safe,"observed_cells":vision_cache[side].cells.duplicate() if fog_enabled() else {},"recon_rules":pack.rules.get("fog",{}).duplicate(true) if fog_enabled() else {}}
func validate(s: Dictionary) -> bool:
	if not whole_number(s.get("turn",null)):return false
	# The recovered V42 branch used 'casualties' for the same history field.
	# Validate a normalized copy; never rewrite or discard the user's original save.
	if s.get("loss_history") is Array:
		var legacy_history=false
		for snapshot in s.loss_history:
			if snapshot is Dictionary and snapshot.has("casualties"):
				if snapshot.has("losses") and snapshot.losses!=snapshot.casualties:return false
				legacy_history=true
		if legacy_history:
			s=s.duplicate(true)
			for snapshot in s.loss_history:
				if snapshot is Dictionary and snapshot.has("casualties"):
					snapshot.losses=snapshot.casualties;snapshot.erase("casualties")
	if s.has("loss_history"):
		if not s.loss_history is Array or s.loss_history.size()>int(pack.rules.turns):return false
		var last_snapshot_turn=0
		var previous_totals={"losses":[0,0],"prisoners":[0,0]}
		for snapshot in s.loss_history:
			if not snapshot is Dictionary or not whole_number(snapshot.get("turn",null)):return false
			if int(snapshot.turn)<=last_snapshot_turn or int(snapshot.turn)>int(s.turn) or (int(snapshot.turn)==int(s.turn) and not s.get("finished",false)):return false
			last_snapshot_turn=int(snapshot.turn)
			for key in ["losses","prisoners"]:
				if not snapshot.get(key) is Array or snapshot[key].size()!=2:return false
				for side in [0,1]:
					if not whole_number(snapshot[key][side]) or snapshot[key][side]<previous_totals[key][side]:return false
					var current_total=0
					for u in s.get("units",[]):
						if int(u.get("side",-1))==side:current_total+=int(u.get("casualties" if key=="losses" else "prisoners",0))
					if snapshot[key][side]>current_total:return false
				previous_totals[key]=snapshot[key]
	if s.has("battle_history"):
		if not s.battle_history is Array or s.battle_history.size()>512:return false
		var last_turn=0
		var surrendered_units={}
		for event in s.battle_history:
			if not event is Dictionary or event.get("kind","") not in ["capture","surrender"]:return false
			if not whole_number(event.get("turn",null)) or event.turn<1 or event.turn>s.get("turn",0) or event.turn<last_turn:return false
			if not whole_number(event.get("side",null)) or int(event.side) not in [0,1]:return false
			last_turn=int(event.turn)
			if event.kind=="capture":
				var found=false
				for goal in objective_definitions():
					if goal.id==event.get("objective",null):found=true
				if not found:return false
			else:
				var n=unit_index(str(event.get("unit","")))
				if n<0 or not whole_number(event.get("prisoners",null)) or event.prisoners<0 or event.prisoners>state.units[n].initial_strength:return false
				if int(event.side)!=int(pack.units[n].side) or surrendered_units.has(str(event.unit)):return false
				surrendered_units[str(event.unit)]=true
	if not whole_number(s.get("human_side",-1)) or not whole_number(s.get("ai_style",0)):return false
	for key in ["support_serial","surrender_serial","reinforcements_arrived"]:
		if s.has(key) and (not whole_number(s[key]) or s[key]<0):return false
	if s.has("support_events"):
		if not s.support_events is Array:return false
		for event in s.support_events:
			if not event is Dictionary:return false
			for key in ["serial","turn","side","prisoners"]:
				if not whole_number(event.get(key,null)) or event[key]<0:return false
			if event.get("kind","") not in ["cut","surrender"] or not event.get("unit",null) is String or not event.get("name_key",null) is String:return false
			if not event.get("cell",null) is Array or event.cell.size()!=2:return false
			if not whole_number(event.cell[0]) or not whole_number(event.cell[1]):return false
	if s.get("undo_reason","none") not in ["none","available","capture","turn","rest","deployment","formation","discovery","information","assault","fire","rally","retreat","entrench","surrender"]:return false
	if s.has("completed_turn_limit") and (not whole_number(s.completed_turn_limit) or not s.finished or int(s.completed_turn_limit)!=int(s.turn)):return false
	if not s.get("ai_difficulty","legacy") in ["legacy","easy","medium","hard","normal","Normal","NORMAL","moyen","Moyen","facile","Facile","difficile","Difficile","DIFFICILE"]:return false
	if not s.get("ai_style",0) is int and not s.get("ai_style",0) is float:return false
	if float(s.get("ai_style",0))!=int(s.get("ai_style",0)) or not int(s.get("ai_style",0)) in [0,1]:return false
	if not super.validate(s) or not int(s.get("human_side",-1)) in [0,1]:return false
	if fixed_hq():
		if not s.get("command_hq",null) is Dictionary:return false
		for group in s.command_hq:
			if not group is String or not s.command_hq[group] is String:return false
			var found=false
			for u in s.get("units",[]):
				if str(u.get("id",""))==s.command_hq[group] and str(u.get("command_group",str(u.get("side",-1))))==group:found=true;break
			if not found:return false
	for u in s.units:
		# At most one isolation observation per own turn. No arbitrary new cap.
		if u.has("isolation_turns"):
			if not whole_number(u.isolation_turns) or u.isolation_turns<0 or u.isolation_turns>int(s.turn):return false
		if u.has("turn_ap_limit"):
			if not whole_number(u.turn_ap_limit):return false
			var base=action_budget(u);var limits=[base]
			if strict_links():
				limits.append(maxi(0,base-int(pack.rules.support.get("uncommanded_ap_penalty",4))))
				limits.append(mini(base,int(pack.rules.support.get("isolated_ap",8))))
			# Links may change mid-turn: the stored limit need not match current links.
			if not int(u.turn_ap_limit) in limits or (strict_links() and int(u.ap)>int(u.turn_ap_limit)):return false
		if u.has("pending") and not u.pending is bool:return false
		if u.has("river_halt") and not u.river_halt is bool:return false
		if u.has("command_distance") and (not whole_number(u.command_distance) or u.command_distance< -1):return false
		if u.has("is_hq") and not u.is_hq is bool:return false
		for key in ["morale","cohesion","casualties","prisoners","rallied","reactions","quiet"]:
			if not u.has(key):return false
		for key in ["cohesion","casualties","prisoners","reactions"]:
			if not whole_number(u[key]):return false
		if int(u.strength)==0 and (int(u.ap)!=0 or not u.done):return false
		if not u.morale in ["stable","shaken","routed"] or not u.rallied is bool:return false
		if support_enabled():
			for key in ["ammo_level","ammo_spent"]:
				if not u.get(key,null) is int and not u.get(key,null) is float:return false
				if float(u[key])!=int(u[key]):return false
			if relaxed_supply() and (not u.get("attacked",null) is bool or not u.get("supply_interrupted",null) is bool):return false
			if int(u.ammo_level)<0 or int(u.ammo_level)>2 or int(u.ammo_spent)<0 or int(u.ammo_spent)>=int(pack.rules.support.salvos_per_level):return false
			for key in ["supply_ok","command_ok","encircled"]:
				if not u.get(key,null) is bool:return false
		if u.has("formation"):
			var no_formation=bool(pack.weapons[u.weapon].get("requires_deployment",false)) or pack.weapons[u.weapon].get("unit_type","")=="cavalry"
			if not u.formation is String:return false
			if no_formation and u.formation!="none":return false
			if not no_formation and not pack.rules.get("formations",{}).get("types",{"line":{}}).has(u.formation):return false
		if u.has("entrenched") and not u.entrenched is bool:return false
		if pack.weapons[u.weapon].get("unit_type","")=="cavalry" and bool(u.get("entrenched",false)):return false
		if not u.quiet is bool or int(u.reactions)<0 or int(u.reactions)>int(pack.rules.combat.reactions):return false
		if int(u.cohesion)<0 or int(u.cohesion)>100 or int(u.casualties)<0 or int(u.prisoners)<0:return false
		if u.get("pending",false):
			if int(u.strength)!=0 or int(u.casualties)!=0 or int(u.prisoners)!=0 or int(u.ap)!=0:return false
			if int(u.get("arrival_turn",1))<=1:return false
		elif int(u.strength)+int(u.casualties)+int(u.prisoners)!=int(u.initial_strength):return false
	for event in s.events:
		for key in ["kind","from","to","retreat","attacker_retreat","advance","prisoners","attacker_prisoners","return_loss","reaction","old_morale","new_morale","attacker_old_morale","attacker_new_morale","attacker_eliminated","outcome","cannon","reaction_cannon"]:
			if not event.has(key):return false
		if not event.kind in ["fire","assault","charge"] or not event.reaction is bool:return false
		for key in ["loss","return_loss","prisoners","attacker_prisoners"]:
			if not event[key] is float and not event[key] is int:return false
			if int(event[key])<0:return false
		for key in ["from","to"]:
			if not event[key] is Array or event[key].size()!=2:return false
			if index(Vector2i(int(event[key][0]),int(event[key][1])))<0:return false
		for key in ["retreat","attacker_retreat","advance"]:
			if not event[key] is Array:return false
			for pos in event[key]:
				if int(pos)<0 or int(pos)>=width*height:return false
	if not s.has("assaults") or int(s.assaults)<0:return false
	if fog_enabled():
		if not s.get("contacts",null) is Array or s.contacts.size()!=2 or not s.get("revealed",null) is Array or s.revealed.size()!=2:return false
		for side in [0,1]:
			if not s.contacts[side] is Dictionary or not s.revealed[side] is Array:return false
			for n in s.revealed[side]:
				if int(n)<0 or int(n)>=s.units.size() or int(s.units[int(n)].side)==side:return false
			for key in s.contacts[side]:
				if not str(key).is_valid_int() or int(key)<0 or int(key)>=s.units.size() or int(s.units[int(key)].side)==side:return false
				var report=s.contacts[side][key]
				if not report is Dictionary:return false
				if report.has("exact_strength")!=report.has("exact_power"):return false
				for field in ["exact_strength","exact_power"]:
					if report.has(field):
						if not report[field] is int and not report[field] is float:return false
						if float(report[field])!=int(report[field]) or int(report[field])<1:return false
				if int(report.get("exact_power",1))>10 or int(report.get("exact_strength",1))>int(s.units[int(key)].initial_strength):return false
				for field in ["cell","type","level","low","high","name_key","number","morale","entrenched","formation","deployed","turn"]:
					if not report.has(field):return false
				if not report.cell is Array or report.cell.size()!=2 or index(Vector2i(int(report.cell[0]),int(report.cell[1])))<0:return false
				if not report.type in ["infantry","artillery","cavalry","hq"] or not int(report.level) in [1,2]:return false
				if int(report.low)<1 or int(report.high)<int(report.low) or int(report.turn)<1 or int(report.turn)>int(s.turn):return false
	return true

func entrench_status(n: int) -> String:
	if not can_act(n):return "invalid"
	if cavalry(n):return "cavalry"
	var u=state.units[n]
	if u.morale=="routed":return "routed"
	if u.get("entrenched",false):return "already"
	if pack.map.tiles[unit_cell(u)] in ["water","bridge"]:return "terrain"
	if artillery(n) and not u.deployed:return "limbered"
	if int(u.ap)<int(pack.rules.entrenchment.ap):return "no_ap"
	return "ok"
func entrench(n: int) -> bool:
	if entrench_status(n)!="ok":return false
	var u=state.units[n];u.entrenched=true;u.ap-=int(pack.rules.entrenchment.ap);u.done=u.ap<=0
	state.active=n if not u.done else -1;previous={};state.undo_reason="entrench";refresh_intel();return true
func initial_force(side: int) -> int:
	var total=0
	for u in state.units:
		if int(u.side)==side:total+=int(u.initial_strength)
	return total
func military_losses(side: int) -> int:return losses(side)+prisoners(side)
func battle_turn_limit() -> int:
	return int(state.get("completed_turn_limit",pack.rules.turns)) if state.get("finished",false) else int(pack.rules.turns)
func result_for(side: int) -> Dictionary:
	var cfg=pack.rules.victory
	var totals=[0.0,0.0];var parts=[]
	var max_duration=float(battle_turn_limit())*objective_value_total()
	for camp_index in [0,1]:
		var final_points=float(cfg.final_control)*controlled_value(camp_index)/maxf(1.0,objective_value_total())
		var duration_points=float(cfg.duration)*clampf(float(state.scores[camp_index])/max_duration,0.0,1.0)
		var military_points=float(cfg.military)*clampf(float(military_losses(1-camp_index))/maxi(1,initial_force(1-camp_index)),0.0,1.0)
		parts.append([final_points,duration_points,military_points]);totals[camp_index]=final_points+duration_points+military_points
	var difference=totals[side]-totals[1-side]
	var result={"level":"pending","winner":-1,"margin":absf(difference),"totals":totals,"parts":parts,"reason":"weighted"}
	if not state.finished:return result
	if absf(difference)<=float(cfg.draw_margin):result.level="draw";return result
	result.winner=side if difference>0 else 1-side
	var winner=int(result.winner)
	var advantage=float(military_losses(1-winner))/maxi(1,initial_force(1-winner))-float(military_losses(winner))/maxi(1,initial_force(winner))
	var final_control=not bool(cfg.get("major_requires_objective",false)) or controlled_value(winner)>controlled_value(1-winner)
	var military_edge=advantage+0.00000001>=float(cfg.get("major_loss_advantage",0.0))
	var decisive=absf(difference)>=float(cfg.major_margin) and final_control and military_edge
	result.reason="major" if decisive else "no_objective" if not final_control else "losses_close" if not military_edge else "score_close"
	result.loss_advantage=advantage
	result.level=("major_" if decisive else "minor_")+("win" if difference>0 else "loss")
	return result

func advance_isolation(n: int):
	var cfg=pack.rules.get("support",{})
	if not cfg.has("isolation_surrender_turns"):return
	var u=state.units[n]
	if u.get("command_ok",true) or u.get("supply_ok",true):u.isolation_turns=0;return
	u.isolation_turns=int(u.get("isolation_turns",0))+1
	if int(u.isolation_turns)>=int(cfg.isolation_surrender_turns):
		u.cohesion=mini(int(u.cohesion),int(pack.rules.morale.routed_below)-1);u.morale="routed"
	elif int(u.isolation_turns)>=int(cfg.isolation_shaken_turns):
		u.cohesion=mini(int(u.cohesion),int(pack.rules.morale.shaken_below)-1);u.morale="shaken"

func capture_objective(pos: int,side: int) -> bool:
	var captured=super.capture_objective(pos,side)
	if captured and state.has("battle_history"):
		state.battle_history.append({"kind":"capture","turn":state.turn,"side":side,"objective":objective_at(pos).id})
		if state.battle_history.size()>512:state.battle_history.pop_front()
	return captured

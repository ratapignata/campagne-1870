extends RefCounted
# Decisions consume a sanitized observation only. No access to the live engine.
const Rules=preload("res://war_engine/core/engine.gd")
const Legacy=preload("res://war_engine/ai/legacy_ai.gd")
const Support=preload("res://war_engine/core/support.gd")
const Intel=preload("res://war_engine/core/intel.gd")
var profiles: Dictionary={}
var mean_rng=RandomNumberGenerator.new()
var ranked: Array=[]
var settings: Dictionary={}
var tactic=0
var offensive=false
var urgency=1.0
var signature=""
func choose(view: Dictionary) -> Dictionary:
	var difficulty=str(view.state.get("ai_difficulty","legacy"))
	if difficulty=="legacy" or not profiles.has(difficulty):return Legacy.new().choose(view)
	settings=profiles[difficulty];tactic=int(view.state.get("ai_style",0));ranked=[]
	var e=Rules.new(view.pack,view.state)
	offensive=int(e.pack.ai.get("attacking_side",-1))==int(e.state.side)
	urgency=1.0+0.6*float(e.state.turn)/maxf(1,float(e.pack.rules.turns))
	# Stable variation depends only on public/observed state, never on battle RNG.
	signature=JSON.stringify(view.state)
	var fields={}
	var networks=Support.strict_networks(e,int(e.state.side)) if e.strict_links() else {}
	var observed=view.get("observed_cells",{});var scout_cache={}
	for n in range(e.state.units.size()):
		if not e.can_act(n):continue
		var u=e.state.units[n];var start=e.unit_cell(u);var goal=mission_goal(e,n,fields)
		var field_key=str(u.weapon)+"/"+e.formation(n)+"/"+str(goal)
		if not fields.has(field_key):fields[field_key]=Legacy.new().goal_distances(e,goal,n)
		var field=fields[field_key]
		if e.rally_status(n)=="ok":offer({"kind":"rally","unit":u.id},float(settings.rally)+(40 if u.morale=="routed" else 0))
		if u.morale=="routed":continue
		if e.rest_status(n)=="ok":
			offer({"kind":"rest","unit":u.id},130.0 if int(u.get("ammo_level",0))==2 else 32.0)
		var desired=Legacy.new().desired_formation(e,n,goal)
		if e.formation_status(n,desired)=="ok":
			# Keep enough AP to use the firing formation immediately.
			var nearby=e.enemy_distance(n,start)<=int(e.weapon(n).range)
			var useful=not nearby or int(u.ap)>=int(e.pack.rules.formations.change_ap)+int(e.weapon(n).ap)
			if useful:offer({"kind":"formation","unit":u.id,"formation":desired},float(settings.formation)*(0.55 if offensive and desired=="skirmish" else 1.0))
		for j in range(e.state.units.size()):
			if e.fire_status(n,j)=="ok":
				var loss=mean_loss(e,n,j);var response=mean_loss(e,j,n,float(e.pack.rules.combat.reaction_factor)) if e.reaction_status(j,n)=="ok" else 0.0
				var score=float(settings.fire)+loss*float(settings.damage)-response*float(settings.return_risk)
				if e.unit_cell(e.state.units[j])==goal:score+=float(settings.objective_target)
				score+=float(settings.get("focus_fire",0))*friends_near(e,n,e.unit_cell(e.state.units[j]))
				offer({"kind":"fire","unit":u.id,"target":e.state.units[j].id},score)
			if e.assault_status(n,j)=="ok":
				var response=mean_loss(e,j,n,float(e.pack.rules.combat.reaction_factor)) if e.reaction_status(j,n)=="ok" else 0.0
				var power=e.attack_power_against(n,j)*maxf(0.0,float(u.strength)-response)/maxf(1,float(u.strength))
				var ratio=power/maxf(1,e.defence_power_against(j,n))
				if ratio>=float(settings.charge_ratio if e.cavalry(n) else settings.assault_ratio):
					var score=float(settings.assault)+(30.0*urgency if offensive else 0.0)+minf(2.0,ratio)*float(settings.ratio_value)-response*float(settings.return_risk)
					if e.unit_cell(e.state.units[j])==goal:score+=float(settings.objective_target)
					offer({"kind":"assault","unit":u.id,"target":e.state.units[j].id},score)
		if e.artillery(n) and not u.deployed and int(u.ap)>=int(e.weapon(n).deployment_ap)+int(e.weapon(n).ap):
			u.deployed=true;u.ap-=int(e.weapon(n).deployment_ap)
			if best_fire(e,n)>0:offer({"kind":"deploy","unit":u.id},float(settings.deploy))
			u.deployed=false;u.ap+=int(e.weapon(n).deployment_ap)
		if e.entrench_status(n)=="ok" and (start==goal or (not offensive and e.enemy_distance(n,start)<=int(e.weapon(n).range))):
			offer({"kind":"entrench","unit":u.id},float(settings.entrench_goal if start==goal else settings.entrench))
		# The objective's garrison stays in place; other troops can support it.
		if start==goal and (not e.strict_links() or u.get("command_ok",true) and u.get("supply_ok",true)):continue
		var original_ap=int(u.ap);var original_deployed=bool(u.deployed)
		var current_threat=threat(e,n);var current_cover=float(e.pack.terrains[e.pack.map.tiles[start]].fire_received)
		var current_fire=best_fire(e,n,true)
		if original_deployed:
			if int(u.ap)<=int(e.weapon(n).deployment_ap):continue
			u.deployed=false;u.ap-=int(e.weapon(n).deployment_ap)
		var move_ap=int(u.ap);var reachable=e.reach(n)
		var own_goal=not e.objective_at(goal).is_empty() and e.objective_owner(e.objective_at(goal))==int(u.side)
		var start_goal_distance=e.distance(start,goal)
		var reserve=own_goal and not e.artillery(n) and not e.cavalry(n) and nearest_foe_goal(e,goal)>2
		for dest in reachable.costs:
			if dest==start or e.unit_at(dest)>=0:continue
			var progress=(float(field.get(start,10000))-float(field.get(dest,10000)))/4.0
			var c=e.cell(dest);u.cell=[c.x,c.y];u.ap=move_ap-int(reachable.costs[dest])
			var score=progress*float(settings.progress)*(2.8*urgency if offensive and not e.headquarters(n) else 1.0)
			if not networks.is_empty():
				var links=Support.strict_report(e,n,networks,dest)
				var old_links=Support.strict_report(e,n,networks,start)
				var before=int(old_links.supply_ok)+int(old_links.command_ok);var after=int(links.supply_ok)+int(links.command_ok)
				score+=(after-before)*float(settings.get("link_safety",0))
				if after==0:score-=float(settings.get("link_safety",0))
			if e.headquarters(n) and float(settings.get("hq_safety",0))>0:
				score-=maxf(0,4-e.enemy_distance(n,dest))*float(settings.hq_safety)
				score+=(group_distance(e,n,start)-group_distance(e,n,dest))*float(settings.get("formation_cohesion",0))
			var cover=float(e.pack.terrains[e.pack.map.tiles[dest]].fire_received)
			score+=(current_cover-cover)*float(settings.cover)
			if dest==goal and not own_goal:score+=float(settings.capture)
			var next_fire=best_fire(e,n,true)
			if next_fire>current_fire:score+=(next_fire-current_fire)*float(settings.firing_lane)
			if best_fire(e,n)>0:score+=float(settings.move_then_fire)
			var danger=threat(e,n)
			score+=(current_threat-danger)*float(settings.threat)*(0.35 if offensive and not e.headquarters(n) else 1.0)
			if e.enemy_distance(n,dest)==1:score-=float(settings.adjacent)*(2 if e.artillery(n) else 0.5 if offensive else 1)
			if reserve:
				score+=(absf(start_goal_distance-2.0)-absf(e.distance(dest,goal)-2.0))*float(settings.reserve)
			if int(settings.support)>0 and danger>0:
				score+=minf(2,friends_near(e,n,dest))*float(settings.support)
			if e.cavalry(n) and float(settings.scout)>0 and not observed.is_empty():
				if not scout_cache.has(str(goal)+":"+str(dest)):scout_cache[str(goal)+":"+str(dest)]=scout_gain(e,dest,goal,observed,view.get("recon_rules",{}))
				score+=float(scout_cache[str(goal)+":"+str(dest)])*float(settings.scout)
			# Two modest approaches, without extra damage or access to hidden forces.
			if tactic==1:score+=(current_cover-cover)*float(settings.style_cover)
			if score>float(settings.minimum_move):
				var path=[int(dest)]
				while reachable.parents.has(path[0]):path.push_front(reachable.parents[path[0]])
				offer({"kind":"limber" if original_deployed else "move","unit":u.id,"path":path},score)
			u.cell=[e.cell(start).x,e.cell(start).y];u.ap=move_ap
		u.ap=original_ap;u.deployed=original_deployed
	if ranked.is_empty():return {"kind":"end"}
	ranked.sort_custom(func(a,b):return float(a.score)>float(b.score))
	return ranked[0].action
func offer(action: Dictionary,score: float):
	var noise=float(settings.get("variation",0))
	if noise>0:
		var value=posmod((signature+JSON.stringify(action)).hash(),1001)/1000.0
		score+=(value-0.5)*2*noise
	if score>0:ranked.append({"action":action,"score":score})
func mean_loss(e,a: int,b: int,factor: float=1.0) -> float:
	var w=e.weapon(a);var variance=float(w.variance);w.variance=0.0
	var value=e.shot_loss(a,b,mean_rng,factor);w.variance=variance
	return float(value)
func best_fire(e,n: int,next_turn: bool=false) -> float:
	if e.cavalry(n):return 0.0
	var u=e.state.units[n];var old_ap=int(u.ap);var old_deployed=bool(u.deployed);var old_done=bool(u.done)
	if next_turn:u.ap=e.max_ap(n);u.done=false;u.deployed=e.artillery(n)
	var value=0.0
	for j in range(e.state.units.size()):
		if e.fire_status(n,j)=="ok":value=maxf(value,mean_loss(e,n,j))
	u.ap=old_ap;u.deployed=old_deployed;u.done=old_done
	return value
func threat(e,n: int) -> float:
	if float(settings.threat)==0:return 0.0
	var u=e.state.units[n];var start=e.unit_cell(u);var total=0.0
	for j in range(e.state.units.size()):
		var foe=e.state.units[j]
		if int(foe.side)==int(u.side) or foe.morale=="routed":continue
		var d=e.distance(start,e.unit_cell(foe));var w=e.weapon(j)
		if bool(w.get("can_fire",true)) and d<=int(w.range) and (not e.artillery(j) or foe.deployed) and e.line_clear(e.unit_cell(foe),start):total+=mean_loss(e,j,n)
		if d==1:total+=float(settings.contact_danger)*(1.5 if e.cavalry(j) else 1.0)
	return total
func friends_near(e,n: int,dest: int) -> int:
	var count=0
	for j in range(e.state.units.size()):
		if j!=n and int(e.state.units[j].side)==int(e.state.units[n].side) and e.state.units[j].morale!="routed" and e.distance(dest,e.unit_cell(e.state.units[j]))<=2:count+=1
	return count
func nearest_foe_goal(e,goal: int) -> int:
	var value=999
	for u in e.state.units:
		if int(u.side)!=int(e.state.side):value=mini(value,e.distance(e.unit_cell(u),goal))
	return value
func scout_gain(e,dest: int,goal: int,observed: Dictionary,cfg: Dictionary) -> int:
	if cfg.is_empty():return 0
	var reach=int(cfg.cavalry_range)+(int(cfg.height_bonus) if e.elevation(dest)>0 else 0);var value=0
	for i in range(e.width*e.height):
		if observed.has(str(i)) or e.distance(dest,i)>reach or e.distance(i,goal)>int(settings.scout_goal_radius):continue
		if Intel.clear(e,dest,i):value+=1
	return mini(value,int(settings.scout_cap))

func group_distance(e,n: int,pos: int) -> float:
	var total=0.0;var count=0;var u=e.state.units[n]
	for j in range(e.state.units.size()):
		var other=e.state.units[j]
		if j!=n and e.alive(j) and int(other.side)==int(u.side) and other.get("command_group","")==u.get("command_group",""):
			total+=e.distance(pos,e.unit_cell(other));count+=1
	return total/maxi(1,count)

func mission_goal(e,n: int,fields: Dictionary) -> int:
	if not offensive or e.headquarters(n):return Legacy.new().target_goal(e,n,fields)
	var start=e.unit_cell(e.state.units[n]);var own=e.objective_at(start)
	if not own.is_empty():return start
	var best=-1;var value=-INF
	for o in e.objective_definitions():
		if e.objective_owner(o)==int(e.state.side):continue
		var goal=e.objective_cell(o);var key=str(e.state.units[n].weapon)+"/"+e.formation(n)+"/"+str(goal)
		if not fields.has(key):fields[key]=Legacy.new().goal_distances(e,goal,n)
		if not fields[key].has(start):continue
		# Concentrate toward valuable objectives; never use hidden enemy positions.
		var score=float(o.points)/(3.0+float(fields[key][start])/4.0)
		if score>value:value=score;best=goal
	return best if best>=0 else Legacy.new().target_goal(e,n,fields)

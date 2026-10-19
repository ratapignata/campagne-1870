extends RefCounted
const Rules=preload("res://war_engine/core/engine.gd")
# Only an observation is accepted, never the authoritative engine.
func choose(view: Dictionary) -> Dictionary:
	var e=Rules.new(view.pack,view.state)
	var weights=e.pack.ai;var fields={}
	var best={};var best_score=-INF
	for n in range(e.state.units.size()):
		if not e.can_act(n):continue
		var u=e.state.units[n];var start=e.unit_cell(u);var goal=target_goal(e,n,fields);var field=goal_distances(e,goal,n)
		if e.rally_status(n)=="ok":
			var score=float(weights.rally)+(40 if u.morale=="routed" else 0)
			if score>best_score:best_score=score;best={"kind":"rally","unit":u.id}
		if u.morale=="routed":continue
		var desired=desired_formation(e,n,goal)
		if e.formation_status(n,desired)=="ok":
			var score=float(weights.get("formation_priority",86))
			if score>best_score:best_score=score;best={"kind":"formation","unit":u.id,"formation":desired}
		for j in range(e.state.units.size()):
			if e.fire_status(n,j)!="ok":continue
			var foe=e.state.units[j]
			var score=float(weights.fire)+(45 if e.unit_cell(foe)==goal else 0)+(15 if e.artillery(j) else 0)+(12 if foe.morale=="shaken" else 0)
			score*=e.formation_factor(n,"fire")
			if score>best_score:best_score=score;best={"kind":"fire","unit":u.id,"target":foe.id}
		for j in range(e.state.units.size()):
			if e.assault_status(n,j)!="ok":continue
			var foe=e.state.units[j]
			var power=e.attack_power_against(n,j)
			if e.cavalry(n) and e.reaction_status(j,n)=="ok":
				var loss=e.shot_loss(j,n,e.combat_rng(),float(e.pack.rules.combat.reaction_factor))
				power*=maxf(0.0,float(u.strength-loss)/maxi(1,int(u.strength)))
			var ratio=power/maxf(1,e.defence_power_against(j,n))
			if ratio<float(weights.get("charge_min_ratio",weights.assault_min_ratio) if e.cavalry(n) else weights.assault_min_ratio):continue
			var score=float(weights.assault)+(45 if e.unit_cell(foe)==goal else 0)+(20 if foe.morale=="routed" else 0)
			if score>best_score:best_score=score;best={"kind":"assault","unit":u.id,"target":foe.id}
		if e.artillery(n) and not u.deployed and int(u.ap)>=int(e.weapon(n).deployment_ap)+int(e.weapon(n).ap):
			u.deployed=true
			for j in range(e.state.units.size()):
				if e.fire_status(n,j)=="ok" and 85.0>best_score:best_score=85.0;best={"kind":"deploy","unit":u.id}
			u.deployed=false
		if e.entrench_status(n)=="ok" and (start==goal or e.enemy_distance(n,start)<=int(e.weapon(n).range)):
			var score=float(weights.entrench_objective if start==goal else weights.entrench_position)
			if score>best_score:best_score=score;best={"kind":"entrench","unit":u.id}
		if start==goal:continue
		var was_deployed=bool(u.deployed)
		if was_deployed:
			if int(u.ap)<=int(e.weapon(n).deployment_ap):continue
			u.deployed=false;u.ap-=int(e.weapon(n).deployment_ap)
		var info=e.reach(n)
		for dest in info.costs:
			if dest==start or e.unit_at(dest)>=0:continue
			var progress=(float(field.get(start,10000))-float(field.get(dest,10000)))/4.0
			var score=progress*float(weights.goal_progress)+(1.0-float(e.pack.terrains[e.pack.map.tiles[dest]].fire_received))*float(weights.cover)
			if dest==goal:score+=float(weights.capture)
			if e.enemy_distance(n,dest)==1:score-=float(weights.adjacent_threat)*(2 if e.artillery(n) else 1)
			var c=e.cell(dest);u.cell=[c.x,c.y]
			var firing_lane=false
			for j in range(e.state.units.size()):
				var foe=e.state.units[j]
				if int(foe.side)==int(u.side):continue
				var enemy_pos=e.unit_cell(foe)
				if e.distance(dest,enemy_pos)<=int(e.weapon(n).range) and e.line_clear(dest,enemy_pos):firing_lane=true;break
			u.cell=[e.cell(start).x,e.cell(start).y]
			if firing_lane:score+=float(weights.firing_position)*(1.6 if e.artillery(n) else 1.0)
			if score>best_score and score>0:
				var path=[int(dest)]
				while info.parents.has(path[0]):path.push_front(info.parents[path[0]])
				best_score=score;best={"kind":"limber" if was_deployed else "move","unit":u.id,"path":path}
		if was_deployed:u.deployed=true;u.ap+=int(e.weapon(n).deployment_ap)
	return best if not best.is_empty() else {"kind":"end"}
func goal_distances(e,goal: int,n: int=-1) -> Dictionary:
	var costs={goal:0};var open=[goal]
	while not open.is_empty():
		var best=0
		for k in range(1,open.size()):
			if costs[open[k]]<costs[open[best]]:best=k
		var current=int(open[best]);open.remove_at(best)
		for next in e.neighbours(current):
			if e.cost(next)<0:continue
			var step=e.step_cost(n,next,current)
			if step<0:continue
			var total=int(costs[current])+maxi(1,step)
			if not costs.has(next) or total<int(costs[next]):
				costs[next]=total
				if not open.has(next):open.append(next)
	return costs

func desired_formation(e,n: int,goal: int=-1) -> String:
	if e.artillery(n) or e.cavalry(n) or not e.pack.rules.has("formations"):return e.formation(n)
	var u=e.state.units[n];var pos=e.unit_cell(u);var nearest=e.enemy_distance(n,pos);var cfg=e.pack.ai
	if goal<0:goal=target_goal(e,n)
	if nearest<=1:return "line"
	if nearest<=int(e.weapon(n).range)+1:
		var exposed=float(e.pack.terrains[e.pack.map.tiles[pos]].fire_received)>=float(cfg.formation_cover_threshold)
		return "skirmish" if (not e.objective_at(pos).is_empty() or exposed) and not u.entrenched else "line"
	if nearest>int(cfg.formation_safe_distance) and e.distance(pos,goal)>int(cfg.formation_column_goal_distance) and not u.entrenched:
		if int(u.ap)>=int(cfg.formation_column_min_ap) or e.formation(n)=="column":return "column"
	return "line" if e.formation(n)=="column" else e.formation(n)

func target_goal(e,n: int,fields: Dictionary={}) -> int:
	var u=e.state.units[n];var start=e.unit_cell(u)
	if e.headquarters(n):
		# Escort stays behind its own formation, using observed enemies only.
		var center=Vector2.ZERO;var count=0
		for j in range(e.state.units.size()):
			var other=e.state.units[j]
			if e.alive(j) and int(other.side)==int(u.side) and not e.headquarters(j) and other.get("command_group","")==u.get("command_group",""):
				center+=Vector2(float(other.cell[0]),float(other.cell[1]));count+=1
		if count==0:return start
		center/=count
		var rear=int(e.pack.rules.support.rear_rows[int(u.side)])
		center.y+=signf(rear-center.y)*3.0
		var goal=start;var value=INF
		for i in range(e.width*e.height):
			if e.cost(i)<0 or (e.unit_at(i)>=0 and i!=start):continue
			var c=e.cell(i);var score=Vector2(c.x,c.y).distance_squared_to(center)
			score+=maxf(0,4-e.enemy_distance(n,i))*18.0
			if score<value:value=score;goal=i
		return goal
	if e.objective_definitions().size()==1:return e.objective()
	if not e.objective_at(start).is_empty():return start
	var best=e.objective();var best_score=-INF
	for o in e.objective_definitions():
		var goal=e.objective_cell(o);var key=str(u.weapon)+"/"+e.formation(n)+"/"+str(goal)
		if not fields.has(key):fields[key]=goal_distances(e,goal,n)
		var field=fields[key]
		if not field.has(start):continue
		var own=e.objective_owner(o)==int(u.side)
		var nearby=0
		for other in e.state.units:
			if other.id!=u.id and int(other.side)==int(u.side) and e.distance(e.unit_cell(other),goal)<=2:nearby+=1
		var score=float(o.points)*(1.0 if own else 3.0)/(3.0+float(field[start])/4.0)/(1.0+nearby*0.4)
		if score>best_score:best_score=score;best=goal
	return best

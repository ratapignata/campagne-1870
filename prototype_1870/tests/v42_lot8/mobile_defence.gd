extends RefCounted
const Rules=preload("res://war_engine/ai/planning_engine.gd")
# Test opponent only. Uses the same sanitized observation as the production AI.
# Repositions towards objectives, withdraws damaged units and counterattacks.
func choose(view: Dictionary) -> Dictionary:
	var e=Rules.new(view.pack,view.state)
	for n in range(e.state.units.size()):
		if not e.can_act(n):continue
		var u=e.state.units[n];var start=e.unit_cell(u)
		if e.rally_status(n)=="ok" and u.morale=="routed":return {"kind":"rally","unit":u.id}
		if u.morale=="routed":continue
		var damaged=float(u.strength)<float(u.initial_strength)*0.55 or u.morale=="shaken"
		var enemy_distance=e.enemy_distance(n,start)
		var withdrawing=damaged and enemy_distance<4
		if not withdrawing:
			for j in range(e.state.units.size()):
				if e.fire_status(n,j)=="ok":return {"kind":"fire","unit":u.id,"target":e.state.units[j].id}
				if not e.headquarters(n) and not e.artillery(n) and e.assault_status(n,j)=="ok" and e.attack_power_against(n,j)>1.35*e.defence_power_against(j,n):
					return {"kind":"assault","unit":u.id,"target":e.state.units[j].id}
		var goal=start;var nearest=100000
		for objective in e.objective_definitions():
			var cell=e.objective_cell(objective);var distance=e.distance(start,cell)
			if distance<nearest:nearest=distance;goal=cell
		if e.artillery(n) and not u.deployed and int(u.ap)>=int(e.weapon(n).deployment_ap):
			u.deployed=true;var useful=false
			for j in range(e.state.units.size()):
				if e.fire_status(n,j)=="ok":useful=true;break
			u.deployed=false
			if useful and not withdrawing:return {"kind":"deploy","unit":u.id}
		if e.artillery(n) and u.deployed:
			if withdrawing and int(u.ap)>int(e.weapon(n).deployment_ap):return {"kind":"limber","unit":u.id}
			continue
		var reach=e.reach(n);var best=start;var gain=0.0
		for cell in reach.costs:
			if cell==start or e.unit_at(cell)>=0:continue
			var value=float(e.distance(start,goal)-e.distance(cell,goal))*10.0
			var distance=e.enemy_distance(n,cell)
			if withdrawing:value=float(mini(5,distance)-mini(5,enemy_distance))*20.0-absf(float(e.distance(cell,goal)-e.distance(start,goal)))
			elif damaged and distance<3:continue
			elif distance==1 and not e.cavalry(n):value-=15.0
			if e.headquarters(n) and distance<4:continue
			value-=float(reach.costs[cell])*0.15
			if value>gain:gain=value;best=cell
		if best!=start:
			var path=[best]
			while reach.parents.has(path[0]):path.push_front(reach.parents[path[0]])
			return {"kind":"move","unit":u.id,"path":path}
		if e.rest_status(n)=="ok" and int(u.get("ammo_level",0))==2:return {"kind":"rest","unit":u.id}
		if e.entrench_status(n)=="ok" and e.distance(start,goal)<=2:return {"kind":"entrench","unit":u.id}
	return {"kind":"end"}

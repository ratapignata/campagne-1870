extends RefCounted
# Candidate module only. Not wired into the released engine or saved games.
# Entries: id, weight > 0, owner (-1/0/1), held [French rounds, coalition rounds].
static func evaluate(objectives: Array, losses: Array, turns: int, cfg: Dictionary, perspective: int=0) -> Dictionary:
	if turns<1 or not perspective in [0,1] or objectives.is_empty() or losses.size()!=2:return {"error":"input"}
	var ids={};var weight=0.0;var control=[0.0,0.0];var held=[0.0,0.0]
	for o in objectives:
		if not o is Dictionary:return {"error":"objective"}
		for key in ["id","weight","owner","held"]:
			if not o.has(key):return {"error":"objective"}
		if str(o.id).is_empty() or ids.has(str(o.id)) or not is_finite(float(o.weight)) or float(o.weight)<=0 or not o.owner in [-1,0,1]:return {"error":"objective"}
		if not o.held is Array or o.held.size()!=2:return {"error":"duration"}
		for n in o.held:
			if not is_finite(float(n)) or float(n)<0 or float(n)!=floor(float(n)):return {"error":"duration"}
		if float(o.held[0])+float(o.held[1])>turns:return {"error":"duration"}
		ids[str(o.id)]=true;weight+=float(o.weight)
		if int(o.owner)>=0:control[int(o.owner)]+=float(o.weight)
		for side in [0,1]:held[side]+=float(o.held[side])*float(o.weight)
	for loss in losses:
		if not is_finite(float(loss)) or float(loss)<0 or float(loss)>1:return {"error":"losses"}
	var parts=[];var totals=[0.0,0.0]
	for side in [0,1]:
		var p=[float(cfg.final_control)*control[side]/weight,float(cfg.duration)*held[side]/(turns*weight),float(cfg.military)*float(losses[1-side])]
		parts.append(p);totals[side]=p[0]+p[1]+p[2]
	var delta=float(totals[perspective])-float(totals[1-perspective])
	var result={"level":"draw","winner":-1,"parts":parts,"totals":totals,"control":control,"reason":"draw"}
	if absf(delta)<=float(cfg.draw_margin):return result
	var winner=perspective if delta>0 else 1-perspective
	var objective_edge=not bool(cfg.major_requires_objective) or control[winner]>control[1-winner]
	var military_edge=float(losses[1-winner])-float(losses[winner])+0.00000001>=float(cfg.major_loss_advantage)
	var decisive=absf(delta)>=float(cfg.major_margin) and objective_edge and military_edge
	result.winner=winner
	result.level=("major_" if decisive else "minor_")+("win" if delta>0 else "loss")
	result.reason="major" if decisive else "objectives" if not objective_edge else "losses" if not military_edge else "margin"
	return result

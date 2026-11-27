extends RefCounted
# Priority orders use the sanitized planning engine and the real gun/AP/LOS rules.
# No extra shots, free deployment, ammunition, hidden target or live-state access.
static func choose(e,defence) -> Dictionary:
 var best={};var value=-INF;var rng=RandomNumberGenerator.new()
 for n in range(e.state.units.size()):
  if not e.can_act(n) or not e.artillery(n):continue
  var u=e.state.units[n];var start=e.unit_cell(u)
  if u.morale=="routed" or defence.needs_withdrawal(e,n,start) or e.enemy_distance(n,start)<=1:continue
  var deployed=bool(u.deployed);var ap=int(u.ap);var done=bool(u.done)
  if not deployed:
   if ap<int(e.weapon(n).deployment_ap):continue
   u.deployed=true;u.ap=e.max_ap(n);u.done=false
  for j in range(e.state.units.size()):
   if e.fire_status(n,j)!="ok":continue
   var response=0.0
   if e.reaction_status(j,n)=="ok":
    var w=e.weapon(j);var variance=w.variance;w.variance=0.0
    response=e.shot_loss(j,n,rng,float(e.pack.rules.combat.reaction_factor));w.variance=variance
   if response>=float(u.strength)*0.5:continue
   var target=e.state.units[j];var score=defence.target_value(e,n,j)
   score+=minf(80.0,float(target.strength)/40.0)
   if e.artillery(j):score+=40.0
   if target.morale=="shaken":score+=20.0
   if deployed:score+=500.0
   else:score+=200.0
   score-=response
   if score>value:
    value=score;best={"kind":"fire" if deployed else "deploy","unit":u.id}
    if deployed and int(u.get("ammo_level",0))==2 and e.rest_status(n)=="ok":best.kind="rest"
   if score==value and best.get("unit","")==u.id and deployed and best.kind=="fire":best.target=target.id
  u.ap=ap;u.deployed=deployed;u.done=done
 return best

extends RefCounted
const Support=preload("res://war_engine/core/support.gd")
# Tactical priorities only. Receives the same sanitized planning engine as the AI.
# No live state, unseen enemy, combat modifier or persistent save field.
var rear_targets: Dictionary={}
var guards: Dictionary={}
var assignments: Dictionary={}
var reserves: Dictionary={}
var priorities: Dictionary={}
var nearest: Dictionary={}
var goals: Array=[]
var garrisons: Dictionary={}
var networks: Dictionary={}
var blockers: Dictionary={}
var exits: Dictionary={}
var risks: Dictionary={}
var threats: Array=[]
var origin_links: Dictionary={}
func prepare(e,links: Dictionary={}):
 assignments={};reserves={};priorities={};nearest={};goals=e.objective_definitions();garrisons={}
 networks=links;blockers={};exits={};risks={};threats=[];origin_links={};rear_targets={};guards={}
 if not networks.is_empty():
  blockers=Support.link_blockers(e,int(e.state.side))
  for n in range(e.state.units.size()):
   if int(e.state.units[n].side)!=int(e.state.side) and e.state.units[n].morale!="routed":threats.append(n)
   elif int(e.state.units[n].side)==int(e.state.side):
    var u=e.state.units[n]
    var predicted=Support.strict_report(e,n,networks)
    origin_links[n]={"pos":e.unit_cell(u),"supply_ok":u.get("supply_ok",true),"command_ok":u.get("command_ok",true),"encircled":u.get("encircled",false),"unknown_supply":predicted.supply_ok and not u.get("supply_ok",true),"unknown_command":predicted.command_ok and not u.get("command_ok",true),"unknown_encirclement":not predicted.encircled and u.get("encircled",false)}
 var infantry=[];var slots={}
 for goal in goals:
  var pos=e.objective_cell(goal);var pressure=0.0;var support=0.0
  for k in range(e.state.units.size()):
   var other=e.state.units[k]
   if other.morale=="routed" or e.headquarters(k):continue
   var d=e.distance(e.unit_cell(other),pos)
   if int(other.side)!=int(e.state.side):
    if d<=5:pressure+=float(other.strength)*(1.0 if d<=2 else 0.4)
   elif not e.artillery(k) and not e.cavalry(k) and d<=3:support+=float(other.strength)
  var priority=float(goal.points)+minf(4.0,pressure/1500.0)
  if e.objective_owner(goal)!=int(e.state.side):priority*=0.35 if pressure>support*1.1 else 0.8
  priorities[pos]=priority;slots[pos]=0
 for n in range(e.state.units.size()):
  var u=e.state.units[n]
  if int(u.side)!=int(e.state.side) or u.morale=="routed" or e.headquarters(n) or e.artillery(n) or e.cavalry(n):continue
  var start=e.unit_cell(u);var own=e.objective_at(start)
  if not own.is_empty() and e.objective_owner(own)==int(u.side):assignments[n]=start;garrisons[n]=start;slots[start]+=1
  else:infantry.append(n)
 infantry.sort_custom(func(a,b):
  var da=nearest_goal_distance(e,e.unit_cell(e.state.units[a]));var db=nearest_goal_distance(e,e.unit_cell(e.state.units[b]))
  return da<db if da!=db else str(e.state.units[a].id)<str(e.state.units[b].id))
 # Give every held objective a first infantry mission before allocating the
 # remaining mass. An artillery/cavalry token alone is not an infantry screen.
 var sectors=goals.duplicate();sectors.sort_custom(func(a,b):return float(priorities[e.objective_cell(a)])>float(priorities[e.objective_cell(b)]))
 for objective in sectors:
  var anchor=e.objective_cell(objective)
  if e.objective_owner(objective)!=int(e.state.side) or int(slots[anchor])>0 or infantry.is_empty():continue
  var chosen=int(infantry[0]);var best=10000
  for n in infantry:
   var distance=e.distance(e.unit_cell(e.state.units[n]),anchor)
   if distance<best:best=distance;chosen=n
  assignments[chosen]=anchor;garrisons[chosen]=anchor;slots[anchor]+=1;infantry.erase(chosen)
 for n in infantry:
  var start=e.unit_cell(e.state.units[n]);var chosen=-1;var best=-INF
  for goal in goals:
   var pos=e.objective_cell(goal);var score=float(priorities[pos])/(2.0+0.6*e.distance(start,pos))/(1.0+float(slots[pos])*0.45)
   if score>best:best=score;chosen=pos
  if chosen>=0:
   assignments[n]=chosen
   # A reserve is released as soon as an observed enemy reaches the sector.
   reserves[n]=int(slots[chosen])>=3 and int(slots[chosen])%3==0 and enemy_distance(e,chosen)>3
   slots[chosen]+=1
 for n in range(e.state.units.size()):
  var u=e.state.units[n]
  if int(u.side)!=int(e.state.side) or e.headquarters(n) or assignments.has(n):continue
  var chosen=-1;var best=-INF
  for goal in goals:
   var pos=e.objective_cell(goal);var score=float(priorities[pos])/(3.0+e.distance(e.unit_cell(u),pos))
   if score>best:best=score;chosen=pos
  if chosen>=0:assignments[n]=chosen
 protect_rear(e)
 intercept_penetrations(e)

# These are planning estimates from observed enemies, not changes to ZOC,
# logistics or movement. The caller still uses reach()/step_cost() for each order.
func safe_exits(e,n: int,pos: int) -> int:
 if networks.is_empty():return 6
 var key=str(e.state.units[n].weapon)+":"+str(pos)
 if exits.has(key):return int(exits[key])
 var count=0
 for next in e.neighbours(pos):
  if blockers.has(next) or not networks.escape.has(next) or e.step_cost(n,pos,next)<0:continue
  var occupant=e.unit_at(next)
  if occupant<0 or int(e.state.units[occupant].side)==int(e.state.side):count+=1
 exits[key]=count;return count

func encirclement_risk(e,n: int,pos: int) -> float:
 if networks.is_empty():return 0.0
 var key=str(n)+":"+str(pos)
 if risks.has(key):return float(risks[key])
 var rear=int(e.pack.rules.support.rear_rows[int(e.state.side)])
 var rear_distance=absi(e.cell(pos).y-rear);var enemies=0;var behind=0;var contact=0;var enemy_force=0.0;var reference_foe=-1;var strongest=0.0
 for j in threats:
  var other=e.unit_cell(e.state.units[j]);var distance=e.distance(pos,other)
  if distance<=3:
   enemies+=1;var power=e.attack_power_against(j,n);enemy_force+=power
   if power>strongest:strongest=power;reference_foe=j
  if distance<=1:contact+=1
  if distance<=4 and absi(e.cell(other).y-rear)<rear_distance:behind+=1
 var links=Support.strict_report(e,n,networks,pos)
 # Own reported cuts are permitted information even when their cause is hidden.
 # Hypothetical destinations remain estimates, rechecked after each real move.
 if origin_links.has(n):
  # A hidden cause does not disappear just because a hypothetical step was
  # made. Wait for the real support update to confirm a restored connection.
  links.supply_ok=links.supply_ok and not origin_links[n].unknown_supply
  links.command_ok=links.command_ok and not origin_links[n].unknown_command
  links.encircled=links.encircled or origin_links[n].unknown_encirclement
  if int(origin_links[n].pos)==pos:
   links.supply_ok=links.supply_ok and origin_links[n].supply_ok
   links.command_ok=links.command_ok and origin_links[n].command_ok
   links.encircled=links.encircled or origin_links[n].encircled
 var risk=0.0
 if not links.supply_ok:risk+=1.5
 if not links.command_ok and not links.supply_ok:risk+=2.0
 if links.encircled:risk+=3.0
 # A lone frontal opponent must not make a defended strongpoint flee.
 var defenders=holding_power(e,n,reference_foe,pos)
 for j in range(e.state.units.size()):
  var ally=e.state.units[j]
  if j!=n and int(ally.side)==int(e.state.side) and ally.morale!="routed" and not e.headquarters(j) and not e.artillery(j) and e.distance(pos,e.unit_cell(ally))<=2:defenders+=holding_power(e,j,reference_foe,e.unit_cell(ally))
 var narrow=safe_exits(e,n,pos)<=1
 if behind>0 and enemies>=2 and (enemy_force>=defenders*0.9 or narrow):
  risk+=1.5+minf(2,behind)*0.5
  if narrow:risk+=1.5
 if contact>=2:risk+=1.0
 risks[key]=risk;return risk

func holding_power(e,n: int,attacker: int,pos: int) -> float:
 # Read the existing combat forecast, including terrain, formations, morale,
 # entrenchment and variant B. This adds no modifier to the real battle.
 var power=e.defence_power_against(n,attacker)
 if origin_links.has(n) and pos!=int(origin_links[n].pos) and e.state.units[n].get("entrenched",false):power/=float(e.pack.rules.entrenchment.assault_defence)
 return power

func needs_withdrawal(e,n: int,pos: int) -> bool:
 var threshold=2.5;var objective=e.objective_at(pos)
 var u=e.state.units[n]
 if e.artillery(n) and battery_exposed(e,n,pos):return true
 var at_origin=not origin_links.has(n) or int(origin_links[n].pos)==pos
 if at_origin and not objective.is_empty() and e.objective_owner(objective)==int(e.state.side) and u.get("command_ok",true) and u.get("supply_ok",true) and not u.get("encircled",false):
  if int(objective.points)>=3 or safe_exits(e,n,pos)>=2:return false
 # Give a valuable, still defensible strongpoint time to receive reserves.
 # A narrowing exit (risk >=4), real enclosure, or a second isolation count
 # still releases it before the existing third-count consequences.
 if int(u.get("isolation_turns",0))>=1 and not u.get("command_ok",true) and not u.get("supply_ok",true):
  if objective.is_empty() or int(objective.points)<3 or int(u.isolation_turns)>=2 or u.get("encircled",false):return true
 if not objective.is_empty() and e.objective_owner(objective)==int(e.state.side) and int(e.state.units[n].get("isolation_turns",0))<2:threshold+=maxi(0,int(objective.points)-1)*0.75
 return encirclement_risk(e,n,pos)>=threshold

# Release a real reserve toward a visible penetration at the fixed supply entry.
# Do not make infantry chase a moving HQ away from its defended objective.
func protect_rear(e):
 if networks.is_empty():return
 var anchors=[]
 for source in e.pack.rules.support.supply_sources[int(e.state.side)]:anchors.append({"pos":e.index(Vector2i(int(source[0]),int(source[1]))),"front":-1.0})
 var guards={};var protected_anchors=[]
 for entry in anchors:
  var anchor=int(entry.pos);var penetration=false
  if enemy_distance(e,anchor)>3:continue
  for j in threats:
   var pos=e.unit_cell(e.state.units[j])
   if e.distance(pos,anchor)<=3 and (float(entry.front)<0 or float(e.cell(pos).y)<float(entry.front)-1.0):penetration=true;break
  if not penetration:continue
  var covered=false
  for other in protected_anchors:
   if e.distance(anchor,int(other))<=2:covered=true;break
  if covered:continue
  var screen=0
  for n in assignments:
   var u=e.state.units[n]
   if not e.artillery(n) and not e.cavalry(n) and not e.headquarters(n) and u.morale!="routed" and e.distance(e.unit_cell(u),anchor)<=2:screen+=1
  if screen>=2:continue
  var chosen=-1;var best=10000
  for n in assignments:
   var u=e.state.units[n];var pos=e.unit_cell(u)
   if guards.has(n) or garrisons.has(n) or not e.can_act(n) or e.artillery(n) or e.cavalry(n) or e.headquarters(n) or u.morale=="routed" or needs_withdrawal(e,n,pos):continue
   if not e.objective_at(pos).is_empty() or float(u.strength)<float(u.initial_strength)*0.4:continue
   var distance=e.distance(pos,anchor)
   if distance<=5 and distance<best:chosen=n;best=distance
  if chosen>=0:assignments[chosen]=anchor;reserves[chosen]=false;guards[chosen]=true;protected_anchors.append(anchor)
func nearest_goal_distance(e,pos: int) -> int:
 var result=10000
 for goal in goals:result=mini(result,e.distance(pos,e.objective_cell(goal)))
 return result
func goal(n: int) -> int:return int(assignments.get(n,-1))
func enemy_distance(e,pos: int) -> int:
 if nearest.has(pos):return int(nearest[pos])
 var distance=10000
 for u in e.state.units:
  if int(u.side)!=int(e.state.side) and u.morale!="routed":distance=mini(distance,e.distance(pos,e.unit_cell(u)))
 nearest[pos]=distance;return distance
func position_value(e,n: int,pos: int,anchor: int) -> float:
 var terrain=e.pack.terrains[e.pack.map.tiles[pos]];var d=e.distance(pos,anchor);var rear=int(e.pack.rules.support.rear_rows[int(e.state.side)])
 var reserve=e.cavalry(n) or bool(reserves.get(n,false))
 var value=-absf(float(d)-2.0)*18.0 if reserve else -minf(6,d)*16.0
 value+=(1.0-float(terrain.fire_received))*90.0+(float(terrain.assault_defence)-1.0)*45.0
 if reserve and abs(e.cell(pos).y-rear)<abs(e.cell(anchor).y-rear):value+=25.0
 if e.artillery(n):value+=minf(2,e.elevation(pos))*14.0
 elif not reserve:
  var foe=enemy_distance(e,pos)
  if foe==int(e.weapon(n).range):value+=20.0
  elif foe==1:value-=24.0
 return value
func fallback_distance(e,n: int,pos: int) -> int:
 var best=10000
 for ally in origin_links:
  if int(ally)!=n and (origin_links[ally].supply_ok or origin_links[ally].command_ok):best=mini(best,e.distance(pos,int(origin_links[ally].pos)))
 if best==10000:
  for source in e.pack.rules.support.supply_sources[int(e.state.side)]:best=mini(best,e.distance(pos,e.index(Vector2i(int(source[0]),int(source[1])))))
 return best
func movement(e,n: int,start: int,dest: int,anchor: int,current_fire: float,next_fire: float,current_threat: float,danger: float,restores_link: bool) -> float:
 if anchor<0:return 0.0
 var risk_before=encirclement_risk(e,n,start);var risk_after=encirclement_risk(e,n,dest)
 var withdrawing=needs_withdrawal(e,n,start)
 var escape_value=(risk_before-risk_after)*140.0 if withdrawing or needs_withdrawal(e,n,dest) else 0.0
 if withdrawing:
  var travel=e.distance(start,dest)
  # All sufficiently safe fallback cells get the same escape priority. The
  # existing cover/firing-lane scores and this distance cost then choose a
  # local second line instead of rewarding the deepest possible retreat.
  if risk_after<risk_before and risk_after<=2.0 and safe_exits(e,n,dest)>=2:escape_value=300.0-float(travel)*32.0
  elif risk_after<risk_before:escape_value=(risk_before-risk_after)*80.0+60.0-float(travel)*20.0
  elif risk_after<=risk_before and fallback_distance(e,n,dest)<fallback_distance(e,n,start):escape_value=260.0-float(travel)*24.0
  if restores_link:escape_value+=100.0
  if int(e.state.units[n].get("isolation_turns",0))>=2 and escape_value>0:escape_value+=120.0
 if e.artillery(n) and battery_exposed(e,n,start):
  escape_value+=clampf(float(enemy_distance(e,dest)-enemy_distance(e,start)),0.0,3.0)*90.0
 if e.headquarters(n):
  var separation=minf(5,enemy_distance(e,dest))-minf(5,enemy_distance(e,start))
  return escape_value+separation*70.0
 var u=e.state.units[n];var before=float(e.pack.terrains[e.pack.map.tiles[start]].fire_received);var after=float(e.pack.terrains[e.pack.map.tiles[dest]].fire_received)
 # Keep a protected firing line unless a safer move, better lane or liaison
 # restoration justifies leaving it. Entrenchment is lost by a real move.
 if not withdrawing and not restores_link and current_fire>0 and before<=0.65 and after>=before and next_fire<=current_fire and danger>=current_threat:return -INF
 var score=position_value(e,n,dest,anchor)-position_value(e,n,start,anchor)
 score+=escape_value
 if u.get("entrenched",false) and not restores_link and not withdrawing:score-=70.0
 if next_fire>0 and current_fire<=0:score+=40.0
 if e.artillery(n) and not withdrawing:
  if current_fire<=0 and next_fire>0:score+=340.0
  if next_fire>0 and int(u.ap)>=int(e.weapon(n).ap)+int(e.weapon(n).deployment_ap):score+=70.0
  if enemy_distance(e,dest)<=2:score-=160.0
  elif enemy_distance(e,dest)==3:score-=80.0
  elif next_fire>0:score+=minf(2,maxi(0,enemy_distance(e,dest)-4))*100.0
  if next_fire<=0 and current_fire<=0 and e.elevation(dest)>e.elevation(start):score+=20.0
 if not e.artillery(n) and not e.cavalry(n) and int(u.ap)<int(e.weapon(n).ap) and enemy_distance(e,dest)<=3:score-=55.0
 # A damaged unit can move to a safer second line, still close to its sector.
 if float(u.strength)<float(u.initial_strength)*0.4 and danger<current_threat and e.distance(dest,anchor)<=3:score+=60.0
 return score
func target_value(e,n: int,j: int) -> float:
 var pos=e.unit_cell(e.state.units[j]);var value=25.0
 for objective in goals:
  var d=e.distance(pos,e.objective_cell(objective))
  if d<=3:value=maxf(value,25.0+float(objective.points)*(4-d)*12.0)
 if e.artillery(n) and not e.cavalry(j) and e.state.units[j].morale=="shaken":value+=15.0
 return value
func counterattack_value(e,n: int,j: int) -> float:
 if e.headquarters(n):return -INF
 var target=e.unit_cell(e.state.units[j]);var objective=e.objective_at(target)
 if not objective.is_empty() and e.objective_owner(objective)!=int(e.state.side):return 170.0+float(objective.points)*30.0
 var own=e.objective_at(e.unit_cell(e.state.units[n]))
 if not own.is_empty() and e.objective_owner(own)==int(e.state.side):return -INF
 if rear_targets.has(j):return 240.0
 if nearest_goal_distance(e,target)<=2 and e.state.units[j].morale in ["shaken","routed"]:return 80.0
 return -45.0
func release_cavalry_garrison(e,n: int) -> bool:
 if not e.cavalry(n) or enemy_distance(e,e.unit_cell(e.state.units[n]))<=3:return false
 for k in range(e.state.units.size()):
  var u=e.state.units[k]
  if int(u.side)==int(e.state.side) and not e.headquarters(k) and not e.artillery(k) and not e.cavalry(k) and u.morale!="routed" and e.distance(e.unit_cell(u),e.unit_cell(e.state.units[n]))<=2:return true
 return false

func prepared_position(e,n: int,pos: int,anchor: int) -> bool:
 if e.artillery(n) or e.cavalry(n) or e.headquarters(n) or bool(reserves.get(n,false)) or guards.has(n):return false
 if anchor<0 or e.distance(pos,anchor)>2:return false
 var terrain=e.pack.terrains[e.pack.map.tiles[pos]]
 return pos==anchor or float(terrain.fire_received)<=0.65 or e.elevation(pos)>=2

func intercept_penetrations(e):
 # At most two real reserves; the first objective defenders are never taken.
 var anchors=[]
 for source in e.pack.rules.support.supply_sources[int(e.state.side)]:anchors.append(e.index(Vector2i(int(source[0]),int(source[1]))))
 for n in origin_links:
  if e.headquarters(n):anchors.append(int(origin_links[n].pos))
 for j in threats:
  var pos=e.unit_cell(e.state.units[j])
  for anchor in anchors:
   if e.distance(pos,anchor)<=3:rear_targets[j]=true;break
 var ordered=rear_targets.keys();ordered.sort()
 var enemy_strength=0.0;var assigned_strength=0.0
 for j in ordered:enemy_strength+=float(e.state.units[j].strength)
 for j in ordered:
  if guards.size()>=2 or (not guards.is_empty() and assigned_strength>=enemy_strength*1.25):break
  var target=e.unit_cell(e.state.units[j]);var selected=-1;var best=10000.0
  for n in assignments:
   var u=e.state.units[n];var pos=e.unit_cell(u)
   if guards.has(n) or garrisons.has(n) or not e.can_act(n) or e.artillery(n) or e.cavalry(n) or e.headquarters(n) or u.morale!="stable":continue
   if (not u.get("command_ok",true) and not u.get("supply_ok",true)) or not e.objective_at(pos).is_empty():continue
   var distance=e.distance(pos,target)
   if distance>5 or float(u.strength)<float(u.initial_strength)*0.6:continue
   var score=float(distance)-(1.0 if reserves.get(n,false) else 0.0)
   if score<best:best=score;selected=n
  if selected>=0:guards[selected]=target;assignments[selected]=target;reserves[selected]=false;assigned_strength+=float(e.state.units[selected].strength)

func battery_exposed(e,n: int,pos: int) -> bool:
 for j in threats:
  var foe=e.state.units[j]
  if e.headquarters(j) or float(foe.strength)<float(foe.initial_strength)*0.45:continue
  var enemy=e.unit_cell(foe);var distance=e.distance(pos,enemy)
  if distance> (4 if e.cavalry(j) else 3):continue
  var screened=false
  for ally in origin_links:
   if e.artillery(ally) or e.cavalry(ally) or e.headquarters(ally) or e.state.units[ally].morale=="routed":continue
   var cell=int(origin_links[ally].pos)
   if e.distance(pos,cell)<=2 and e.distance(cell,enemy)<distance:screened=true;break
  if not screened:return true
 return false

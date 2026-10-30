extends RefCounted
# Tactical priorities only. Receives the same sanitized planning engine as the AI.
# No live state, unseen enemy, combat modifier or persistent save field.
var assignments: Dictionary={}
var reserves: Dictionary={}
var priorities: Dictionary={}
var nearest: Dictionary={}
var goals: Array=[]
func prepare(e):
 assignments={};reserves={};priorities={};nearest={};goals=e.objective_definitions()
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
  if not own.is_empty() and e.objective_owner(own)==int(u.side):assignments[n]=start;slots[start]+=1
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
  assignments[chosen]=anchor;slots[anchor]+=1;infantry.erase(chosen)
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
func movement(e,n: int,start: int,dest: int,anchor: int,current_fire: float,next_fire: float,current_threat: float,danger: float,restores_link: bool) -> float:
 if e.headquarters(n) or anchor<0:return 0.0
 var u=e.state.units[n];var before=float(e.pack.terrains[e.pack.map.tiles[start]].fire_received);var after=float(e.pack.terrains[e.pack.map.tiles[dest]].fire_received)
 # Keep a protected firing line unless a safer move, better lane or liaison
 # restoration justifies leaving it. Entrenchment is lost by a real move.
 if not restores_link and current_fire>0 and before<=0.65 and after>=before and next_fire<=current_fire and danger>=current_threat:return -INF
 var score=position_value(e,n,dest,anchor)-position_value(e,n,start,anchor)
 if u.get("entrenched",false) and not restores_link:score-=70.0
 if next_fire>0 and current_fire<=0:score+=40.0
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
 if nearest_goal_distance(e,target)<=2 and e.state.units[j].morale in ["shaken","routed"]:return 35.0
 return -45.0
func release_cavalry_garrison(e,n: int) -> bool:
 if not e.cavalry(n) or enemy_distance(e,e.unit_cell(e.state.units[n]))<=3:return false
 for k in range(e.state.units.size()):
  var u=e.state.units[k]
  if int(u.side)==int(e.state.side) and not e.headquarters(k) and not e.artillery(k) and not e.cavalry(k) and u.morale!="routed" and e.distance(e.unit_cell(u),e.unit_cell(e.state.units[n]))<=2:return true
 return false

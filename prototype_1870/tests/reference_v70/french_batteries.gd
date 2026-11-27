extends RefCounted
# V70: decisions from the sanitized observation. Native AP, LOS and movement
# still decide every real action. These estimates add no defensive modifier.
static func infantry(e,n: int) -> bool:
 return not e.artillery(n) and not e.cavalry(n) and not e.headquarters(n) and e.state.units[n].morale!="routed" and float(e.state.units[n].strength)>=float(e.state.units[n].initial_strength)*0.35

static func screen(e,d,n: int,pos: int,enemy: int=-1) -> bool:
 for ally in d.origin_links:
  if ally==n or not infantry(e,ally):continue
  var cell=int(d.origin_links[ally].pos)
  if e.distance(pos,cell)>2:continue
  if enemy<0 or e.distance(cell,enemy)<e.distance(pos,enemy):return true
 return false

static func urgent(e,d,n: int,pos: int) -> bool:
 for j in d.threats:
  var foe=e.state.units[j]
  if e.headquarters(j) or e.artillery(j) or float(foe.strength)<float(foe.initial_strength)*0.45:continue
  var enemy=e.unit_cell(foe);var distance=e.distance(pos,enemy)
  if distance<=1 or distance<=(3 if e.cavalry(j) else 2) and not screen(e,d,n,pos,enemy):return true
 return false

static func nearest(e,d,pos: int) -> int:
 var result=100
 for j in d.threats:
  if not e.headquarters(j):result=mini(result,e.distance(pos,e.unit_cell(e.state.units[j])))
 return result

static func position_value(e,d,n: int,pos: int) -> float:
 var distance=nearest(e,d,pos);var value=0.0
 if distance<=1:value-=800.0
 elif distance==2:value-=350.0
 elif distance in [3,4]:value+=100.0
 elif distance==5:value+=40.0
 value+=100.0 if screen(e,d,n,pos) else -60.0
 return value

static func anchor(e,d,n: int) -> int:
 var result=-1;var best=-INF;var start=e.unit_cell(e.state.units[n])
 for ally in d.origin_links:
  if not infantry(e,ally):continue
  var cell=int(d.origin_links[ally].pos);var enemy=nearest(e,d,cell)
  if enemy>6:continue
  var score=80.0-float(e.distance(start,cell))*8.0-float(absi(enemy-3))*12.0
  if score>best:best=score;result=cell
 return result

static func protect(e,d):
 # A local screen uses at most two spare formations; objective garrisons and
 # reserves already guarding a rear penetration retain their approved missions.
 for n in d.origin_links:
  if not e.artillery(n) or d.battery_screens.size()>=2:continue
  var pos=int(d.origin_links[n].pos);var closest=-1;var distance=100
  for j in d.threats:
   if e.headquarters(j) or e.artillery(j):continue
   var gap=e.distance(pos,e.unit_cell(e.state.units[j]))
   if gap<distance:distance=gap;closest=e.unit_cell(e.state.units[j])
  if distance>5 or closest<0 or screen(e,d,n,pos,closest):continue
  var chosen=-1;var best=10000
  for ally in d.assignments:
   if d.garrisons.has(ally) or d.guards.has(ally) or d.battery_screens.has(ally) or not infantry(e,ally) or not e.can_act(ally):continue
   var u=e.state.units[ally];var cell=e.unit_cell(u)
   if not u.get("supply_ok",true) or not u.get("command_ok",true) or not e.objective_at(cell).is_empty():continue
   var gap=e.distance(cell,pos)
   if gap>3:continue
   var score=gap*10-(5 if d.reserves.get(ally,false) else 0)
   if score<best:best=score;chosen=ally
  if chosen<0:continue
  var destination=-1;var value=-INF;var start=e.unit_cell(e.state.units[chosen])
  var reachable=e.reach(chosen)
  for cell in reachable.costs:
   if e.distance(cell,pos)!=1 or e.distance(cell,closest)>=distance or e.unit_at(cell)>=0 and cell!=start:continue
   var score=100.0-float(reachable.costs[cell])*4.0-float(e.pack.terrains[e.pack.map.tiles[cell]].fire_received)*20.0
   if score>value:value=score;destination=cell
  if destination>=0:
   d.battery_screens[chosen]=destination;d.assignments[chosen]=destination;d.reserves[chosen]=false

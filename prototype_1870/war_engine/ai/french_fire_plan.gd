extends RefCounted
const Batteries=preload("res://war_engine/ai/french_batteries.gd")
const Support=preload("res://war_engine/core/support.gd")
# French Hard only. Every proposed order is paid and checked by the native
# engine. Forecasts use observed targets, never unobserved enemy positions.
static func targets(e,n: int) -> Array:
 var result=[]
 for j in range(e.state.units.size()):
  if e.fire_status(n,j)=="ok":result.append(j)
 return result

static func clear_lane(e,d) -> Dictionary:
 var lanes={}
 for other in d.origin_links:
  if not e.artillery(other):continue
  var origin=e.unit_cell(e.state.units[other]);var open=[]
  for foe in d.threats:
   var target=e.unit_cell(e.state.units[foe])
   if e.distance(origin,target)<=int(e.weapon(other).range) and e.line_status(origin,target)=="ok":open.append(target)
  if not open.is_empty():lanes[other]=open
 for n in d.origin_links:
  var gun=e.state.units[n]
  if not e.artillery(n) or not e.can_act(n) or gun.morale=="routed" or not gun.deployed or int(gun.ap)<int(e.weapon(n).ap) or d.needs_withdrawal(e,n,e.unit_cell(gun)):continue
  var tried=0
  for j in d.threats:
   var target=e.unit_cell(e.state.units[j])
   if e.distance(e.unit_cell(gun),target)>int(e.weapon(n).range) or e.line_status(e.unit_cell(gun),target)!="blocked_friendly":continue
   tried+=1
   var plan=open_lane(e,d,n,j,2,{},lanes)
   if not plan.is_empty():return plan[0]
   if tried>=8:break
 return {}

static func first_blocker(e,n: int,target: int) -> int:
 var start=e.unit_cell(e.state.units[n]);var steps=e.distance(start,target)
 var cfg=e.pack.rules.get("line_of_fire",{});var eye=float(cfg.get("sight_height",0.4))
 for sign_value in [-1.0,1.0]:
  var offset=Vector3(0.00001,0.00001,-0.00002)*sign_value
  for k in range(1,steps):
   var cell=e.round_hex((e.cube(start)+offset).lerp(e.cube(target)+offset,float(k)/steps))
   var sight=lerpf(e.elevation(start)+eye,e.elevation(target)+eye,float(k)/steps)
   if e.terrain_obstacle_status(cell,sight)!="ok":return -1
   var ally=e.line_unit_at(cell,n)
   if ally<0:continue
   if int(e.state.units[ally].side)!=int(e.state.units[n].side):return -1
   var clearance=e.elevation(cell)+float(cfg.get("unit_height",0.4))+float(cfg.get("friendly_clearance",0.2))
   if bool(cfg.get("elevated_artillery_overhead",false)) and e.elevation(start)>e.elevation(cell) and sight>clearance+0.00001:continue
   return ally
 return -1

static func open_lane(e,d,n: int,j: int,depth: int,used: Dictionary,lanes: Dictionary) -> Array:
 if e.fire_status(n,j)=="ok":return [{}]
 var start=e.unit_cell(e.state.units[n]);var target=e.unit_cell(e.state.units[j])
 if depth<=0 or e.line_status(start,target)!="blocked_friendly":return []
 var ally=first_blocker(e,n,target)
 if ally<0 or used.has(ally):return []
 var u=e.state.units[ally];var old=e.unit_cell(u)
 if not Batteries.infantry(e,ally) or not e.can_act(ally) or u.get("entrenched",false) or d.garrisons.has(ally) or d.guards.has(ally) or not e.objective_at(old).is_empty() or u.get("river_halt",false):return []
 var original_ap=int(u.ap);var original_done=bool(u.done)
 for cell in e.neighbours(old):
  var cost=e.step_cost(ally,old,cell)
  if e.unit_at(cell)>=0 or cost<0 or cost>mini(4,original_ap) or e.distance(cell,start)>3 or e.distance(cell,target)<=1 or e.distance(cell,target)>=e.distance(start,target):continue
  if float(e.pack.terrains[e.pack.map.tiles[cell]].fire_received)>float(e.pack.terrains[e.pack.map.tiles[old]].fire_received):continue
  var c=e.cell(cell);e.set_planning_cell(ally,[c.x,c.y]);u.ap=original_ap-cost;u.done=u.ap<=0
  var safe_move=true
  for other in lanes:
   if other==n:continue
   var retained=false
   for previous in lanes[other]:
    if e.line_status(e.unit_cell(e.state.units[other]),previous)=="ok":retained=true;break
   if not retained:safe_move=false;break
  var links=Support.strict_report(e,ally,d.networks) if not d.networks.is_empty() else {}
  if not links.is_empty() and (u.get("command_ok",true) and not links.command_ok or u.get("supply_ok",true) and not links.supply_ok):safe_move=false
  var tail=[]
  if safe_move:
   var next_used=used.duplicate();next_used[ally]=true
   tail=open_lane(e,d,n,j,depth-1,next_used,lanes)
  e.set_planning_cell(ally,[e.cell(old).x,e.cell(old).y]);u.ap=original_ap;u.done=original_done
  if not tail.is_empty():
   var action={"kind":"move","unit":u.id,"path":[old,int(cell)]}
   if tail.size()==1 and tail[0].is_empty():return [action]
   tail.push_front(action);return tail
 return []

static func relocation(e,d) -> Dictionary:
 var best={};var best_score=-INF
 for n in d.origin_links:
  var u=e.state.units[n];var start=e.unit_cell(u)
  if not e.artillery(n) or not e.can_act(n) or u.morale=="routed" or d.needs_withdrawal(e,n,start) or e.max_ap(n)<int(e.weapon(n).ap):continue
  var original_ap=int(u.ap);var original_deployed=bool(u.deployed);var original_done=bool(u.done)
  var setup=int(e.weapon(n).deployment_ap);var limber=setup if original_deployed else 0
  # A productive lane is retained. A limbered gun there is deployed by the
  # existing gun-priority routine before this planner is called.
  u.ap=e.max_ap(n);u.deployed=true;u.done=false
  var current=targets(e,n)
  u.ap=original_ap;u.deployed=original_deployed;u.done=original_done
  if not current.is_empty() or original_ap<limber+setup+2:continue
  # With four PA the gun may finish its setup next turn and still fire.
  # At the three-PA command limit deployment must be paid this turn.
  var reserve=0 if e.max_ap(n)>=int(e.weapon(n).ap)+setup else setup
  u.deployed=false;u.ap=original_ap-limber-reserve
  var reach=e.reach(n);var found_lane=false
  for cell in reach.costs:
   if cell==start or e.unit_at(cell)>=0:continue
   var c=e.cell(cell);e.set_planning_cell(n,[c.x,c.y]);u.ap=e.max_ap(n);u.deployed=true;u.done=false
   var shots=targets(e,n)
   if not shots.is_empty() and safe(e,d,n,cell):
    found_lane=true
    var margin=0
    for foe in shots:margin=maxi(margin,int(e.weapon(n).range)-e.distance(cell,e.unit_cell(e.state.units[foe])))
    var setup_now=original_ap-limber-int(reach.costs[cell])>=setup
    var score=10000.0+minf(4,shots.size())*50.0-float(reach.costs[cell])*4.0+minf(3,margin)*55.0+(25.0 if setup_now else 0.0)+Batteries.position_value(e,d,n,cell)*0.1
    if score>best_score:
     best_score=score;best=order(e,n,start,cell,reach,original_deployed)
   e.set_planning_cell(n,[e.cell(start).x,e.cell(start).y]);u.ap=original_ap-limber-reserve;u.deployed=false;u.done=original_done
  # If no firing cell is reachable, advance toward an observed engagement
  # supported by real infantry. Full movement is useful while still out of
  # range; deployment is reserved as soon as a firing lane can be reached.
  if not found_lane and original_ap>=limber+4:
   var engagements=[]
   for j in d.threats:
    if e.headquarters(j):continue
    var target=e.unit_cell(e.state.units[j])
    if e.distance(start,target)<=int(e.weapon(n).range):continue
    for ally in d.origin_links:
     if Batteries.infantry(e,ally) and e.distance(int(d.origin_links[ally].pos),target)<=4:engagements.append(target);break
   if not engagements.is_empty():
    u.ap=original_ap-limber;u.deployed=false
    var march=e.reach(n)
    for cell in march.costs:
     if cell==start or e.unit_at(cell)>=0:continue
     var gain=0
     for target in engagements:gain=maxi(gain,e.distance(start,target)-e.distance(cell,target))
     if gain<1:continue
     var c=e.cell(cell);e.set_planning_cell(n,[c.x,c.y])
     if safe(e,d,n,cell):
      var score=100.0+float(gain)*35.0-float(march.costs[cell])*2.0+Batteries.position_value(e,d,n,cell)*0.1
      if score>best_score:best_score=score;best=order(e,n,start,cell,march,original_deployed)
     e.set_planning_cell(n,[e.cell(start).x,e.cell(start).y])
  u.ap=original_ap;u.deployed=original_deployed;u.done=original_done
 return best

static func safe(e,d,n: int,pos: int) -> bool:
 if Batteries.urgent(e,d,n,pos):return false
 var nearby=false
 for ally in d.origin_links:
  if Batteries.infantry(e,ally) and e.distance(pos,int(d.origin_links[ally].pos))<=3:nearby=true;break
 if not nearby:return false
 if not d.networks.is_empty():
  var links=Support.strict_report(e,n,d.networks,pos);var origin=d.origin_links[n]
  if origin.command_ok and not links.command_ok or origin.supply_ok and not links.supply_ok:return false
 return true

static func order(e,n: int,start: int,destination: int,reach: Dictionary,deployed: bool) -> Dictionary:
 var path=[int(destination)]
 while reach.parents.has(path[0]):path.push_front(reach.parents[path[0]])
 return {"kind":"limber" if deployed else "move","unit":e.state.units[n].id,"path":path}

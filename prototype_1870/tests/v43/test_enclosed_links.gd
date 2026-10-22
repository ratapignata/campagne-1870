extends "res://tests/test_strict0833.gd"
const Store=preload("res://war_engine/platform/save_store.gd")
func ring_fixture(side:int=0):
 var e=fresh();var center=e.index(Vector2i(9,6));var neighbours=e.neighbours(center)
 var foe=e.state.units[enemy];foe.strength=foe.initial_strength;foe.casualties=0;foe.side=1-side;foe.cell=[9,6];foe.pending=false;foe.morale="stable"
 e.state.units[qg].side=side;e.state.units[qg].cell=[7,5]
 e.pack.rules.support.supply_sources[side]=[[7,5]]
 e.state.units[foot].strength=0;e.state.units[foot].casualties=e.state.units[foot].initial_strength;e.state.units[foot].ap=0;e.state.units[foot].done=true
 var first=true
 for pos in neighbours:
  var u=e.state.units[cav].duplicate(true)
  u.id="ring_"+str(pos);u.side=side;u.cell=[e.cell(pos).x,e.cell(pos).y];u.command_group="test";u.strength=u.initial_strength;u.casualties=0;u.morale="stable";u.pending=false
  if first:
   u.id=e.state.units[cav].id;e.state.units[cav]=u;first=false
  else:e.state.units.append(u);e.pack.units.append(u.duplicate(true))
 e.state.command_hq={"test":str(e.state.units[qg].id)}
 e.pack.units=e.state.units.duplicate(true)
 e.refresh_support(false);return e
func _initialize():
 for side in [0,1]:
  var e=ring_fixture(side);var net=Support.strict_networks(e,side);var count=0
  for n in range(e.state.units.size()):
   if e.alive(n) and int(e.state.units[n].side)==side and not e.headquarters(n):
    count+=1;check(e.state.units[n].command_ok and e.state.units[n].supply_ok,"fully surrounded enemy does not cut enclosing unit "+str(side)+"/"+str(n))
  check(count==6,"six enclosing units")
  check(not net.supply.has(e.unit_cell(e.state.units[enemy])),"occupied enemy cell remains blocked")
  var coverage=Support.supply_coverage(e,side)
  check(coverage.has(e.unit_cell(e.state.units[cav])),"coverage matches connection")
  var copy=Rules.new(e.pack);var store=Store.new("user://ring.json","ring")
  check(store.save_game(e) and store.load_game(copy),"save reload ring")
  copy.refresh_support(false);check(copy.state.units[cav].command_ok,"reloaded ring retains command")
  # Opening one slot restores original enemy influence; no exception for partial rings.
  var removed=e.state.units.size()-1;e.state.units[removed].strength=0;e.state.units[removed].casualties=e.state.units[removed].initial_strength;e.state.units[removed].ap=0;e.state.units[removed].done=true
  e.refresh_support(false);net=Support.strict_networks(e,side)
  var all_blocked=true
  for pos in e.neighbours(e.unit_cell(e.state.units[enemy])):
   if net.commands["test"].has(pos):all_blocked=false
  check(all_blocked,"partial ring retains enemy interference")
 var ordinary=fresh();wall(ordinary,19)
 check(not ordinary.state.units[cav].command_ok and not ordinary.state.units[cav].supply_ok,"normal barrier still isolates")
 print("ENCLOSED LINKS ",checks-failures,"/",checks);quit(1 if failures else 0)

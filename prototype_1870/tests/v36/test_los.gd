extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const Intel=preload("res://war_engine/core/intel.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func fresh():
 var p=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial.json"));p.rules.support.enabled=false;p.rules.fog.enabled=false
 p.map.tiles.fill("plain");p.map.elevations.fill(0);p.map.river_edges=[];p.map.road_edges=[]
 var e=Rules.new(p)
 for u in e.state.units:u.strength=0;u.casualties=u.initial_strength;u.pending=false;u.done=true;u.ap=0
 return e
func pair(e):
 var a=-1;var b=-1
 for n in range(e.state.units.size()):
  if e.artillery(n) or e.cavalry(n) or e.headquarters(n):continue
  if e.state.units[n].side==0:a=n
  else:b=n
 for n in [a,b]:
  var u=e.state.units[n];u.strength=u.initial_strength;u.casualties=0;u.done=false;u.ap=16
 e.state.units[a].cell=[10,2];e.state.units[b].cell=[10,5];return [a,b]
func both(e,a,b,clear,label):
 check((e.line_status(a,b)=="ok")==clear,label+" fire")
 check(Intel.clear(e,a,b)==clear,label+" observation")
 check((e.line_status(b,a)=="ok")==clear,label+" reverse fire")
func _initialize():
 var e=fresh();var p=pair(e);var a=e.unit_cell(e.state.units[p[0]]);var b=e.unit_cell(e.state.units[p[1]]);var m=e.index(Vector2i(10,3))
 both(e,a,b,true,"flat explicit elevations")
 e.pack.map.elevations[m]=2;both(e,a,b,false,"blocking ridge between open endpoints")
 e.pack.map.elevations[m]=1;both(e,a,b,false,"low ridge still intersects ray")
 e.pack.map.elevations[a]=2;e.pack.map.elevations[b]=2;both(e,a,b,true,"higher intermediate terrain below elevated ray")
 e.pack.map.elevations[a]=4;e.pack.map.elevations[b]=0;both(e,a,b,true,"shooting down from height")
 e.pack.map.elevations[a]=0;e.pack.map.elevations[b]=4;both(e,a,b,true,"shooting up toward height")
 e.pack.map.elevations.fill(0)
 for t in ["forest","village"]:
  e.pack.map.tiles[m]=t;both(e,a,b,false,t+" cover")
 e.pack.map.tiles[m]="plain"
 # Find an exact hex-edge ray whose two nudged variants visit different cells.
 var edge=[]
 for x in range(1,6):
  for y in range(1,6):
   var start=e.index(Vector2i(8,8));var dest=e.index(Vector2i(8+x,8+y));var d=e.distance(start,dest)
   for k in range(1,d):
    var offset=Vector3(0.00001,0.00001,-0.00002)
    var i=e.round_hex((e.cube(start)+offset).lerp(e.cube(dest)+offset,float(k)/d));var j=e.round_hex((e.cube(start)-offset).lerp(e.cube(dest)-offset,float(k)/d))
    if i!=j:edge=[start,dest,i,j];break
   if not edge.is_empty():break
  if not edge.is_empty():break
 check(not edge.is_empty(),"reproducible border-hex geometry found")
 if not edge.is_empty():
  both(e,edge[0],edge[1],true,"both edge variants clear")
  for blocker in [edge[2],edge[3]]:
   e.pack.map.elevations.fill(0);e.pack.map.elevations[blocker]=2
   both(e,edge[0],edge[1],false,"one edge variant intersects ridge "+str(blocker))
 e=fresh();p=pair(e);a=e.unit_cell(e.state.units[p[0]]);b=e.unit_cell(e.state.units[p[1]]);m=e.index(Vector2i(10,3))
 var gun=-1;var friend=-1
 for n in range(e.state.units.size()):
  if e.state.units[n].side==0 and e.artillery(n):gun=n
  if e.state.units[n].side==0 and e.cavalry(n):friend=n
 for n in [gun,friend]:e.state.units[n].strength=e.state.units[n].initial_strength;e.state.units[n].casualties=0
 e.state.units[p[0]].strength=0;e.state.units[p[0]].casualties=e.state.units[p[0]].initial_strength;e.state.units[p[0]].done=true;e.state.units[p[0]].ap=0
 e.state.units[gun].cell=[10,2];e.state.units[gun].deployed=true;e.state.units[gun].done=false;e.state.units[gun].ap=16;e.state.units[friend].cell=[10,3]
 check(e.line_status(a,b)=="blocked_friendly","level gun cannot shoot through friend")
 e.pack.map.elevations[a]=4;check(e.line_status(a,b)=="ok","elevated gun safely shoots above friend")
 e.pack.map.elevations[m]=4;check(e.line_status(a,b)=="blocked_terrain","overhead fire does not bypass terrain")
 e=fresh();p=pair(e);e.pack.rules.fog.enabled=true;m=e.index(Vector2i(10,3));e.pack.map.elevations[m]=2;e.refresh_intel()
 check(not e.visible_to(0,p[1]) and e.fire_status(p[0],p[1])=="hidden","enemy behind ridge neither detected nor targeted")
 var view=e.observation(0);e.state.units[p[1]].cell=[28,18];e.refresh_intel()
 check(e.observation(0)==view,"hidden enemy position behind ridge does not leak")
 check(e.pack.weapons.french_rifled.range==6 and e.pack.weapons.krupp.range==8,"artillery ranges preserved")
 print("V36 LOS ",checks-failures,"/",checks);quit(1 if failures else 0)

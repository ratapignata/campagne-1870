extends RefCounted
# Experimental presentation only: one reusable atlas, public terrain geometry.
const ATLAS=preload("res://assets/graphics2d/terrain_atlas.png")
const NAMES=["plain_0", "plain_1", "plain_2", "plain_3", "cultivated_0", "cultivated_1", "cultivated_2", "cultivated_3", "meadow_0", "meadow_1", "meadow_2", "hill_0", "hill_1", "forest_ground_0", "village_ground_0", "road_0", "water_0", "bridge_0", "forest_0", "forest_0_road", "forest_1", "forest_1_road", "forest_2", "forest_2_road", "forest_3", "forest_3_road", "village_0", "village_1", "village_2"]
static var regions: Dictionary={}
static func prepare():
 if not regions.is_empty():return
 for n in range(NAMES.size()):
  var t=AtlasTexture.new();t.atlas=ATLAS;t.region=Rect2((n%6)*220+8,(n/6)*193+8,204,177);t.filter_clip=true;regions[NAMES[n]]=t
static func sprite(view,name: String,p: Vector2,z: float,tint: Color=Color.WHITE):
 prepare()
 if regions.has(name):view.draw_texture_rect(regions[name],Rect2(p-Vector2(view.R,view.R*sqrt(3.0)/2)*z,Vector2(view.R*2,view.R*sqrt(3.0))*z),false,tint)
static func ground(view,terrain: String,index: int,p: Vector2,z: float):
 var kind=terrain;var variants=1
 match terrain:
  "plain","cultivated":variants=4
  "meadow":variants=3
  "hill":variants=2
  "forest":kind="forest_ground"
  "village":kind="village_ground"
 var elevation=view.engine.elevation(index);var tint=Color(1.0+0.012*elevation,1.0+0.005*elevation,1.0-0.018*elevation)
 sprite(view,kind+"_"+str(posmod(index*7+index/view.engine.width,variants)),p,z,tint)
static func decor(view,terrain: String,index: int,p: Vector2,z: float,road: bool):
 if terrain=="forest":sprite(view,"forest_"+str(index%4)+("_road" if road else ""),p,z)
 elif terrain=="village":sprite(view,"village_"+str(index%3),p,z)
static func relief(view,index: int,p: Vector2,z: float):
 var height=view.engine.elevation(index)
 if height<=0:return
 for n in view.engine.neighbours(index):
  if view.engine.cost(n)<0 or view.engine.elevation(n)>=height:continue
  var normal=(view.screen(n)-p).normalized();var middle=(view.screen(n)+p)/2;var tangent=Vector2(-normal.y,normal.x)*view.R*z*0.49
  view.draw_line(middle-tangent-normal*1.2*z,middle+tangent-normal*1.2*z,Color(0.37,0.32,0.23,0.11),maxf(1,4.5*z),true)
  view.draw_line(middle-tangent-normal*3.5*z,middle+tangent-normal*3.5*z,Color(0.93,0.89,0.73,0.18),maxf(0.7,2*z),true)
static func river(view,a: Vector2,b: Vector2,z: float):
 var d=(b-a).normalized();var normal=Vector2(-d.y,d.x)
 view.draw_line(a,b,Color("a4ae89"),8.4*z,true)
 view.draw_line(a,b,Color("dbcfab"),6.8*z,true)
 view.draw_line(a,b,Color("3f829a"),4.9*z,true)
 view.draw_line(a-normal*0.5*z,b-normal*0.5*z,Color(0.53,0.76,0.80,0.68),1.7*z,true)
 if z>=0.65:
  for fraction in [0.27,0.66]:
   var p=a.lerp(b,fraction)
   view.draw_line(p-d*2*z+normal*z,p+d*3*z+normal*z,Color(0.82,0.90,0.83,0.42),maxf(0.55,0.7*z),true)
static func road(view,points: PackedVector2Array,z: float):
 view.draw_polyline(points,Color("ae9974"),4.4*z,true)
 view.draw_polyline(points,Color("d3bf96"),2.5*z,true)

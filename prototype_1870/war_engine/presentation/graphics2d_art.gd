extends RefCounted
# Painted assets are presentation only. Geography and unit state come from the engine.
const GROUND=preload("res://assets/graphics2d2/painted_ground.png")
const FIGURES=preload("res://assets/graphics2d2/painted_figures.png")
const FIGURE_RECTS={
 "infantry_fr":Rect2(35,52,360,330),"infantry_pr":Rect2(426,52,302,332),
 "cavalry_fr":Rect2(770,0,380,396),"cavalry_pr":Rect2(1153,0,383,397),
 "artillery_fr":Rect2(2,413,382,290),"artillery_pr":Rect2(387,411,379,286),
 "forest_0":Rect2(769,397,380,308),"forest_1":Rect2(1153,397,383,308),
 "forest_road":Rect2(0,705,383,319),"village_0":Rect2(385,686,382,338),
 "village_1":Rect2(769,717,382,307),"village_2":Rect2(1153,708,383,316)}
static var regions: Dictionary={}
static func prepare():
 if not regions.is_empty():return
 for name in FIGURE_RECTS:
  var t=AtlasTexture.new();t.atlas=FIGURES;t.region=FIGURE_RECTS[name];t.filter_clip=true;regions[name]=t
static func ground_rect(n: int) -> Rect2:
 return Rect2((n%4)*384,(n/4)*1024.0/3.0,384,1024.0/3.0)
static func paint_hex(view,texture: Texture2D,region: Rect2,p: Vector2,z: float,tint: Color=Color.WHITE,mirror: bool=false):
 var polygon=view.hexagon(p,view.R*z);var uv=PackedVector2Array()
 var extent=Vector2(view.R*2,view.R*sqrt(3.0))*z
 for vertex in polygon:
  var relative=(vertex-p)/extent+Vector2(0.5,0.5)
  if mirror:relative.x=1.0-relative.x
  uv.append((region.position+Vector2(3,3)+relative*(region.size-Vector2(6,6)))/Vector2(texture.get_size()))
 view.draw_polygon(polygon,PackedColorArray([tint]),uv,texture)
static func ground(view,terrain: String,index: int,p: Vector2,z: float):
 var n=0;var variant=posmod(index*7+index/view.engine.width,2)
 match terrain:
  "plain":n=variant
  "cultivated":n=2+variant
  "meadow":n=4+variant
  "hill":n=6+variant
  "forest":n=8
  "village":n=9
  "road","bridge":n=10
  "water":return
  _:n=11
 var height=view.engine.elevation(index)
 paint_hex(view,GROUND,ground_rect(n),p,z,Color(1.0+0.008*height,1.0+0.003*height,1.0-0.012*height,0.90),index%5==0)
static func decor(view,terrain: String,index: int,p: Vector2,z: float,road: bool):
 var key=""
 if terrain=="forest":key="forest_road" if road else "forest_"+str(index%2)
 elif terrain=="village":key="village_"+str(index%3)
 if not key.is_empty():paint_hex(view,FIGURES,FIGURE_RECTS[key],p,z,Color.WHITE,index%3==0)
static func figure(view,kind: String,p: Vector2,z: float,french: bool):
 prepare()
 var key=kind+("_fr" if french else "_pr")
 # Same counter footprint: decorations never enter the force/flag strip.
 var rect=Rect2(p+Vector2(-24,-22.5)*z,Vector2(48,40)*z)
 view.draw_texture_rect(regions[key],rect,false)
static func relief(view,index: int,p: Vector2,z: float):
 var height=view.engine.elevation(index)
 if height<=0:return
 for n in view.engine.neighbours(index):
  if view.engine.cost(n)<0 or view.engine.elevation(n)>=height:continue
  var normal=(view.screen(n)-p).normalized();var middle=(view.screen(n)+p)/2;var tangent=Vector2(-normal.y,normal.x)*view.R*z*0.49
  view.draw_line(middle-tangent-normal*1.2*z,middle+tangent-normal*1.2*z,Color(0.29,0.29,0.14,0.16),maxf(1,4.5*z),true)
  view.draw_line(middle-tangent-normal*3.5*z,middle+tangent-normal*3.5*z,Color(0.98,0.92,0.69,0.18),maxf(0.7,2*z),true)
static func river(view,a: Vector2,b: Vector2,z: float):
 var d=(b-a).normalized();var normal=Vector2(-d.y,d.x)
 # Original segment endpoints are retained; only the water/shore brush changes.
 view.draw_line(a,b,Color("6d8352"),12*z,true)
 view.draw_line(a,b,Color("c5ae77"),10*z,true)
 view.draw_line(a,b,Color("427f98"),7.8*z,true)
 view.draw_line(a-normal*0.8*z,b-normal*0.8*z,Color(0.43,0.70,0.78,0.85),3.5*z,true)
 if z>=0.65:
  for fraction in [0.24,0.58,0.83]:
   var p=a.lerp(b,fraction)
   view.draw_line(p-d*2*z+normal*z,p+d*3*z+normal*z,Color(0.77,0.87,0.81,0.44),maxf(0.55,0.8*z),true)
static func road(view,points: PackedVector2Array,z: float):
 view.draw_polyline(points,Color("8e724d"),4.9*z,true)
 view.draw_polyline(points,Color("c4aa77"),3.5*z,true)
 view.draw_polyline(points,Color("dbc495"),1.3*z,true)

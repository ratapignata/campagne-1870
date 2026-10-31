extends RefCounted
# Painted assets are presentation only. Geography and unit state come from the engine.
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
static func terrain_style(terrain: String) -> int:
 # Exactly one unmirrored material per terrain type; altitude remains public shading.
 match terrain:
  "plain":return 0
  "cultivated":return 3
  "meadow":return 4
  "hill":return 6
  "forest":return 8
  "village":return 9
  "road","bridge":return 10
  _:return 11
static func base_color(source: Color) -> Color:
 return source
static func ground(view,terrain: String,index: int,p: Vector2,z: float):
 # Stable V43.15 colour is already drawn by MapView. No green texture overlay.
 pass
static func decor(view,terrain: String,index: int,p: Vector2,z: float,road: bool):
 var key=""
 if terrain=="forest":key="forest_0"
 elif terrain=="village":key="village_"+str(index%3)
 if not key.is_empty():
  # The same transparent artwork provides a light underpainting, lifting shadows.
  paint_hex(view,FIGURES,FIGURE_RECTS[key],p,z,Color(8,8,8))
  var tint=Color(1.28,1.30,1.18,0.75) if terrain=="forest" else Color(1.10,1.10,1.08,0.90)
  paint_hex(view,FIGURES,FIGURE_RECTS[key],p,z,tint)
static func infantry_figures(strength: int) -> int:
 return 2 if strength>=2000 else 1
static func contact_figures(report: Dictionary) -> int:
 if report.get("type","")!="infantry":return 1
 if report.has("exact_strength"):return infantry_figures(int(report.exact_strength))
 # An ambiguous interval uses a generic silhouette, never hidden live strength.
 return 2 if int(report.get("low",0))>=2000 else 1
static func figure(view,kind: String,p: Vector2,z: float,french: bool,figures: int=1):
 prepare()
 var key=kind+("_fr" if french else "_pr")
 var tint=Color(1.18,1.18,1.16,0.82) if french else Color(1.45,1.45,1.38,0.82)
 if kind=="infantry" and figures>=2:
  draw_figure(view,key,Rect2(p+Vector2(-24,-22.5)*z,Vector2(34,36)*z),tint*Color(0.97,0.99,1.0))
  draw_figure(view,key,Rect2(p+Vector2(-10,-19)*z,Vector2(34,36)*z),tint)
 else:draw_figure(view,key,Rect2(p+Vector2(-24,-22.5)*z,Vector2(48,40)*z),tint)
static func draw_figure(view,key: String,rect: Rect2,tint: Color):
 view.draw_texture_rect(regions[key],rect,false,Color(4,4,4))
 view.draw_texture_rect(regions[key],rect,false,tint)
static func movement_marker(view,p: Vector2,z: float):
 view.draw_circle(p,maxf(3.8,6.0*z),Color("183b37"))
 view.draw_circle(p,maxf(2.5,4.2*z),Color("fff2ce"))
static func selection_brackets(view,p: Vector2,z: float):
 # Outside the unchanged red/green tactical rectangle; never cover the force strip.
 for sx in [-1,1]:
  for sy in [-1,1]:
   var corner=p+Vector2(33*sx,34*sy)*z
   var points=PackedVector2Array([corner+Vector2(-8*sx,0)*z,corner,corner+Vector2(0,-8*sy)*z])
   view.draw_polyline(points,Color("243b3a"),maxf(4,5.2*z),true)
   view.draw_polyline(points,Color("fff4d7"),maxf(2,2.8*z),true)
static func route_preview(view,points: PackedVector2Array,z: float):
 if points.size()<2:return
 view.draw_polyline(points,Color("183b37"),maxf(5,8*z),true)
 view.draw_polyline(points,Color("fff4d7"),maxf(3.5,5.8*z),true)
 view.draw_polyline(points,Color("286a70"),maxf(1.7,3*z),true)
 for k in range(1,points.size()-1):view.draw_circle(points[k],maxf(2,3*z),Color("286a70"))
 var endpoint=points[-1];var radius=maxf(7,10*z)
 var diamond=PackedVector2Array([endpoint+Vector2(0,-radius),endpoint+Vector2(radius,0),endpoint+Vector2(0,radius),endpoint+Vector2(-radius,0)])
 view.draw_colored_polygon(diamond,Color("ffe09a"));diamond.append(diamond[0])
 view.draw_polyline(diamond,Color("183b37"),maxf(1.5,2*z),true)
 view.draw_arc(endpoint,maxf(11,18*z),0,TAU,32,Color("183b37"),maxf(3,4*z),true)
 view.draw_arc(endpoint,maxf(11,18*z),0,TAU,32,Color("fff4d7"),maxf(1.5,2*z),true)
static func locality_name(view,p: Vector2,text: String,font_size: int):
 view.draw_string_outline(view.LOCALITY_FONT,p,text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,clampi(roundi(3.2*view.zoom),3,5),Color("fff5df"))
 view.draw_string(view.LOCALITY_FONT,p,text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,Color("253a29"))
static func label_obstacles(view) -> Array:
 var obstacles=[];var e=view.engine;var side=int(e.state.human_side)
 for n in range(e.state.units.size()):
  if int(e.state.units[n].side)!=side and e.fog_enabled() and not e.state.finished:continue
  if e.alive(n):obstacles.append(Rect2(view.screen(e.unit_cell(e.state.units[n]))-Vector2(31,33)*view.zoom,Vector2(62,66)*view.zoom))
 if e.fog_enabled() and not e.state.finished:
  for report in e.state.contacts[side].values():
   var c=report.cell;var p=view.screen(e.index(Vector2i(int(c[0]),int(c[1]))))
   obstacles.append(Rect2(p-Vector2(31,33)*view.zoom,Vector2(62,66)*view.zoom))
 return obstacles
static func begin_labels(view,obstacles: Array):
 var signature=[view.size,view.focus,view.zoom,view.engine.get_instance_id(),obstacles]
 if signature!=view.graphics_label_signature:
  view.graphics_label_signature=signature;view.graphics_label_positions.clear()
static func label_position(view,anchor: Vector2,preferred: Vector2,text_size: Vector2,obstacles: Array,placed: Array,below: bool=false) -> Vector2:
 var z=view.zoom;var half=text_size.x/2.0;var initial=preferred-Vector2(half,0)
 var offsets=[Vector2.ZERO,Vector2(-half-38*z,0),Vector2(half+38*z,0),Vector2(0,50*z),Vector2(-half-38*z,50*z),Vector2(half+38*z,50*z)]
 if not below:offsets.append_array([Vector2(0,-38*z),Vector2(-half-38*z,-38*z),Vector2(half+38*z,-38*z)])
 var key=str([anchor,preferred,text_size,below])
 if not view.graphics_label_signature.is_empty() and view.graphics_label_positions.has(key):
  var cached=view.graphics_label_positions[key];placed.append(Rect2(cached-Vector2(3,text_size.y),text_size+Vector2(6,4)));return cached
 var best=initial;var best_score=INF
 for offset in offsets:
  var p=initial+offset
  p.x=clampf(p.x,4,maxf(4,view.size.x-text_size.x-4));p.y=clampf(p.y,text_size.y+4,maxf(text_size.y+4,view.size.y-5))
  if below and p.y<anchor.y+30*z:continue
  var box=Rect2(p-Vector2(3,text_size.y),text_size+Vector2(6,4));var score=p.distance_to(initial)
  for occupied in obstacles+placed:
   if box.intersects(occupied):score+=box.intersection(occupied).get_area()*100
  if score<best_score:best=p;best_score=score
 placed.append(Rect2(best-Vector2(3,text_size.y),text_size+Vector2(6,4)))
 if not view.graphics_label_signature.is_empty():view.graphics_label_positions[key]=best
 return best
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

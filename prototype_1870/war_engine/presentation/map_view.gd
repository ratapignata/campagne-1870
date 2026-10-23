extends Control
signal cell_tapped(index: int)
signal fire_sound(is_cannon: bool,is_reaction: bool)
signal assault_sound
var help_tip: Panel
var help_title: Label
var help_body: Label
var help_ttl=0.0
var help_unit=-1
var press_age=0.0
var press_pending=false
var press_consumed=false
var press_unit=-1
var press_topic=""
const HELP_DELAY=0.55
var engine
const SupportRules=preload("res://war_engine/core/support.gd")
var supply_overlay_source=-2 # -2 off; -1 all; >=0 one source
var supply_overlay_cells: Dictionary={}
var texts: Dictionary
var selected: int=-1
var target: int=-1
var route: Array=[]
var full_route: Array=[]
var reachable: Dictionary={}
var fire_cells: Dictionary={}
var zoom: float=1.18
var focus=Vector2(765,580)
var font=preload("res://assets/fonts/DejaVuSans.ttf")
const COUNTER_FONT=preload("res://assets/fonts/DejaVuSans-Bold.ttf")
const R=34.0
const Cartography=preload("res://war_engine/presentation/cartography.gd")
const RIVER_FONT=preload("res://assets/fonts/DejaVuSerif-Italic.ttf")
var river_curve: Curve2D
var river_key=""
var river_center=0.0
var down=false
var dragging=false
var origin=Vector2.ZERO
var last=Vector2.ZERO
var touches: Dictionary={}
var multi=false
var crossing_ttl=0.0
var crossing_unit=-1
var crossing_cell=-1
var feedback_cell=-1
var feedback_text=""
var feedback_ttl=0.0
var combat_ttl=0.0
var combat_duration=0.75
var combat_event={}
var combat_feedback=""
var combat_cannon=false
var reaction_sounded=false
var just_finished=false
func _ready():
	clip_contents=true;mouse_filter=Control.MOUSE_FILTER_STOP;set_process(false)
	help_tip=Panel.new();help_tip.mouse_filter=Control.MOUSE_FILTER_IGNORE;help_tip.size=Vector2(398,116)
	var style=StyleBoxFlat.new();style.bg_color=Color("192f31");style.border_color=Color("d4b06c");style.set_border_width_all(1);style.set_corner_radius_all(5)
	help_tip.add_theme_stylebox_override("panel",style);add_child(help_tip);help_tip.hide()
	help_title=Label.new();help_title.position=Vector2(16,10);help_title.size=Vector2(366,26);help_title.add_theme_font_override("font",font);help_title.add_theme_font_size_override("font_size",20);help_title.add_theme_color_override("font_color",Color("d4b06c"));help_title.mouse_filter=Control.MOUSE_FILTER_IGNORE;help_tip.add_child(help_title)
	help_body=Label.new();help_body.position=Vector2(16,41);help_body.size=Vector2(366,66);help_body.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;help_body.add_theme_font_override("font",font);help_body.add_theme_font_size_override("font_size",17);help_body.add_theme_color_override("font_color",Color("eee6cf"));help_body.mouse_filter=Control.MOUSE_FILTER_IGNORE;help_tip.add_child(help_body)
func world(i: int) -> Vector2:
	var c=engine.cell(i);var y=(c.y+0.5*(c.x&1))*sqrt(3.0)*R
	if engine.pack.map.get("north_left",false):y=(engine.height-0.5)*sqrt(3.0)*R-y
	return Vector2(c.x*1.5*R,y)
func screen(i: int) -> Vector2:return (world(i)-focus)*zoom+size/2
func reichshoffen_geometry(anchor: Vector2,text_size: Vector2) -> Dictionary:
	var p=anchor+Vector2(0,-38)*zoom+Cartography.reichshoffen_offset(R)*zoom
	p.x=clampf(p.x-text_size.x/2,8,maxf(8,size.x-text_size.x-8))
	var start=Vector2(p.x+text_size.x/2,p.y+8)
	return {"text":p,"start":start,"tip":start+Vector2(0,sqrt(3.0)*R*zoom)}
func pick(p: Vector2) -> int:
	var w=(p-size/2)/zoom+focus
	if engine.pack.map.get("north_left",false):w.y=(engine.height-0.5)*sqrt(3.0)*R-w.y
	var q=w.x*2.0/(3.0*R);var r=(-w.x/3.0+w.y/sqrt(3.0))/R
	var a=roundi(q);var b=roundi(r);var c=roundi(-q-r)
	var da=abs(a-q);var db=abs(b-r);var dc=abs(c+q+r)
	if da>db and da>dc:a=-b-c
	elif db>dc:b=-a-c
	return engine.index(Vector2i(a,b+int((a-(a&1))/2)))
func clamp_focus():
	var limit=Vector2((engine.width-1)*1.5*R,(engine.height-0.5)*sqrt(3.0)*R)
	focus.x=clampf(focus.x,0,limit.x);focus.y=clampf(focus.y,0,limit.y)
func set_zoom(value: float,anchor: Vector2):
	var before=(anchor-size/2)/zoom+focus;zoom=clampf(value,0.42,2.3)
	focus=before-(anchor-size/2)/zoom;clamp_focus();queue_redraw()
func hexagon(p: Vector2,radius: float) -> PackedVector2Array:
	var a=PackedVector2Array()
	for k in range(6):a.append(p+Vector2(cos(k*PI/3),sin(k*PI/3))*radius)
	return a
func star(p: Vector2,radius: float):
	var points=PackedVector2Array()
	for k in range(10):
		var a=-PI/2+k*PI/5;points.append(p+Vector2(cos(a),sin(a))*radius*(1.0 if k%2==0 else 0.43))
	draw_colored_polygon(points,Color("efcb72"));points.append(points[0]);draw_polyline(points,Color("6e5532"),2*zoom,true)
func outlined_shape(points: PackedVector2Array,fill: Color,edge: Color,width: float):
	draw_colored_polygon(points,fill)
	var border=points.duplicate();border.append(border[0]);draw_polyline(border,edge,width,true)
func supply_wagon(p: Vector2,z: float):
	var ink=Color("39443b");var wood=Color("a47e48");var canvas=Color("f0e4c7")
	draw_line(p+Vector2(-22,8)*z,p+Vector2(22,8)*z,ink,3*z,true)
	draw_line(p+Vector2(17,6)*z,p+Vector2(28,0)*z,wood,3*z,true)
	draw_rect(Rect2(p+Vector2(-18,-5)*z,Vector2(35,12)*z),wood)
	var cover=PackedVector2Array([p+Vector2(-18,-5)*z,p+Vector2(-17,-13)*z,p+Vector2(-11,-19)*z,p+Vector2(10,-19)*z,p+Vector2(16,-13)*z,p+Vector2(17,-5)*z])
	outlined_shape(cover,canvas,ink,1.6*z)
	for x in [-9,8]:draw_line(p+Vector2(x,-18)*z,p+Vector2(x,-5)*z,Color("baa986"),1.2*z,true)
	for x in [-12,12]:
		var hub=p+Vector2(x,10)*z
		draw_circle(hub,6*z,ink);draw_circle(hub,3.5*z,Color("ceb78c"));draw_line(hub-Vector2(4,0)*z,hub+Vector2(4,0)*z,ink,z,true)
func headquarters_symbol(p: Vector2,z: float,french: bool):
	var flag=Rect2(p+Vector2(-22,-21)*z,Vector2(44,30)*z)
	var colors=[Color("285b90"),Color("fff5df"),Color("d25355")] if french else [Color("111c1d"),Color("fff5df"),Color("d25355")]
	for k in range(3):
		var stripe=Rect2(flag.position+Vector2(k*44.0/3,0)*z,Vector2(44.0/3,30)*z) if french else Rect2(flag.position+Vector2(0,k*10)*z,Vector2(44,10)*z)
		draw_rect(stripe,colors[k])
	draw_rect(flag,Color("f2dfad"),false,maxf(.7,z))
func village(p: Vector2,z: float):
	draw_line(p+Vector2(-20,17)*z,p+Vector2(21,-8)*z,Color("b8aa88"),4*z,true)
	var offsets=[Vector2(-12,-3),Vector2(5,8),Vector2(9,-12)]
	for j in range(3):
		var b=p+offsets[j]*z
		draw_rect(Rect2(b+Vector2(-5,0)*z,Vector2(14,10)*z),Color(0.24,0.22,0.15,0.15))
		draw_rect(Rect2(b+Vector2(-7,-2)*z,Vector2(13,9)*z),Color("efdfbe"))
		draw_rect(Rect2(b+Vector2(-7,-2)*z,Vector2(13,9)*z),Color("74654c"),false,maxf(0.8,1.1*z))
		outlined_shape(PackedVector2Array([b+Vector2(-9,-2)*z,b+Vector2(-2,-9)*z,b+Vector2(8,-2)*z]),Color("98604e") if j!=1 else Color("7e6253"),Color("61443a"),maxf(0.9,1.1*z))
		draw_line(b+Vector2(-2,-8)*z,b+Vector2(6,-2)*z,Color("bf8a68"),1.2*z,true)
		draw_rect(Rect2(b+Vector2(-1,2)*z,Vector2(3,5)*z),Color("665d4d"))
		if z>=0.9:draw_rect(Rect2(b+Vector2(-5,0)*z,Vector2(2,2)*z),Color("857862"))
func woodland(p: Vector2,z: float,variant: int):
	var offsets=[Vector2(-11,3),Vector2(9,7),Vector2(0,-10)]
	for j in range(3):
		var offset=offsets[(j+variant)%3]+Vector2((variant-1)*2 if j==0 else 0,variant if j==2 else 0)
		var b=p+offset*z;var radius=(7.0+((j+variant)%3)*0.5)*z
		draw_circle(b+Vector2(2,3)*z,radius,Color(0.26,0.35,0.22,0.24))
		draw_line(b+Vector2(0,4)*z,b+Vector2(0,10)*z,Color("6c7550"),1.6*z,true)
		draw_circle(b,radius,Color("54734f") if (j+variant)%2==0 else Color("627f56"))
		if z>=0.75:
			draw_circle(b+Vector2(-3,-2)*z,radius*0.72,Color("8da179"))
			draw_circle(b+Vector2(3,-3)*z,radius*0.66,Color("82996f"))
func horseman(p: Vector2,z: float,french: bool):
	var edge=Color("152b30");var coat=Color("d8bd88");var light=Color("fff1cc")
	var body=PackedVector2Array([p+Vector2(-17,-1)*z,p+Vector2(-8,-6)*z,p+Vector2(5,-5)*z,p+Vector2(8,-13)*z,p+Vector2(13,-13)*z,p+Vector2(18,-7)*z,p+Vector2(17,-3)*z,p+Vector2(12,-4)*z,p+Vector2(8,5)*z,p+Vector2(-11,6)*z])
	outlined_shape(body,coat,edge,2*z)
	for limb in [[Vector2(-12,4),Vector2(-15,13)],[Vector2(-6,4),Vector2(-3,13)],[Vector2(5,4),Vector2(10,13)],[Vector2(9,1),Vector2(15,9)]]:
		draw_line(p+limb[0]*z,p+limb[1]*z,edge,4*z,true);draw_line(p+limb[0]*z,p+limb[1]*z,coat,2*z,true)
	draw_line(p+Vector2(-16,-1)*z,p+Vector2(-21,6)*z,edge,3*z,true)
	draw_line(p+Vector2(-7,-5)*z,p+Vector2(3,-5)*z,Color("963047") if french else Color("253b39"),5*z,true)
	draw_line(p+Vector2(-3,-10)*z,p+Vector2(0,4)*z,edge,7*z,true)
	draw_line(p+Vector2(-3,-10)*z,p+Vector2(-2,-3)*z,Color("6186a1") if french else Color("8b9b8d"),5*z,true)
	draw_line(p+Vector2(-2,-2)*z,p+Vector2(0,6)*z,Color("ce5960") if french else Color("8b9b8d"),3*z,true)
	draw_circle(p+Vector2(-3,-15)*z,3.4*z,light)
	draw_line(p+Vector2(-7,-18)*z,p+Vector2(1,-18)*z,edge,3*z,true)
	draw_line(p+Vector2(0,-9)*z,p+Vector2(7,-11)*z,light,1.5*z,true)
	draw_line(p+Vector2(7,-11)*z,p+Vector2(10,-20)*z,light,1.4*z,true)
	draw_circle(p+Vector2(13,-9)*z,0.9*z,edge)

func soldier(p: Vector2,z: float,french: bool):
	var coat=Color("84aac5") if french else Color("b1c2ba")
	var trousers=Color("df5861") if french else Color("8da09b");var dark=Color("13242d")
	# Outlined limbs and jacket retain their silhouette at the normal map zoom.
	for leg in [[Vector2(-4,3),Vector2(-7,12)],[Vector2(1,3),Vector2(5,12)]]:
		draw_line(p+leg[0]*z,p+leg[1]*z,dark,6*z,true);draw_line(p+leg[0]*z,p+leg[1]*z,trousers,3.8*z,true)
	draw_line(p+Vector2(-7,12)*z,p+Vector2(-11,12)*z,dark,2.6*z,true)
	draw_line(p+Vector2(5,12)*z,p+Vector2(8,12)*z,dark,2.6*z,true)
	outlined_shape(PackedVector2Array([p+Vector2(-7,-8)*z,p+Vector2(2,-8)*z,p+Vector2(5,3)*z,p+Vector2(-8,3)*z]),coat,dark,1.4*z)
	draw_line(p+Vector2(-5,-7)*z,p+Vector2(1,2)*z,Color("f1e9cc"),1.8*z,true)
	draw_line(p+Vector2(-7,2)*z,p+Vector2(4,2)*z,dark,1.8*z,true)
	draw_line(p+Vector2(-4,-8)*z,p+Vector2(1,-8)*z,Color("d1aa68"),1.2*z,true)
	draw_circle(p+Vector2(-1,-2)*z,0.8*z,Color("f2db9b"))
	draw_circle(p+Vector2(-2,-12)*z,4.5*z,dark);draw_circle(p+Vector2(-2,-12)*z,3.3*z,Color("efd1a8"))
	draw_rect(Rect2(p+Vector2(-6,-18)*z,Vector2(9,4)*z),Color("c75460") if french else dark)
	draw_line(p+Vector2(-7,-14)*z,p+Vector2(4,-14)*z,dark,2*z,true)
	if not french:draw_line(p+Vector2(-2,-18)*z,p+Vector2(-2,-21)*z,Color("e8d298"),1.6*z,true)
	draw_line(p+Vector2(-3,-6)*z,p+Vector2(7,-2)*z,dark,4.7*z,true)
	draw_line(p+Vector2(-3,-6)*z,p+Vector2(7,-2)*z,coat,2.8*z,true)
	draw_line(p+Vector2(6,8)*z,p+Vector2(13,-18)*z,dark,4*z,true)
	draw_line(p+Vector2(6,8)*z,p+Vector2(10,-7)*z,Color("c49b6a"),2.5*z,true)
	draw_line(p+Vector2(10,-7)*z,p+Vector2(13,-18)*z,Color("f0e9d6"),1.8*z,true)
func cannon(p: Vector2,z: float,color: Color,deployed: bool):
	var metal=Color("d9dfd8");var wood=Color("d2ac72");var dark=Color("14262b")
	# Broad tapered tube, visible muzzle and two spoked wheels stay legible at phone scale.
	var far=p+Vector2(-9,5)*z
	draw_circle(far,7*z,dark);draw_arc(far,5.5*z,0,TAU,24,wood.darkened(0.22),2*z,true)
	for k in range(6):draw_line(far,far+Vector2(cos(k*TAU/6),sin(k*TAU/6))*5*z,wood.darkened(0.22),z,true)
	outlined_shape(PackedVector2Array([p+Vector2(-7,0)*z,p+Vector2(2,3)*z,p+Vector2(-18,13)*z,p+Vector2(-22,11)*z]),wood,dark,1.5*z)
	draw_line(p+Vector2(-11,3)*z,p+Vector2(6,5)*z,dark,5*z,true)
	draw_line(p+Vector2(-11,3)*z,p+Vector2(6,5)*z,wood,2.5*z,true)
	outlined_shape(PackedVector2Array([p+Vector2(-13,-5)*z,p+Vector2(10,-15)*z,p+Vector2(13,-9)*z,p+Vector2(-10,2)*z]),metal,dark,1.7*z)
	draw_line(p+Vector2(-10,-4)*z,p+Vector2(9,-12)*z,color,1.2*z,true)
	draw_line(p+Vector2(10,-15)*z,p+Vector2(13,-9)*z,dark,3*z,true)
	draw_line(p+Vector2(10.5,-13.5)*z,p+Vector2(12,-10.5)*z,Color("71817c"),1.2*z,true)
	draw_circle(p+Vector2(-13,-1)*z,2.2*z,dark)
	var near=p+Vector2(3,6)*z
	draw_circle(near,8.5*z,dark);draw_arc(near,6.9*z,0,TAU,32,wood,2.5*z,true)
	for k in range(8):draw_line(near,near+Vector2(cos(k*TAU/8),sin(k*TAU/8))*6.3*z,wood,1.1*z,true)
	draw_circle(near,2.1*z,metal);draw_circle(near,0.8*z,dark)
	if deployed:draw_line(p+Vector2(-22,15)*z,p+Vector2(13,15)*z,Color("e8c57b"),1.4*z,true)
	else:draw_arc(p+Vector2(-23,11)*z,2*z,-PI/2,PI/2,8,wood,1.4*z,true)
func selection_outline(p: Vector2,z: float):
	var points=PackedVector2Array()
	for v in [Vector2(-24,-30),Vector2(24,-30),Vector2(29,-25),Vector2(29,25),Vector2(24,30),Vector2(-24,30),Vector2(-29,25),Vector2(-29,-25),Vector2(-24,-30)]:points.append(p+v*z)
	draw_polyline(points,Color("263d3b"),maxf(5,7*z),true)
	draw_polyline(points,Color("ffe27a"),maxf(3.0,4.5*z),true)
func hq_member_highlighted(n: int) -> bool:
	if target>=0 or not engine.alive(selected) or not engine.headquarters(selected) or not engine.alive(n) or n==selected:return false
	var hq=engine.state.units[selected];var member=engine.state.units[n]
	return int(hq.side)==int(engine.state.human_side) and int(member.side)==int(hq.side) and member.get("command_group","")==hq.get("command_group","")
func hq_outline(p: Vector2,z: float):
	var rect=Rect2(p+Vector2(-29,-30)*z,Vector2(58,60)*z)
	draw_rect(rect,Color("163b25"),false,maxf(3,4*z))
	draw_rect(rect,Color("65ff45"),false,maxf(1.75,2.25*z))
func counter_back(p: Vector2,z: float,ink: Color,current: bool=true):
	var shape=PackedVector2Array()
	for v in [Vector2(-23,-27),Vector2(23,-27),Vector2(26,-24),Vector2(26,24),Vector2(23,27),Vector2(-23,27),Vector2(-26,24),Vector2(-26,-24)]:shape.append(p+v*z)
	var shadow=shape.duplicate()
	for k in range(shadow.size()):shadow[k]+=Vector2(1.5,2)*z
	draw_colored_polygon(shadow,Color(0.08,0.15,0.17,0.3))
	outlined_shape(shape,ink,Color("142c31"),2.4*z)
	draw_line(p+Vector2(-22,-25)*z,p+Vector2(22,-25)*z,Color("e6d8b7") if current else Color("9da78f"),1.2*z,true)
	draw_line(p+Vector2(-24,-23)*z,p+Vector2(-24,12)*z,ink.lightened(0.24),1.0*z,true)
func counter_number(p: Vector2,z: float,value) -> void:
	var text="" if str(value).is_empty() else str(int(value))
	var font_size=maxi(8,int((9 if text.length()>2 else 13)*z))
	var text_width=COUNTER_FONT.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x
	# Fit the complete number inside the right edge; V42 adds three-digit IDs.
	draw_string(COUNTER_FONT,p+Vector2(25*z-text_width,-8*z),text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,Color("ffffff"))
func contours(p: Vector2,z: float,variant: int=0):
	for level in range(3):
		var radius=25-level*7;var points=PackedVector2Array();var phase=variant*0.7
		for k in range(33):
			var a=k*TAU/32;var wave=1.0+0.08*sin(a*3+phase)+0.05*cos(a*5-phase)
			points.append(p+(Vector2(cos(a)*radius*wave,sin(a)*radius*0.64*wave)+Vector2(-2+level,-2))*z)
		if level==0:draw_colored_polygon(points,Color(0.42,0.45,0.26,0.055))
		draw_polyline(points,Color(0.43,0.35,0.20,0.58),maxf(0.9,1.15*z),true)
# Public topography, independent of spotting and terrain cover.
func relief_edges(i: int) -> Array:
	var result=[]
	if not engine.pack.map.get("show_relief",true) or not engine.pack.map.has("elevations") or engine.cost(i)<0:return result
	for n in engine.neighbours(i):
		if engine.cost(n)>=0 and engine.elevation(i)>engine.elevation(n):result.append(n)
	return result
func crossing_edges(path: Array) -> Array:
	var result=[]
	for k in range(1,path.size()):
		if engine.open_river(int(path[k-1]),int(path[k])):result.append([int(path[k-1]),int(path[k])])
	return result
func animate_crossing(n: int):
	if not engine.alive(n) or not engine.visible_to(int(engine.state.human_side),n):return
	crossing_unit=n;crossing_cell=engine.unit_cell(engine.state.units[n]);crossing_ttl=0.65
	set_process(true);queue_redraw()
func projectile_ink(is_cannon: bool) -> Color:
	return Color("101214") if is_cannon else Color(1.0,0.81,0.40,0.9)
func shot_effect(origin: Vector2,dest: Vector2,progress: float,is_cannon: bool):
	if progress<0.0 or progress>1.0:return
	var direction=(dest-origin).normalized()
	if direction.length_squared()<0.01:return
	var side=Vector2(-direction.y,direction.x)
	var muzzle=origin+direction*19.0*zoom
	var scale=1.6 if is_cannon else 1.0
	# Bright muzzle blast: larger for artillery, but short-lived to keep AI turns brisk.
	if progress<0.23:
		var flash_fade=1.0-progress/0.23
		var flash=Color(1.0,0.78,0.27,flash_fade)
		var tip=muzzle+direction*(24.0 if is_cannon else 14.0)*zoom
		draw_line(muzzle,tip,flash,(9.0 if is_cannon else 5.0)*zoom*flash_fade,true)
		draw_circle(muzzle+direction*8.0*zoom,(9.0 if is_cannon else 5.0)*zoom*flash_fade,Color(1.0,0.95,0.65,flash_fade))
		for k in range(4):
			var angle=(float(k)-1.5)*0.36
			var ray=direction.rotated(angle)
			draw_line(muzzle,muzzle+ray*(19.0 if is_cannon else 11.0)*zoom,flash,(3.5 if is_cannon else 2.0)*zoom*flash_fade,true)
	# Rolling gun smoke; rifle smoke is smaller but clearly distinguishable.
	var smoke=Color(0.88,0.86,0.78,(0.85 if is_cannon else 0.67)*(1.0-progress))
	for k in range(7 if is_cannon else 4):
		var drift=direction*(float(k)*5.0+progress*18.0)+side*sin(float(k)*2.1)*8.0+Vector2(0,-progress*23.0)
		draw_circle(muzzle+drift*zoom,(4.0+float(k)*1.7+progress*12.0)*scale*zoom,smoke)
	# A visible travelling tracer and target impact make the shot direction legible.
	if progress>=0.12 and progress<0.63:
		var travel=(progress-0.12)/0.51
		var tracer=muzzle.lerp(dest,travel)
		if is_cannon:
			var radius=maxf(2.2,4.5*zoom)
			draw_line(tracer-direction*12.0*zoom,tracer,Color(0.06,0.07,0.08,0.6),maxf(1.0,2.0*zoom),true)
			draw_circle(tracer,radius+maxf(0.65,0.65*zoom),Color("b1b7b8"))
			draw_circle(tracer,radius,projectile_ink(true))
		else:draw_circle(tracer,2.8*zoom,projectile_ink(false))
	if progress>=0.48:
		var phase=(progress-0.48)/0.52
		var fade=1.0-phase
		var dust=Color(0.53,0.41,0.28,fade*0.76)
		for k in range(5 if is_cannon else 3):
			var offset=side*(float(k)-2.0)*7.0+Vector2(0,-phase*20.0)
			draw_circle(dest+offset*zoom,(4.0+phase*14.0)*scale*zoom,dust)
		draw_arc(dest,(8.0+phase*(25.0 if is_cannon else 14.0))*zoom,0,TAU,28,Color(0.95,0.72,0.35,fade*0.85),(3.5 if is_cannon else 2.0)*zoom,true)
func shovel(p: Vector2,z: float):
	var metal=Color("fff2c8")
	draw_circle(p,11*z,Color("14272d"));draw_circle(p,9.5*z,Color("244043"));draw_arc(p,9.5*z,0,TAU,24,Color("e4c486"),1.5*z,true)
	draw_rect(Rect2(p+Vector2(-3,-8)*z,Vector2(6,4)*z),metal,false,1.6*z)
	draw_line(p+Vector2(0,-4)*z,p+Vector2(0,2)*z,Color("deb985"),2.6*z,true)
	draw_colored_polygon(PackedVector2Array([p+Vector2(-4,1)*z,p+Vector2(4,1)*z,p+Vector2(4,5)*z,p+Vector2(0,8)*z,p+Vector2(-4,5)*z]),metal)
func set_supply_overlay(source_index: int):
	supply_overlay_source=source_index
	supply_overlay_cells={}
	if engine!=null and source_index!=-2 and engine.fixed_hq():
		supply_overlay_cells=SupportRules.supply_coverage(engine,int(engine.state.human_side),source_index)
	queue_redraw()

func refresh_supply_overlay():
	if supply_overlay_source!=-2:set_supply_overlay(supply_overlay_source)

func _draw():
	if engine==null:return
	draw_rect(Rect2(Vector2.ZERO,size),Color("c4c8aa"))
	for i in range(engine.width*engine.height):
		var p=screen(i);var z=zoom;var h=R*z
		if p.x< -h or p.y< -h or p.x>size.x+h or p.y>size.y+h:continue
		var terrain_key=engine.pack.map.tiles[i];var terrain=str(engine.pack.terrains[terrain_key].get("visual_type",terrain_key));var polygon=hexagon(p,h)
		draw_colored_polygon(polygon,Color(engine.pack.terrains[terrain_key].color))
		if supply_overlay_source!=-2 and engine.fixed_hq():
			var known=not engine.fog_enabled() or engine.state.finished or engine.cell_visible(int(engine.state.human_side),i)
			var fill=Color(0.76,0.19,0.19,0.37) if known and supply_overlay_cells.has(i) else Color(0.37,0.40,0.42,0.37)
			draw_colored_polygon(polygon,fill)
		var outline=polygon.duplicate();outline.append(polygon[0]);draw_polyline(outline,Color(0.22,0.29,0.22,0.17),0.7,true)
		for lower in relief_edges(i):
			var normal=(screen(lower)-p).normalized();var middle=(p+screen(lower))/2
			var tangent=Vector2(-normal.y,normal.x)*R*z*0.5
			draw_line(middle-tangent,middle+tangent,Color(0.40,0.32,0.21,0.60),maxf(1.1,1.7*z),true)
			if engine.elevation(i)>=2:
				var inset=normal*4*z
				draw_line(middle-tangent*0.85-inset,middle+tangent*0.85-inset,Color(0.40,0.32,0.21,0.40),maxf(1.0,1.2*z),true)
		if engine.pack.map.get("show_relief",true) and engine.elevation(i)>=2 and terrain!="hill":contours(p,z*0.72,i%4)
		var road_ends=[]
		for edge in engine.pack.map.get("road_edges",[]):
			if int(edge[0])==i or int(edge[1])==i:
				var other=int(edge[1]) if int(edge[0])==i else int(edge[0])
				road_ends.append((p+screen(other))/2)
		for exit in engine.pack.map.get("road_exits",[]):
			if int(exit.cell[0])==i%engine.width and int(exit.cell[1])==i/engine.width:
				var sign_y=-1.0 if engine.pack.map.get("north_left",false) else 1.0
				road_ends.append(p+Vector2(float(exit.direction[0])*R,float(exit.direction[1])*sqrt(3.0)*R*0.5*sign_y)*z)
		if road_ends.size()==2:
			var curve=PackedVector2Array()
			for k in range(9):
				var t=float(k)/8.0
				curve.append(road_ends[0].lerp(p,t).lerp(p.lerp(road_ends[1],t),t))
			draw_polyline(curve,Color("ae9974"),4*z,true)
		else:
			for end in road_ends:draw_line(p,end,Color("ae9974"),4*z,true)
		if terrain=="forest":woodland(p,z,i%3)
		elif terrain=="hill" and engine.pack.map.get("show_relief",true):contours(p,z,i%4)
		elif terrain=="village":village(p,z)
		elif terrain=="road" or terrain=="bridge":
			for n in engine.neighbours(i):
				if not engine.pack.map.has("road_edges") and engine.pack.map.tiles[n] in ["road","bridge"]:draw_line(p,(p+screen(n))/2,Color("ae9974"),4*z,true)
			if terrain=="bridge":
				for y in [-6,6]:draw_line(p+Vector2(-19,y)*z,p+Vector2(19,y)*z,Color("665c49"),3*z,true)
		elif terrain=="water":draw_line(p-Vector2(5,19)*z,p+Vector2(3,19)*z,Color("bbd2c9"),2*z,true)
		if not engine.cell_visible(int(engine.state.human_side),i):draw_colored_polygon(polygon,Color(0.13,0.20,0.20,0.29))
		if fire_cells.has(i) and engine.artillery(selected) and not busy():
			draw_colored_polygon(hexagon(p,h-2),Color(1.0,0.96,0.76,0.34))
		if reachable.has(i) and (fire_cells.is_empty() or not engine.artillery(selected)):
			draw_colored_polygon(hexagon(p,h-2),Color(0.15,0.50,0.41,0.19))
			if engine.known_unit_at(i,int(engine.state.human_side))<0:draw_circle(p,2.8*z,Color(0.2,0.44,0.36,0.5))
	# River boundaries are public map information. One permanent road bridge; no repairs.
	for edge in engine.pack.map.get("river_edges",[]):
		var a=screen(int(edge.a));var b=screen(int(edge.b));var middle=(a+b)/2
		var normal=(b-a).normalized();var tangent=Vector2(-normal.y,normal.x)*R*zoom/2
		draw_line(middle-tangent,middle+tangent,Color("5792a5"),5*zoom,true)
		if bool(edge.bridge) or edge.has("bridge_from_turn"):
			draw_line(middle-normal*14*zoom,middle+normal*14*zoom,Color("ede2bb"),10*zoom,true)
			for sign in [-1,1]:
				var shift=tangent.normalized()*sign*5*zoom
				draw_line(middle-normal*15*zoom+shift,middle+normal*15*zoom+shift,Color("6c5942"),2*zoom,true)
			if engine.open_river(int(edge.a),int(edge.b)):
				draw_line(middle+Vector2(-10,-10)*zoom,middle+Vector2(10,10)*zoom,Color("963c31"),3*zoom,true)
				draw_line(middle+Vector2(-10,10)*zoom,middle+Vector2(10,-10)*zoom,Color("963c31"),3*zoom,true)
	draw_sauer()
	for location in engine.pack.map.get("labels",[]):
		var c=location.cell;var anchor=screen(engine.index(Vector2i(int(c[0]),int(c[1]))));var p=anchor+Vector2(0,-38)*zoom
		var fs=maxi(11,int(16*zoom));var text_size=font.get_string_size(location.text,HORIZONTAL_ALIGNMENT_LEFT,-1,fs)
		if location.has("arrow_cell"):
			if anchor.x< -text_size.x or anchor.x>size.x+text_size.x or anchor.y< -80 or anchor.y>size.y+100:continue
			# One hexagon high, plain downward arrow in the exact road colour.
			# Translate the complete world-anchored group. Viewport clamping would cancel this offset.
			var geometry=reichshoffen_geometry(anchor,text_size);p=geometry.text
			var start=geometry.start;var tip=geometry.tip
			var road_colour=Color("ae9974");var stroke=maxf(1.5,3*zoom)
			draw_line(start,tip,road_colour,stroke,true)
			draw_polyline(PackedVector2Array([tip+Vector2(-12,-14)*zoom,tip,tip+Vector2(12,-14)*zoom]),road_colour,stroke,true)
		else:p.x-=text_size.x/2
		draw_string_outline(font,p,location.text,HORIZONTAL_ALIGNMENT_LEFT,-1,fs,3,Color("ece7d1"))
		draw_string(font,p,location.text,HORIZONTAL_ALIGNMENT_LEFT,-1,fs,Color("435749"))
	if selected>=0 and engine.alive(selected) and (not engine.fog_enabled() or int(engine.state.units[selected].side)==int(engine.state.human_side)):
		var center=engine.unit_cell(engine.state.units[selected]);var max_range=1 if engine.cavalry(selected) else int(engine.weapon(selected).range)
		for i in range(engine.width*engine.height):
			if engine.distance(center,i)>max_range:continue
			var p=screen(i);var vertices=hexagon(p,R*zoom-1)
			for k in range(6):
				var midpoint=(vertices[k]+vertices[(k+1)%6])/2
				var across=pick(midpoint+(midpoint-p).normalized()*3*zoom)
				if across<0 or engine.distance(center,across)>max_range:draw_dashed_line(vertices[k],vertices[(k+1)%6],Color("b04f42"),1.8*zoom,4*zoom,true,true)
	if full_route.size()>route.size():
		for k in range(maxi(1,route.size()),full_route.size()):draw_dashed_line(screen(full_route[k-1]),screen(full_route[k]),Color("7b7f6d"),2*zoom,6*zoom,true,true)
	if route.size()>1:
		var points=PackedVector2Array()
		for i in route:points.append(screen(i))
		draw_polyline(points,Color("465448"),7*zoom,true);draw_polyline(points,Color("f6d57f"),4*zoom,true)
		for j in range(1,route.size()):draw_circle(screen(route[j]),4*zoom,Color("fff0bc"))
		var endpoint=screen(route[-1]);draw_arc(endpoint,25*zoom,0,TAU,40,Color("66552f"),5*zoom,true);draw_arc(endpoint,25*zoom,0,TAU,40,Color("f5d37d"),2.5*zoom,true)
		if full_route.size()>route.size():draw_string(font,endpoint+Vector2(-30,-32)*zoom,texts.limit,HORIZONTAL_ALIGNMENT_CENTER,60*zoom,int(14*zoom),Color("283b33"))
	# Only the currently confirmable route receives a crossing marker.
	for edge in crossing_edges(route):
		var a=screen(edge[0]);var b=screen(edge[1]);var middle=(a+b)/2
		var direction=(b-a).normalized();var side=Vector2(-direction.y,direction.x)
		var tail=middle-direction*16*zoom;var tip=middle+direction*16*zoom
		var arrow=PackedVector2Array([tip-direction*9*zoom+side*7*zoom,tip,tip-direction*9*zoom-side*7*zoom])
		draw_line(tail,tip,Color("e6f4ef"),7*zoom,true);draw_polyline(arrow,Color("e6f4ef"),7*zoom,true)
		draw_line(tail,tip,Color("237aab"),3.5*zoom,true);draw_polyline(arrow,Color("237aab"),3.5*zoom,true)
	if engine.fixed_hq():
		for c in engine.pack.rules.support.supply_sources[int(engine.state.human_side)]:
			var depot=screen(engine.index(Vector2i(int(c[0]),int(c[1]))))
			if engine.known_unit_at(engine.index(Vector2i(int(c[0]),int(c[1]))),int(engine.state.human_side))>=0:depot+=Vector2(-24,-25)*zoom
			supply_wagon(depot,zoom)
			if supply_overlay_source!=-2:
				var active=supply_overlay_source==-1 or supply_overlay_source==engine.pack.rules.support.supply_sources[int(engine.state.human_side)].find(c)
				if active:draw_arc(depot,27*zoom,0,TAU,30,Color("ffe0a2"),2.8*zoom,true)
	for n in range(engine.state.units.size()):
		if not engine.alive(n) or (engine.fog_enabled() and not engine.state.finished and int(engine.state.units[n].side)!=int(engine.state.human_side)):continue
		var u=engine.state.units[n];var p=screen(engine.unit_cell(u));var z=zoom
		if combat_ttl>0:
			var progress=1.0-combat_ttl/combat_duration
			var path=[]
			if n==int(combat_event.target):path=combat_event.retreat
			elif n==int(combat_event.shooter):path=combat_event.attacker_retreat if not combat_event.attacker_retreat.is_empty() else combat_event.advance
			if not path.is_empty():p=screen(int(path[0])).lerp(p,clampf((progress-0.5)/0.5,0,1))
			if engine.artillery(n):
				var firing=n==int(combat_event.shooter) and combat_event.kind=="fire"
				var replying=n==int(combat_event.target) and combat_event.reaction
				var recoil_phase=progress if firing else progress-(0.0 if combat_event.kind in ["assault","charge"] else 0.32)
				if (firing or replying) and recoil_phase>=0 and recoil_phase<0.3:p+=Vector2(-sin(recoil_phase/0.3*PI)*3*zoom,0)
		if n==selected:selection_outline(p,z)
		if hq_member_highlighted(n):hq_outline(p,z)
		var ink=Color("568db4") if int(u.side)==0 else Color("43504c")
		var actionable=engine.actionable(n)
		if u.done or int(u.ap)==0:ink=ink.lerp(Color("869088"),0.45)
		if fire_target_lit(n):ink=ink.lerp(Color("fff0bc"),0.42)
		counter_back(p,z,ink,actionable)
		if engine.headquarters(n):headquarters_symbol(p,z,int(u.side)==0)
		elif engine.artillery(n):cannon(p+Vector2(-1,-3)*z,z,Color("fff3d1"),u.deployed)
		elif engine.cavalry(n):horseman(p+Vector2(-3,-3)*z,1.04*z,int(u.side)==0)
		else:soldier(p+Vector2(-5,-1)*z,1.10*z,int(u.side)==0)
		draw_rect(Rect2(p+Vector2(-25,14)*z,Vector2(50,12)*z),Color("963047") if int(u.side)==0 else Color("273532"))
		# Vertical French tricolour / horizontal black-white-red: shape and colour identify camp.
		if not engine.headquarters(n):
			var flag_origin=p+Vector2(-22,16)*z
			var flag_colors=[Color("285b90"),Color("fff5df"),Color("d25355")] if int(u.side)==0 else [Color("111c1d"),Color("fff5df"),Color("d25355")]
			for stripe in range(3):
				var flag_rect=Rect2(flag_origin+Vector2(stripe*4,0)*z,Vector2(4,8)*z) if int(u.side)==0 else Rect2(flag_origin+Vector2(0,stripe*8.0/3)*z,Vector2(12,8.0/3)*z)
				draw_rect(flag_rect,flag_colors[stripe])
			draw_rect(Rect2(flag_origin,Vector2(12,8)*z),Color("d9d9c5"),false,maxf(0.4,0.6*z))
		draw_rect(Rect2(p+Vector2(-4,12)*z,Vector2(28,14)*z),Color("963047") if int(u.side)==0 else Color("162c31"))
		draw_string(COUNTER_FONT,p+Vector2(-3,25)*z,str(maxi(1,ceili(float(u.strength)/float(u.initial_strength)*10))),HORIZONTAL_ALIGNMENT_CENTER,26*z,maxi(6,int(14*z)),Color("ffffff"))
		if u.done or int(u.ap)==0:draw_string(font,p+Vector2(9,8)*z,"✓",HORIZONTAL_ALIGNMENT_LEFT,-1,maxi(10,int(16*z)),Color("e9e1c9"))
		if u.morale=="shaken":
			disorder_badge(p,z)
		elif u.morale=="routed":
			var badge=p+Vector2(-23,-16)*z
			draw_circle(badge,10*z,Color("152a2f"));draw_circle(badge,8.5*z,Color("b95343"));draw_string(font,badge+Vector2(-5,5)*z,"»",HORIZONTAL_ALIGNMENT_CENTER,10*z,maxi(10,int(15*z)),Color("fff3db"))
		if engine.fixed_hq() and not engine.headquarters(n) and int(u.side)==int(engine.state.human_side) and u.get("is_hq",false):
			var badge=Rect2(p+Vector2(-15,-43)*z,Vector2(30,15)*z)
			draw_rect(badge,Color("203533"));draw_rect(badge,Color("d4b06c"),false,maxf(1,zoom))
			draw_string(COUNTER_FONT,p+Vector2(-13,-31)*z,str(texts.get("hq_badge","QG")),HORIZONTAL_ALIGNMENT_CENTER,26*z,maxi(9,int(12*z)),Color("f5d483"))
		if u.get("entrenched",false):shovel(p+Vector2(21,3)*z,z)
		# Draw outside the counter and selection so the red border stays visible.
		# Both links must be cut; enemy logistics are never exposed.
		if int(u.side)==int(engine.state.human_side) and not u.get("command_ok",true) and not u.get("supply_ok",true):
			var isolated_rect=Rect2(p+Vector2(-29,-30)*z,Vector2(58,60)*z)
			draw_rect(isolated_rect,Color("4a1015"),false,maxf(3,4*z))
			draw_rect(isolated_rect,Color("ff4545"),false,maxf(1.75,2.25*z))
		if n==target:
			draw_arc(p,33*z,0,TAU,32,Color("b04f42"),3*z,true)
			for v in [Vector2(-1,0),Vector2(1,0),Vector2(0,-1),Vector2(0,1)]:draw_line(p+v*28*z,p+v*37*z,Color("b04f42"),3*z,true)
	if engine.fog_enabled() and not engine.state.finished:
		for key in engine.state.contacts[int(engine.state.human_side)]:draw_contact(int(key))
	for goal in engine.objective_definitions():
		var objective=screen(engine.objective_cell(goal))
		if engine.known_unit_at(engine.objective_cell(goal),int(engine.state.human_side))>=0:objective+=Vector2(25,-24)*zoom
		star(objective,19*zoom)
		if engine.objective_definitions().size()>1:draw_string(font,objective+Vector2(-4,5)*zoom,str(int(goal.points)),HORIZONTAL_ALIGNMENT_CENTER,10*zoom,maxi(10,int(12*zoom)),Color("302b20"))
		var owner=engine.objective_owner(goal)
		if owner>=0:
			var marker=Rect2(objective+Vector2(-18,20)*zoom,Vector2(36,17)*zoom)
			draw_rect(marker,Color("568db4") if owner==0 else Color("43504c"))
			draw_string(font,marker.position+Vector2(2,13)*zoom,texts.fr_short if owner==0 else texts.de_short,HORIZONTAL_ALIGNMENT_CENTER,32*zoom,maxi(10,int(12*zoom)),Color("fff3dc"))
	draw_string(font,Vector2(size.x-70,31),str(texts.get("north_left" if engine.pack.map.get("north_left",false) else "north","N")),HORIZONTAL_ALIGNMENT_CENTER,55,16,Color("53614d"))
	if combat_ttl>0:
		var origin=screen(engine.index(Vector2i(combat_event.from[0],combat_event.from[1])))
		var dest=screen(engine.index(Vector2i(combat_event.to[0],combat_event.to[1])))
		var progress=1.0-combat_ttl/combat_duration
		if combat_event.kind=="fire":shot_effect(origin,dest,progress*1.3,combat_cannon)
		else:
			var approach=clampf(progress/0.6,0,1)
			var point=origin.lerp(dest,approach*0.65)
			draw_line(origin,point,Color(0.95,0.81,0.5,0.65*(1-progress)),3*zoom,true)
			if progress>0.45:draw_arc(dest,(6+(progress-0.45)*20)*zoom,0,TAU,20,Color(0.74,0.47,0.26,1-progress),2*zoom,true)
		if combat_event.reaction:
			var phase=(progress-(0.0 if combat_event.kind in ["assault","charge"] else 0.32))*1.5
			shot_effect(dest,origin,phase,combat_event.reaction_cannon)
			if phase>=0 and phase<1.0:
				var callout=dest+Vector2(-43,-49)*zoom
				callout.x=clampf(callout.x,4,size.x-90*zoom);callout.y=maxf(23*zoom,callout.y)
				draw_rect(Rect2(callout-Vector2(4,19)*zoom,Vector2(94,26)*zoom),Color(0.1,0.19,0.2,0.86))
				draw_string(font,callout,texts.reaction_label,HORIZONTAL_ALIGNMENT_CENTER,86*zoom,maxi(13,int(18*zoom)),Color("fff0bc"))
	if crossing_ttl>0 and engine.alive(crossing_unit) and engine.visible_to(int(engine.state.human_side),crossing_unit) and engine.unit_cell(engine.state.units[crossing_unit])==crossing_cell:
		var progress=1.0-crossing_ttl/0.65;var water=Color("367f9b");water.a=(1.0-progress)*0.85
		var feet=screen(crossing_cell)+Vector2(0,25)*zoom
		for ring in range(3):
			var radius=(10+ring*6+progress*10)*zoom;var ripple=PackedVector2Array()
			for k in range(25):
				var angle=k*TAU/24
				ripple.append(feet+Vector2(cos(angle)*radius,sin(angle)*radius*0.30))
			draw_polyline(ripple,water,1.7*zoom,true)
	if feedback_ttl>0 and feedback_cell>=0:
		var p=screen(feedback_cell)+Vector2(0,-65*zoom);var fs=22
		while fs>15 and font.get_string_size(feedback_text,HORIZONTAL_ALIGNMENT_LEFT,-1,fs).x>size.x-50:fs-=1
		var w=font.get_string_size(feedback_text,HORIZONTAL_ALIGNMENT_LEFT,-1,fs).x+30
		p.x=clampf(p.x,w/2+10,size.x-w/2-10);p.y=clampf(p.y,50,size.y-30)
		draw_rect(Rect2(p-Vector2(w/2,28),Vector2(w,44)),Color("223b39"))
		draw_string(font,p-Vector2(w/2-15,0),feedback_text,HORIZONTAL_ALIGNMENT_LEFT,-1,fs,Color("f6d996"))
func contact_power_text(n: int) -> String:
	var side=int(engine.state.human_side)
	if not engine.visible_to(side,n):return ""
	var report=engine.contact(n,side)
	return str(int(report.exact_power)) if report.has("exact_power") else "?"
func fire_target_lit(n: int) -> bool:
	return not busy() and engine.alive(n) and int(engine.state.units[n].side)!=int(engine.state.human_side) and engine.visible_to(int(engine.state.human_side),n) and fire_cells.has(engine.unit_cell(engine.state.units[n]))
func draw_contact(n: int):
	var side=int(engine.state.human_side);var report=engine.contact(n,side)
	var c=report.cell;var p=screen(engine.index(Vector2i(int(c[0]),int(c[1]))));var z=zoom;var current=engine.visible_to(side,n)
	var ink=Color("568db4") if side==1 else Color("43504c")
	if not current:ink=ink.lerp(Color("a3aa96"),0.65)
	if fire_target_lit(n):ink=ink.lerp(Color("fff0bc"),0.42)
	counter_back(p,z,ink,current)
	if report.type=="cavalry":horseman(p+Vector2(-3,-3)*z,1.04*z,side==1)
	elif report.type=="hq":headquarters_symbol(p,z,int(engine.state.units[n].side)==0)
	elif report.type=="artillery":cannon(p+Vector2(-1,-3)*z,z,Color("fff3d1"),bool(report.deployed))
	else:soldier(p+Vector2(-5,-1)*z,1.10*z,side==1)
	draw_rect(Rect2(p+Vector2(-25,14)*z,Vector2(50,12)*z),Color("963047") if side==1 else Color("273532"))
	if report.type!="hq":
		var flag_origin=p+Vector2(-22,16)*z
		var colors=[Color("285b90"),Color("fff5df"),Color("d25355")] if side==1 else [Color("111c1d"),Color("fff5df"),Color("d25355")]
		for stripe in range(3):
			var rect=Rect2(flag_origin+Vector2(stripe*4,0)*z,Vector2(4,8)*z) if side==1 else Rect2(flag_origin+Vector2(0,stripe*8.0/3)*z,Vector2(12,8.0/3)*z)
			draw_rect(rect,colors[stripe])
	draw_string(COUNTER_FONT,p+Vector2(-3,25)*z,contact_power_text(n),HORIZONTAL_ALIGNMENT_CENTER,26*z,maxi(8,int(14*z)),Color("fff3dc"))
	if current and int(report.level)==2:
		if report.morale=="shaken":
			disorder_badge(p,z)
		if report.entrenched:shovel(p+Vector2(21,3)*z,z)
	if n==target:draw_arc(p,33*z,0,TAU,32,Color("b04f42"),3*z,true)
	elif n==selected and current:selection_outline(p,z)
func show_feedback(i: int,value: String):
	if value.is_empty():return
	feedback_cell=i;feedback_text=value;feedback_ttl=1.3;set_process(true);queue_redraw()
func busy() -> bool:return combat_ttl>0
func animate_fire(event: Dictionary,feedback: String,is_cannon: bool):
	cancel_interaction()
	combat_event=event.duplicate(true);combat_feedback=feedback;combat_cannon=is_cannon
	combat_duration=1.15 if event.reaction else 0.85
	if event.kind in ["assault","charge"]:combat_duration=1.15
	if int(engine.state.side)!=int(engine.state.human_side):combat_duration*=0.6
	combat_ttl=combat_duration;feedback_ttl=0;just_finished=false;reaction_sounded=false;set_process(true);queue_redraw()
	if event.kind=="fire":fire_sound.emit(is_cannon,false)
	else:
		assault_sound.emit()
		if event.reaction:fire_sound.emit(event.reaction_cannon,true);reaction_sounded=true
func _process(delta: float):
	if press_pending:
		press_age+=delta
		if press_age>=HELP_DELAY:
			press_pending=false;press_consumed=true
			if not busy() and engine.alive(press_unit):
				var u=engine.state.units[press_unit]
				if (press_topic=="shaken" and u.morale=="shaken") or (press_topic=="entrenched" and u.get("entrenched",false)):
					help_unit=press_unit;help_title.text=texts["tip_"+press_topic+"_title"];help_body.text=texts["tip_"+press_topic+"_body"]
					help_ttl=4.0;help_tip.show();position_help()
	if help_ttl>0:
		help_ttl=maxf(0,help_ttl-delta)
		if help_ttl<=0:help_tip.hide()
	crossing_ttl=maxf(0,crossing_ttl-delta)
	feedback_ttl=maxf(0,feedback_ttl-delta)
	if combat_ttl>0:
		combat_ttl=maxf(0,combat_ttl-delta)
		if combat_event.reaction and not reaction_sounded and 1.0-combat_ttl/combat_duration>=0.32:
			reaction_sounded=true;fire_sound.emit(combat_event.reaction_cannon,true)
		if combat_ttl<=0:
			just_finished=true;show_feedback(engine.index(Vector2i(combat_event.to[0],combat_event.to[1])),combat_feedback)
	queue_redraw()
	if crossing_ttl<=0 and feedback_ttl<=0 and combat_ttl<=0 and help_ttl<=0 and not press_pending:set_process(false)
func position_help():
	if help_unit<0:return
	var anchor=screen(engine.unit_cell(engine.state.units[help_unit]))
	help_tip.position=Vector2(clampf(anchor.x-help_tip.size.x/2,8,size.x-help_tip.size.x-8),clampf(anchor.y-34*zoom-help_tip.size.y-10,8,size.y-help_tip.size.y-8))
func dismiss_help():
	help_ttl=0
	if help_tip!=null:help_tip.hide()
func cancel_interaction():
	press_pending=false;press_consumed=true;down=false;dragging=false;multi=false;touches.clear();dismiss_help()
func begin_press(point: Vector2):
	dismiss_help();press_pending=false;press_consumed=false;press_age=0;press_unit=-1;press_topic=""
	if busy():press_consumed=true;return
	var nearest=INF
	for n in range(engine.state.units.size()):
		if not engine.alive(n) or (engine.fog_enabled() and not engine.state.finished and int(engine.state.units[n].side)!=int(engine.state.human_side)):continue
		var u=engine.state.units[n]
		if u.morale!="shaken" and not u.get("entrenched",false):continue
		var offset=point-screen(engine.unit_cell(u));var extent=maxf(22,34*zoom)
		if absf(offset.x)>extent or absf(offset.y)>extent or offset.length_squared()>=nearest:continue
		nearest=offset.length_squared();press_unit=n
		# A forgiving finger target: the left side is D, the right side is the shovel.
		press_topic="entrenched" if u.get("entrenched",false) and (u.morale!="shaken" or offset.x>8*zoom) else "shaken"
	if press_unit>=0:press_pending=true;set_process(true)
func _gui_input(event):
	# Ignore emulated mouse duplicates: touch and pinch are handled directly.
	if event is InputEventMouse and event.device==InputEvent.DEVICE_ID_EMULATION:return
	if event is InputEventMouseButton and touches.is_empty():
		if event.button_index==MOUSE_BUTTON_WHEEL_UP and event.pressed:press_pending=false;press_consumed=true;dismiss_help();set_zoom(zoom*1.12,event.position)
		elif event.button_index==MOUSE_BUTTON_WHEEL_DOWN and event.pressed:press_pending=false;press_consumed=true;dismiss_help();set_zoom(zoom/1.12,event.position)
		elif event.button_index==MOUSE_BUTTON_LEFT:
			if event.pressed:down=true;dragging=false;origin=event.position;last=event.position;begin_press(event.position)
			else:
				press_pending=false
				if down and not dragging and not press_consumed:cell_tapped.emit(pick(event.position))
				down=false
	elif event is InputEventMouseMotion and down:
		if event.position.distance_to(origin)>8:dragging=true;press_pending=false;dismiss_help()
		if dragging:focus-=(event.position-last)/zoom;clamp_focus();queue_redraw()
		last=event.position
	elif event is InputEventScreenTouch:
		if event.pressed:
			touches[event.index]=event.position
			if touches.size()==1:origin=event.position;dragging=false;multi=false;begin_press(event.position)
			else:multi=true;press_pending=false;press_consumed=true;dismiss_help()
		else:
			press_pending=false
			if event.canceled:press_consumed=true;dismiss_help()
			if touches.has(event.index) and touches.size()==1 and not multi and not dragging and not press_consumed and not event.canceled:cell_tapped.emit(pick(event.position))
			touches.erase(event.index)
	elif event is InputEventScreenDrag and touches.has(event.index):
		if touches.size()>=2:
			press_pending=false;dismiss_help()
			var values=touches.values();var old_distance=values[0].distance_to(values[1]);var old_center=(values[0]+values[1])/2
			touches[event.index]=event.position;values=touches.values()
			var center=(values[0]+values[1])/2
			if old_distance>1:set_zoom(zoom*values[0].distance_to(values[1])/old_distance,old_center)
			focus-=(center-old_center)/zoom
		else:
			if event.position.distance_to(origin)>8:dragging=true;press_pending=false;dismiss_help()
			if dragging:focus-=(event.position-touches[event.index])/zoom
			touches[event.index]=event.position
		clamp_focus();queue_redraw()

func disorder_badge(p: Vector2,z: float):
	# A corner badge leaves the unit silhouette, number and strength visible.
	var badge=p+Vector2(-22,-17)*z
	draw_circle(badge,11*z,Color("172e32"))
	draw_arc(badge,10*z,0,TAU,24,Color("edc77b"),maxf(1,1.3*z),true)
	draw_string(COUNTER_FONT,badge+Vector2(-8,6)*z,"D",HORIZONTAL_ALIGNMENT_CENTER,16*z,maxi(10,int(17*z)),Color("ffe0a0"))

func draw_sauer():
	if not engine.pack.map.get("north_left",false):return
	var key=JSON.stringify([engine.pack.map.get("river_edges",[]),engine.pack.map.get("road_edges",[]),engine.pack.map.get("labels",[]),engine.width,engine.height,engine.pack.map.get("north_left",false)])
	if key!=river_key or river_curve==null:
		river_key=key;river_curve=Cartography.river_curve(self);river_center=Cartography.name_center(self,river_curve)
	if river_curve.get_point_count()<2:return
	var fs=clampi(int(23*zoom),20,38);var name="Sauer"
	var text_width=RIVER_FONT.get_string_size(name,HORIZONTAL_ALIGNMENT_LEFT,-1,fs).x
	for center in Cartography.name_centers(self,river_curve,text_width/zoom):
		var baseline=Cartography.label_curve(river_curve,center,text_width/zoom,zoom)
		var offset=(baseline.get_baked_length()-text_width/zoom)/2
		for k in range(name.length()):
			var letter=name.substr(k,1);var width=RIVER_FONT.get_string_size(letter,HORIZONTAL_ALIGNMENT_LEFT,-1,fs).x
			var pos=baseline.sample_baked(offset,true);var next=baseline.sample_baked(offset+8/zoom,true)
			var angle=(next-pos).angle();var normal=Vector2(-sin(angle),cos(angle))
			var location=(pos-focus)*zoom+size/2+normal*22
			draw_set_transform(location,angle)
			draw_string_outline(RIVER_FONT,Vector2.ZERO,letter,HORIZONTAL_ALIGNMENT_LEFT,-1,fs,4,Color("f5eedb"))
			draw_string(RIVER_FONT,Vector2.ZERO,letter,HORIZONTAL_ALIGNMENT_LEFT,-1,fs,Color("185982"))
			offset+=width/zoom
	draw_set_transform(Vector2.ZERO)

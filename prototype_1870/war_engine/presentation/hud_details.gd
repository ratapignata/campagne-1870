extends Control
## Cosmetic HUD only. Status cues read the already authorised, displayed labels.
## No engine, AI, save, input handling or per-frame polling belongs here.
const BOLD=preload("res://assets/fonts/DejaVuSans-Bold.ttf")
const ICONS=[preload("res://assets/graphics2d6/journal.svg"),preload("res://assets/graphics2d6/aide.svg"),preload("res://assets/graphics2d6/menu.svg")]
const CLOCK=preload("res://assets/graphics2d6/horloge.svg")
const GOOD=Color("80d6a0")
const CAUTION=Color("f3bf72")
const DANGER=Color("f08078")
const MUTED=Color("b7c8bf")
var game
var clock_panel: Panel
var clock_icon: TextureRect
var cues: Dictionary={}

func prepare():
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	for n in range(game.header_buttons.size()):
		var b=game.header_buttons[n]
		var original_size=b.size
		b.add_theme_font_size_override("font_size",17)
		b.add_theme_constant_override("icon_max_width",16)
		b.add_theme_constant_override("h_separation",4)
		b.icon=ICONS[n];b.size=original_size
	game.unit_ap.add_theme_font_override("font",BOLD)
	clock_panel=Panel.new();clock_panel.mouse_filter=Control.MOUSE_FILTER_IGNORE
	var style=StyleBoxFlat.new();style.bg_color=Color("0e242a")
	style.border_color=Color("72847a");style.set_border_width_all(1);style.set_corner_radius_all(5)
	clock_panel.add_theme_stylebox_override("panel",style)
	game.header.add_child(clock_panel);game.header.move_child(clock_panel,1)
	clock_icon=TextureRect.new();clock_icon.texture=CLOCK;clock_icon.mouse_filter=Control.MOUSE_FILTER_IGNORE
	clock_icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	clock_panel.add_child(clock_icon);clock_icon.position=Vector2(10,10);clock_icon.size=Vector2(16,16)

func morale_color(text: String) -> Color:
	for item in [["stable",GOOD],["shaken",CAUTION],["routed",DANGER]]:
		if text.begins_with(game.t("morale_"+item[0])):return item[1]
	return Color.TRANSPARENT

func link_color(field: Label,command: bool) -> Color:
	if field.text.is_empty():return Color.TRANSPARENT
	var key="command_status" if command else "supply_status"
	if field.text==game.t(key)%game.t("link_ok"):return GOOD
	if field.text==game.t(key)%game.t("command_cut" if command else "link_cut"):
		return DANGER if game.encircled_label.text==game.t("link_double_short") else CAUTION
	return Color.TRANSPARENT

func update_details():
	# Keep the original row spacing, card height and every control rectangle.
	size=game.footer.size
	clock_panel.position=Vector2(game.header_buttons[0].position.x-314,43);clock_panel.size=Vector2(300,36)
	game.score_label.position=clock_panel.position+Vector2(32,3);game.score_label.size=Vector2(260,30)
	game.score_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	var w=game.unit_card.size.x
	game.unit_state.size.x=w-(197 if game.formation_label.visible else 46)
	for field in [game.ammo_label,game.unit_reaction]:field.size.x=w-(236 if not game.support_label.text.is_empty() else 46)
	for field in [game.unit_state,game.ammo_label,game.unit_reaction]:field.position.x=44
	var ap_size=24
	while ap_size>20 and BOLD.get_string_size(game.unit_ap.text,HORIZONTAL_ALIGNMENT_LEFT,-1,ap_size).x>game.unit_ap.size.x:ap_size-=1
	game.unit_ap.add_theme_font_size_override("font_size",ap_size)
	# Use the actual serif font after the responsive card width is known.
	var title_size=23;var title_font=game.unit_label.get_theme_font("font")
	while title_size>14 and title_font.get_string_size(game.unit_label.text,HORIZONTAL_ALIGNMENT_LEFT,-1,title_size).x>game.unit_label.size.x:title_size-=1
	game.unit_label.add_theme_font_size_override("font_size",title_size)
	cues={"morale":morale_color(game.unit_state.text),"command":link_color(game.support_label,true),"supply":link_color(game.supply_label,false)}
	queue_redraw()

func mark(field: Label,color: Color,kind: String,right_column=false):
	if field.text.is_empty() or color.a==0:return
	var p=Vector2(30,field.position.y+field.size.y/2)
	if right_column:
		var font=field.get_theme_font("font");var fs=field.get_theme_font_size("font_size")
		var text_width=font.get_string_size(field.text,HORIZONTAL_ALIGNMENT_LEFT,-1,fs).x
		p.x=field.position.x+field.size.x-text_width-16
		if p.x<field.position.x+8:return # Never collide with long or translated text.
	var dark=Color("10272e")
	draw_circle(p,10,dark)
	if kind=="morale":
		var points=PackedVector2Array([p+Vector2(-5,-6),p+Vector2(5,-6),p+Vector2(5,0),p+Vector2(0,6),p+Vector2(-5,0),p+Vector2(-5,-6)])
		draw_polyline(points,color,1.5,true)
		draw_line(p+Vector2(-2,0),p+Vector2(0,2),color,1.5,true);draw_line(p+Vector2(0,2),p+Vector2(3,-2),color,1.5,true)
	elif kind=="ammo":
		for dx in [-3,3]:
			draw_rect(Rect2(p+Vector2(dx-1.5,-4),Vector2(3,9)),color)
			draw_line(p+Vector2(dx,-6),p+Vector2(dx,-4),color,2,true)
	elif kind=="command":
		draw_line(p+Vector2(-4,-6),p+Vector2(-4,6),color,1.5,true)
		draw_polyline(PackedVector2Array([p+Vector2(-4,-5),p+Vector2(5,-5),p+Vector2(3,-1),p+Vector2(-4,-1)]),color,1.5,true)
	elif kind=="supply":
		draw_rect(Rect2(p-Vector2(5,4),Vector2(10,8)),color,false,1.5)
		draw_line(p+Vector2(0,-4),p+Vector2(0,4),color,1,true)
	else:
		draw_arc(p,5,-PI*.9,PI*.6,16,color,1.5,true)
		draw_polyline(PackedVector2Array([p+Vector2(-6,-1),p+Vector2(-5,-5),p+Vector2(-1,-4)]),color,1.5,true)

func _draw():
	if cues.is_empty():return
	draw_line(Vector2(22,35),Vector2(game.unit_card.position.x+game.unit_card.size.x-12,35),Color("72847a55"),1,true)
	mark(game.unit_state,cues.morale,"morale")
	if not game.ammo_label.text.is_empty():
		var low=game.ammo_label.text==game.t("ammo_status")%game.t("ammo_2")
		mark(game.ammo_label,CAUTION if low else MUTED,"ammo")
	mark(game.unit_reaction,MUTED,"reaction")
	mark(game.support_label,cues.command,"command",true)
	mark(game.supply_label,cues.supply,"supply",true)

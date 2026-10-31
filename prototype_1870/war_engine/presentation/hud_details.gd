extends Control
## Cosmetic HUD only. Status cues read the already authorised, displayed labels.
## Read-only help hit areas; no engine, AI, save or per-frame polling here.
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
var help_targets: Dictionary={}

func prepare():
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	for n in range(game.header_buttons.size()):
		var b=game.header_buttons[n]
		var original_size=b.size
		b.add_theme_font_size_override("font_size",22)
		b.add_theme_constant_override("icon_max_width",18)
		b.add_theme_constant_override("h_separation",6)
		b.icon=ICONS[n];b.size=original_size
	game.unit_ap.add_theme_font_override("font",BOLD)
	clock_panel=Panel.new();clock_panel.mouse_filter=Control.MOUSE_FILTER_IGNORE
	var style=StyleBoxFlat.new();style.bg_color=Color("0e242a")
	style.border_color=Color("72847a");style.set_border_width_all(1);style.set_corner_radius_all(5)
	clock_panel.add_theme_stylebox_override("panel",style)
	game.header.add_child(clock_panel);game.header.move_child(clock_panel,1)
	clock_icon=TextureRect.new();clock_icon.texture=CLOCK;clock_icon.mouse_filter=Control.MOUSE_FILTER_IGNORE
	clock_icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	clock_panel.add_child(clock_icon);clock_icon.position=Vector2(8,9);clock_icon.size=Vector2(18,18)
	for topic in ["morale","ammo","reaction","command","supply"]:
		var area=Control.new();area.name="Help_"+topic;area.mouse_filter=Control.MOUSE_FILTER_STOP
		area.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND;area.size=Vector2(44,28)
		area.gui_input.connect(help_input.bind(topic,area));add_child(area);help_targets[topic]=area

func help_input(event: InputEvent,topic: String,area: Control):
	var pressed=event is InputEventScreenTouch and event.pressed
	pressed=pressed or (event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed)
	if not pressed or not area.visible:return
	show_status_help(topic);area.accept_event()

func help_text(topic: String) -> Array:
	# These are the same public strings shown on the card, never hidden unit fields.
	if topic=="morale" and cues.get("morale",Color.TRANSPARENT).a>0:
		return ["Moral",game.unit_state.text+"\n\nLe moral décrit la cohésion de l’unité. En ordre : cohésion préservée. Désorganisée : efficacité réduite. En déroute : capacités offensives limitées et retraite. La couleur complète toujours le texte."]
	if topic=="ammo" and not game.ammo_label.text.is_empty():
		return ["Munitions",game.ammo_label.text+"\n\nCe niveau représente des réserves abstraites, pas un nombre de cartouches. Des munitions faibles réduisent l’efficacité des tirs. Le ravitaillement décrit une liaison, pas le stock disponible."]
	if topic=="reaction" and reaction_known():
		if game.unit_reaction.text==game.t("cavalry_contact"):
			return ["Combat au contact",game.unit_reaction.text+"\n\nCette indication rappelle le rôle de la cavalerie au contact. La charge conserve son coût et ses conditions habituelles."]
		return ["Riposte",game.unit_reaction.text+"\n\nCet état indique la disponibilité de la réaction défensive. Une riposte éventuelle est résolue automatiquement selon les règles existantes."]
	return []

func show_status_help(topic: String):
	if topic in ["command","supply"]:
		if cues.get(topic,Color.TRANSPARENT).a>0:game.show_link_info(topic=="command")
		return
	var content=help_text(topic)
	if content.is_empty():return
	var box=game.modal_base(760,380)
	game.label(box,content[0],30,20,700,38,27,game.GOLD,true)
	game.scroll_text(box,content[1],76,210)
	game.button(box,game.t("close"),30,310,700,48,game.close_modal,true)

func reaction_known() -> bool:
	for key in ["reaction_ready","reaction_spent","reaction_routed","reaction_limbered","cavalry_contact"]:
		if game.unit_reaction.text==game.t(key):return true
	return false

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
	clock_panel.size=Vector2(310,36)
	var anchor=game.header_buttons[0]
	clock_panel.position=Vector2(anchor.position.x-clock_panel.size.x-14,anchor.position.y+(anchor.size.y-clock_panel.size.y)/2)
	game.score_label.position=clock_panel.position+Vector2(30,3);game.score_label.size=Vector2(272,30)
	game.score_label.add_theme_font_size_override("font_size",24)
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
	var fields={"morale":game.unit_state,"ammo":game.ammo_label,"reaction":game.unit_reaction,"command":game.support_label,"supply":game.supply_label}
	for topic in help_targets:
		var right=topic in ["command","supply"];var p=mark_position(fields[topic],right)
		var available=not help_text(topic).is_empty() if not right else cues[topic].a>0
		help_targets[topic].visible=available and p.is_finite()
		if help_targets[topic].visible:
			help_targets[topic].position=Vector2(maxf(game.unit_card.position.x,p.x-20),p.y-14)
			help_targets[topic].tooltip_text=fields[topic].text+" — Toucher pour une explication"
	queue_redraw()

func mark_position(field: Label,right_column: bool) -> Vector2:
	var p=Vector2(30,field.position.y+field.size.y/2)
	if right_column:
		var font=field.get_theme_font("font");var fs=field.get_theme_font_size("font_size")
		var text_width=font.get_string_size(field.text,HORIZONTAL_ALIGNMENT_LEFT,-1,fs).x
		p.x=field.position.x+field.size.x-text_width-16
		if p.x<field.position.x+8:return Vector2.INF
	return p

func mark(field: Label,color: Color,kind: String,right_column=false):
	if field.text.is_empty() or color.a==0:return
	var p=mark_position(field,right_column)
	if not p.is_finite():return
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
	draw_line(Vector2(22,68),Vector2(game.unit_card.position.x+game.unit_card.size.x-12,68),Color("9bb7ac44"),1,true)
	mark(game.unit_state,cues.morale,"morale")
	if not game.ammo_label.text.is_empty():
		var low=game.ammo_label.text==game.t("ammo_status")%game.t("ammo_2")
		mark(game.ammo_label,CAUTION if low else MUTED,"ammo")
	mark(game.unit_reaction,MUTED,"reaction")
	mark(game.support_label,cues.command,"command",true)
	mark(game.supply_label,cues.supply,"supply",true)

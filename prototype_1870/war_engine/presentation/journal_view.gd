extends Control
const Model=preload("res://war_engine/presentation/journal_model.gd")
const JournalSkin=preload("res://war_engine/presentation/graphics2d_skin.gd")
const TouchScroll=preload("res://war_engine/presentation/touch_scroll.gd")
const ICONS={"all":preload("res://assets/graphics2d10/all.svg"),"combat":preload("res://assets/graphics2d10/combat.svg"),"surrender":preload("res://assets/graphics2d10/surrender.svg"),"objective":preload("res://assets/graphics2d10/objective.svg"),"reinforcement":preload("res://assets/graphics2d10/reinforcement.svg")}
const CATEGORY_COLORS={"all":Color("9bb7ac"),"combat":Color("e2a394"),"surrender":Color("d8e2e5"),"objective":Color("e8c56f"),"reinforcement":Color("8fcbd1")}
var game
var data: Dictionary
var buttons: Dictionary={}
var selected_filter="all"
var list: VBoxContainer
var scroll: ScrollContainer
var visible_rows: Array=[]
var count_label: Label
var shown_count=0
var generation=0
var loading=false

static func open(g):
	var box=g.modal_base(minf(1120,g.size.x-48),minf(650,g.size.y-32))
	var view=new();view.name="JournalView";view.game=g;view.data=Model.build(g)
	box.add_child(view);view.size=box.size;view.mouse_filter=Control.MOUSE_FILTER_IGNORE;view.build()

func build():
	var w=size.x;var h=size.y
	game.label(self,"Journal de bataille",30,14,w-360,42,30,game.PAPER,true)
	game.label(self,game.score_label.text,w-320,20,290,30,21,game.GOLD).horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
	var summary=RichTextLabel.new();summary.name="GoalsSummary";summary.fit_content=false;summary.scroll_active=false
	summary.text=data.summary;summary.bbcode_enabled=false;summary.mouse_filter=Control.MOUSE_FILTER_IGNORE
	summary.add_theme_font_override("normal_font",game.BODY);summary.add_theme_font_size_override("normal_font_size",16);summary.add_theme_color_override("default_color",Color("c5d4cb"))
	game.place(summary,self,30,59,w-60,24)
	var categories=["all","combat","surrender","objective","reinforcement"];var captions=["Tous","Combats","Redditions","Objectifs","Renforts"]
	var bw=(w-92)/5
	for k in range(categories.size()):
		var category=categories[k];var b=game.button(self,captions[k],30+k*(bw+8),91,bw,46,func():set_filter(category),category=="all")
		b.name="Filter_"+category;b.add_theme_font_size_override("font_size",19)
		b.add_theme_constant_override("icon_max_width",18);b.add_theme_constant_override("h_separation",8);b.icon=ICONS[category]
		buttons[category]=b
	scroll=TouchScroll.new();scroll.name="JournalScroll";game.place(scroll,self,30,149,w-60,h-254)
	scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	list=VBoxContainer.new();list.size_flags_horizontal=Control.SIZE_EXPAND_FILL;list.add_theme_constant_override("separation",8);scroll.add_child(list)
	scroll.get_v_scroll_bar().value_changed.connect(load_near_bottom)
	count_label=game.label(self,"",30,h-94,w-60,22,15,Color("b7c8bf"))
	game.button(self,game.t("close"),30,h-62,w-60,48,game.close_modal,true)
	set_filter("all")

func set_filter(category: String):
	if not buttons.has(category):return
	selected_filter=category;visible_rows=Model.filtered(data.rows,category)
	generation+=1;shown_count=0;loading=false
	for key in buttons:
		var b=buttons[key];var active=key==category
		for state in ["normal","hover","pressed","disabled"]:b.add_theme_stylebox_override(state,JournalSkin.button_style(active,state))
		b.add_theme_color_override("font_color",game.INK if active else game.PAPER)
		b.add_theme_color_override("font_hover_color",game.INK if active else Color.WHITE)
		b.add_theme_color_override("font_pressed_color",game.INK if active else game.PAPER)

		for color in ["icon_normal_color","icon_hover_color","icon_pressed_color","icon_focus_color"]:b.add_theme_color_override(color,game.INK if active else CATEGORY_COLORS[key])
		b.set_meta("active",active)
	for child in list.get_children():list.remove_child(child);child.queue_free()
	if visible_rows.is_empty():
		add_row({"category":category,"title":"Aucune entrée","body":"Aucune information enregistrée dans cette catégorie.","turn":-1})
	else:
		append_chunk(generation)
	scroll.scroll_vertical=0
	count_label.text="%d entrées · Regroupées par tour · Informations connues de votre camp"%visible_rows.size()
	if category=="reinforcement":count_label.text="Vos renforts · Les dates effectives non enregistrées ne sont pas reconstituées."

func append_chunk(expected: int):
	if expected!=generation:return
	var stop=mini(shown_count+40,visible_rows.size())
	for k in range(shown_count,stop):add_row(visible_rows[k])
	shown_count=stop;loading=false

func load_near_bottom(value: float):
	var bar=scroll.get_v_scroll_bar()
	if loading or shown_count>=visible_rows.size() or bar.max_value<=bar.page:return
	if value>=bar.max_value-bar.page-120:
		loading=true;append_chunk.call_deferred(generation)

func add_row(item: Dictionary):
	var panel=PanelContainer.new();panel.mouse_filter=Control.MOUSE_FILTER_IGNORE
	panel.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	var accent=CATEGORY_COLORS.get(item.category,CATEGORY_COLORS.all)
	var style=StyleBoxFlat.new();style.bg_color=Color("122c31");style.border_color=accent;style.border_width_left=3;style.border_width_bottom=1
	style.content_margin_left=12;style.content_margin_right=12;style.content_margin_top=10;style.content_margin_bottom=12
	panel.add_theme_stylebox_override("panel",style);list.add_child(panel)
	var row_box=HBoxContainer.new();row_box.mouse_filter=Control.MOUSE_FILTER_IGNORE;row_box.add_theme_constant_override("separation",14);panel.add_child(row_box)
	var icon=TextureRect.new();icon.texture=ICONS.get(item.category,ICONS.all);icon.custom_minimum_size=Vector2(38,38)
	icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;icon.size_flags_vertical=Control.SIZE_SHRINK_BEGIN
	icon.mouse_filter=Control.MOUSE_FILTER_IGNORE;icon.modulate=accent;row_box.add_child(icon)
	var column=VBoxContainer.new();column.mouse_filter=Control.MOUSE_FILTER_IGNORE;column.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	column.custom_minimum_size.x=size.x-156;column.add_theme_constant_override("separation",4);row_box.add_child(column)
	var head=HBoxContainer.new();head.mouse_filter=Control.MOUSE_FILTER_IGNORE;column.add_child(head)
	var title=Label.new();title.text=item.title;title.clip_text=true;title.size_flags_horizontal=Control.SIZE_EXPAND_FILL;title.mouse_filter=Control.MOUSE_FILTER_IGNORE
	title.add_theme_font_override("font",game.TITLE);title.add_theme_font_size_override("font_size",23);title.add_theme_color_override("font_color",game.GOLD if item.category=="objective" else game.PAPER);head.add_child(title)
	var time=Label.new();time.text=str(item.get("stamp",Model.stamp(game.engine,int(item.turn))));time.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
	time.mouse_filter=Control.MOUSE_FILTER_IGNORE;time.add_theme_font_override("font",game.BODY);time.add_theme_font_size_override("font_size",17);time.add_theme_color_override("font_color",game.GOLD);head.add_child(time)
	var body=RichTextLabel.new();body.name="EntryBody";body.text=item.body;body.bbcode_enabled=false;body.fit_content=true;body.scroll_active=false
	body.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;body.size_flags_horizontal=Control.SIZE_EXPAND_FILL;body.mouse_filter=Control.MOUSE_FILTER_IGNORE
	body.add_theme_font_override("normal_font",game.BODY);body.add_theme_font_size_override("normal_font_size",20);body.add_theme_color_override("default_color",game.PAPER);column.add_child(body)

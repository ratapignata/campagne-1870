extends Control
## Six supplied panels; presentation only, no engine or save access.
signal introduction_finished
signal menu_requested

const TITLES := [
    "Une Europe en transformation", "Deux puissances rivales", "La candidature Hohenzollern",
    "La dépêche d’Ems", "La déclaration de guerre", "La mobilisation"
]
const DESCRIPTIONS := [
    "En 1866, la Prusse bat l’Autriche à Sadowa et l’écarte de la direction des affaires allemandes. En 1867, la Confédération de l’Allemagne du Nord réunit autour de Berlin la Prusse et les États du Nord.\n\nLes États du Sud restent en dehors, mais des traités militaires les lient à la Prusse. L’unification reste inachevée ; ce nouvel équilibre inquiète la France.",
    "Après 1866, le Second Empire redoute une diminution de l’influence française en Europe. Napoléon III entend préserver l’équilibre des puissances et le prestige de son régime.\n\nBismarck cherche, lui, à rapprocher les États allemands du Sud de Berlin. Les crises diplomatiques et la presse nourrissent la rivalité. La guerre n’est pourtant pas inévitable : la question du trône d’Espagne déclenche l’escalade de juillet 1870.",
    "En juillet 1870, la candidature de Léopold de Hohenzollern au trône d’Espagne inquiète Paris. La France redoute de voir un parent du roi de Prusse installé de l’autre côté des Pyrénées.\n\nLe 12 juillet, la candidature est retirée. Paris exige néanmoins que Guillaume Ier garantisse qu’elle ne sera jamais renouvelée. Une issue diplomatique possible devient une question de prestige.",
    "Le 13 juillet 1870, à Ems, Guillaume Ier refuse à l’ambassadeur français Benedetti une garantie perpétuelle contre la candidature espagnole. Un compte rendu est télégraphié à Berlin.\n\nBismarck en abrège le texte et le publie sous une forme plus sèche. Diffusée le soir du 13, puis reprise par la presse le 14, cette version fait paraître l’échange humiliant et attise l’indignation dans les deux pays.",
    "À Paris, le gouvernement présente l’affaire comme une atteinte à l’honneur national. Le 15 juillet, le Corps législatif vote les crédits de guerre. Le 19 juillet 1870, la France déclare officiellement la guerre à la Prusse.\n\nL’espoir d’isoler Berlin échoue : les États allemands du Sud se rangent aux côtés de la Prusse. La crise diplomatique devient une guerre.",
    "La mobilisation révèle des préparations inégales. Les armées allemandes disposent de plans de rassemblement coordonnés et utilisent efficacement le chemin de fer. En France, les difficultés de transport, d’équipement et de regroupement retardent la concentration.\n\nAu début d’août, les forces se font face près de la frontière. Les premiers grands combats s’ouvrent en Alsace et en Lorraine : la campagne commence."
]
const ART_PATHS := [
    "res://intro_bd/assets/scene_1.png", "res://intro_bd/assets/scene_2.png",
    "res://intro_bd/assets/scene_3.png", "res://intro_bd/assets/scene_4.png",
    "res://intro_bd/assets/scene_5.png", "res://intro_bd/assets/scene_6.png"
]
const IntroSkin=preload("res://war_engine/presentation/graphics2d_skin.gd")
const TouchScroll=preload("res://war_engine/presentation/touch_scroll.gd")
const BODY=preload("res://assets/fonts/DejaVuSans.ttf")
const TITLE=preload("res://assets/fonts/DejaVuSerif-Bold.ttf")
const PAPER=Color("eee6cf")
const GOLD=Color("d4b06c")
var ART: Array=[]
var index=0
var auto_play=false
var completed=false
var backgrounded=false
var unfocused=false
var timer: Timer
var art: TextureRect
var outgoing: TextureRect
var heading: Label
var description: RichTextLabel
var counter: Label
var masthead: Label
var subtitle: Label
var playback_note: Label
var art_holder: Panel
var text_holder: Panel
var description_scroll: ScrollContainer
var auto_button: Button
var next_button: Button
var previous_button: Button
var menu_button: Button
var skip_button: Button
var anim: Tween
var scroll_anim: Tween
var page_generation=0
var host: Control

func _fit_host():
    if not is_instance_valid(host):return
    var box=get_parent() as Control
    if box!=null:box.position=Vector2.ZERO;box.size=host.size

func _ready():
    mouse_filter=Control.MOUSE_FILTER_STOP
    for path in ART_PATHS:ART.append(load(path))
    _build_ui();resized.connect(_layout);_layout();_show_scene(0)

func _panel() -> Panel:
    var p=Panel.new();p.mouse_filter=Control.MOUSE_FILTER_IGNORE
    var s=StyleBoxFlat.new();s.bg_color=Color("122c31");s.border_color=Color("536b65");s.set_border_width_all(1);s.set_corner_radius_all(6)
    p.add_theme_stylebox_override("panel",s);add_child(p);return p

func _label(parent: Control,text: String,font_size: int,color: Color,bold=false) -> Label:
    var l=Label.new();l.text=text;l.mouse_filter=Control.MOUSE_FILTER_IGNORE
    l.add_theme_font_override("font",TITLE if bold else BODY);l.add_theme_font_size_override("font_size",font_size);l.add_theme_color_override("font_color",color)
    parent.add_child(l);return l

func _button(text: String,callback: Callable,primary=false) -> Button:
    var b=Button.new();b.text=text;b.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
    b.add_theme_font_override("font",BODY)
    for state in ["normal","hover","pressed","disabled"]:b.add_theme_stylebox_override(state,IntroSkin.button_style(primary,state))
    b.add_theme_color_override("font_color",Color("192f31") if primary else PAPER)
    b.add_theme_color_override("font_hover_color",Color("192f31") if primary else Color.WHITE)
    b.add_theme_color_override("font_pressed_color",Color("192f31") if primary else PAPER)
    b.add_theme_color_override("font_disabled_color",Color("aabbb1"))
    b.pressed.connect(callback);add_child(b);return b

func _build_ui():
    var bg=ColorRect.new();bg.color=Color("0b2027");bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);bg.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(bg)
    masthead=_label(self,"CAMPAGNE 1870",30,GOLD,true)
    subtitle=_label(self,"Les origines de la guerre",21,PAPER)
    counter=_label(self,"",20,GOLD);counter.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
    art_holder=_panel();art_holder.clip_contents=true
    for k in range(2):
        var picture=TextureRect.new();picture.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;picture.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        picture.mouse_filter=Control.MOUSE_FILTER_IGNORE;art_holder.add_child(picture)
        picture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);picture.offset_left=10;picture.offset_top=10;picture.offset_right=-10;picture.offset_bottom=-10
        if k==0:outgoing=picture
        else:art=picture
    text_holder=_panel()
    heading=_label(text_holder,"",30,GOLD,true);heading.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
    description_scroll=TouchScroll.new();description_scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;text_holder.add_child(description_scroll)
    description=RichTextLabel.new();description.text="";description.bbcode_enabled=false;description.fit_content=true;description.scroll_active=false
    description.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;description.size_flags_horizontal=Control.SIZE_EXPAND_FILL;description.mouse_filter=Control.MOUSE_FILTER_IGNORE
    description.add_theme_font_override("normal_font",BODY);description.add_theme_font_size_override("normal_font_size",25);description.add_theme_color_override("default_color",PAPER)
    description_scroll.add_child(description)
    description.resized.connect(_reading_hint)
    description_scroll.get_v_scroll_bar().changed.connect(_reading_hint)
    description_scroll.get_v_scroll_bar().value_changed.connect(_reading_hint)
    description_scroll.gui_input.connect(_reading_input)
    playback_note=_label(text_holder,"",16,Color("b7c8bf"));playback_note.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
    menu_button=_button("Retour au menu",_return_menu)
    skip_button=_button("Passer l’introduction",_finish)
    previous_button=_button("Précédent",func():_show_scene(index-1))
    auto_button=_button("Lecture auto : non",_toggle_auto)
    next_button=_button("Suivant",_next,true)
    timer=Timer.new();timer.wait_time=30.0;timer.one_shot=true;timer.timeout.connect(_next);add_child(timer)

func _rect(node: Control,x: float,y: float,w: float,h: float):
    node.position=Vector2(x,y);node.size=Vector2(w,h)

func _layout():
    if art_holder==null:return
    var w=size.x;var h=size.y;var compact=h<650
    _rect(masthead,24,15,w-260,38);masthead.add_theme_font_size_override("font_size",28 if compact else 30)
    _rect(subtitle,24,55,w-260,30);_rect(counter,w-226,30,202,30)
    var body_h=maxf(220,h-216);var picture_w=(w-66)*0.50
    _rect(art_holder,24,98,picture_w,body_h);_rect(text_holder,42+picture_w,98,w-66-picture_w,body_h)
    var text_w=text_holder.size.x-40
    var heading_size=28 if compact else 32
    heading.add_theme_font_size_override("font_size",heading_size)
    var heading_h=clampf(TITLE.get_multiline_string_size(heading.text,HORIZONTAL_ALIGNMENT_LEFT,text_w,heading_size).y,40,96)
    _rect(heading,20,18,text_w,heading_h)
    var text_top=heading_h+30
    _rect(description_scroll,20,text_top,text_w,body_h-text_top-68)
    description.add_theme_font_size_override("normal_font_size",22 if compact else 25)
    _rect(playback_note,20,body_h-50,text_w,38)
    var widths=[0.18,0.25,0.15,0.24,0.18];var buttons=[menu_button,skip_button,previous_button,auto_button,next_button]
    var left=24.0;var available=w-88
    for k in range(buttons.size()):
        var bw=available*widths[k];_rect(buttons[k],left,h-82,bw,58)
        buttons[k].add_theme_font_size_override("font_size",21 if w>=1200 else 18);left+=bw+10

func _show_scene(n: int):
    if completed:return
    page_generation+=1;_stop_scroll()
    index=clampi(n,0,TITLES.size()-1)
    if anim and anim.is_valid():anim.kill()
    outgoing.texture=art.texture;outgoing.visible=outgoing.texture!=null
    art.texture=ART[index];art.modulate.a=0.0
    anim=create_tween();anim.tween_property(art,"modulate:a",1.0,0.65)
    anim.finished.connect(func():outgoing.hide(),CONNECT_ONE_SHOT)
    if backgrounded or unfocused:anim.pause()
    heading.text="%d. %s"%[index+1,TITLES[index]];description.text=DESCRIPTIONS[index];description_scroll.scroll_vertical=0
    counter.text="Scène %d / %d"%[index+1,TITLES.size()]
    previous_button.disabled=index==0;next_button.disabled=false;next_button.text="Continuer" if index==TITLES.size()-1 else "Suivant"
    playback_note.text="Lecture automatique · 30 s par scène" if auto_play else "Lecture manuelle · Passez à tout moment"
    _layout();_reading_hint.call_deferred()
    timer.stop()
    if auto_play:
        timer.start();_auto_scroll.call_deferred(page_generation)

func _stop_scroll():
    if scroll_anim and scroll_anim.is_valid():scroll_anim.kill()

func _auto_scroll(expected: int):
    if completed or not auto_play or expected!=page_generation:return
    _stop_scroll()
    var bar=description_scroll.get_v_scroll_bar();var bottom=maxf(0,bar.max_value-bar.page)
    if bottom<=description_scroll.scroll_vertical+1:return
    scroll_anim=create_tween();scroll_anim.tween_interval(8.0)
    scroll_anim.tween_property(description_scroll,"scroll_vertical",int(bottom),14.0)
    if backgrounded or unfocused:scroll_anim.pause()

func _reading_input(event: InputEvent):
    if auto_play and event is InputEventScreenDrag:_toggle_auto()

func _reading_hint(_value: float=0):
    if playback_note==null or description_scroll==null:return
    var bar=description_scroll.get_v_scroll_bar()
    var more=bar.max_value-bar.page>description_scroll.scroll_vertical+2
    var text="Lecture auto · 30 s" if auto_play else "Lecture manuelle"
    playback_note.text=text+(" · Glissez pour lire la suite" if more else " · Passez à tout moment")

func _next():
    if completed:return
    if index==TITLES.size()-1:_finish()
    else:_show_scene(index+1)

func _toggle_auto():
    if completed:return
    auto_play=not auto_play;auto_button.text="Lecture auto : oui" if auto_play else "Lecture auto : non"
    playback_note.text="Lecture automatique · 30 s par scène" if auto_play else "Lecture manuelle · Passez à tout moment"
    _reading_hint.call_deferred()
    if auto_play:
        timer.start();_auto_scroll.call_deferred(page_generation)
    else:timer.stop();_stop_scroll()

func _stop():
    timer.stop()
    _stop_scroll()
    if anim and anim.is_valid():anim.kill()

func _finish():
    if completed:return
    completed=true;_stop();introduction_finished.emit()

func _return_menu():
    if completed:return
    completed=true;_stop();menu_requested.emit()

func _notification(what):
    if what==NOTIFICATION_APPLICATION_PAUSED:backgrounded=true
    elif what==NOTIFICATION_APPLICATION_RESUMED:backgrounded=false
    elif what==NOTIFICATION_APPLICATION_FOCUS_OUT:unfocused=true
    elif what==NOTIFICATION_APPLICATION_FOCUS_IN:unfocused=false
    else:return
    if timer==null:return
    timer.paused=backgrounded or unfocused
    for tween in [anim,scroll_anim]:
        if tween and tween.is_valid():
            if timer.paused:tween.pause()
            else:tween.play()

func _exit_tree():
    if timer!=null:_stop()
    if is_instance_valid(art):art.texture=null
    if is_instance_valid(outgoing):outgoing.texture=null
    ART.clear()

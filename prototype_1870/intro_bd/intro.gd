extends Control
## Six supplied panels; presentation only, no engine or save access.
signal introduction_finished
signal menu_requested

const TITLES := [
    "Une Europe en transformation", "Deux puissances rivales", "La candidature Hohenzollern",
    "La dépêche d’Ems", "La déclaration de guerre", "La mobilisation"
]
const DESCRIPTIONS := [
    "Après sa victoire contre l’Autriche en 1866, la Prusse renforce son influence sur les États allemands. La perspective d’une unification modifie l’équilibre européen.",
    "Napoléon III s’inquiète de la montée en puissance de la Prusse. Entre Paris et Berlin, les rivalités diplomatiques s’accentuent.",
    "En 1870, la candidature d’un prince de la maison de Hohenzollern au trône d’Espagne provoque une crise. La France redoute un encerclement diplomatique.",
    "Le 13 juillet 1870, Bismarck publie une version condensée de l’échange d’Ems entre le roi de Prusse et l’ambassadeur français. La tension s’enflamme.",
    "Le 19 juillet 1870, la France déclare la guerre à la Prusse. La crise diplomatique débouche sur un conflit qui mobilise bientôt plusieurs États allemands.",
    "Les armées se rassemblent et se mettent en marche. Début août, les premiers grands combats éclatent en Alsace et en Lorraine."
]
const ART_PATHS := [
    "res://intro_bd/assets/scene_1.jpg", "res://intro_bd/assets/scene_2.jpg",
    "res://intro_bd/assets/scene_3.jpg", "res://intro_bd/assets/scene_4.jpg",
    "res://intro_bd/assets/scene_5.jpg", "res://intro_bd/assets/scene_6.jpg"
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
    playback_note=_label(text_holder,"",16,Color("b7c8bf"));playback_note.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
    menu_button=_button("Retour au menu",_return_menu)
    skip_button=_button("Passer l’introduction",_finish)
    previous_button=_button("Précédent",func():_show_scene(index-1))
    auto_button=_button("Lecture auto : non",_toggle_auto)
    next_button=_button("Suivant",_next,true)
    timer=Timer.new();timer.wait_time=9.0;timer.one_shot=true;timer.timeout.connect(_next);add_child(timer)

func _rect(node: Control,x: float,y: float,w: float,h: float):
    node.position=Vector2(x,y);node.size=Vector2(w,h)

func _layout():
    if art_holder==null:return
    var w=size.x;var h=size.y;var compact=h<650
    _rect(masthead,24,15,w-260,38);masthead.add_theme_font_size_override("font_size",28 if compact else 30)
    _rect(subtitle,24,55,w-260,30);_rect(counter,w-226,30,202,30)
    var body_h=maxf(220,h-216);var picture_w=(w-66)*0.58
    _rect(art_holder,24,98,picture_w,body_h);_rect(text_holder,42+picture_w,98,w-66-picture_w,body_h)
    var text_w=text_holder.size.x-40
    _rect(heading,20,18,text_w,100);heading.add_theme_font_size_override("font_size",28 if compact else 32)
    _rect(description_scroll,20,126,text_w,body_h-196)
    description.add_theme_font_size_override("normal_font_size",23 if compact else 25)
    _rect(playback_note,20,body_h-54,text_w,42)
    var widths=[0.18,0.25,0.15,0.24,0.18];var buttons=[menu_button,skip_button,previous_button,auto_button,next_button]
    var left=24.0;var available=w-88
    for k in range(buttons.size()):
        var bw=available*widths[k];_rect(buttons[k],left,h-82,bw,58)
        buttons[k].add_theme_font_size_override("font_size",21 if w>=1200 else 18);left+=bw+10

func _show_scene(n: int):
    if completed:return
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
    playback_note.text="Lecture automatique · 9 s par scène" if auto_play else "Lecture manuelle · Passez à tout moment"
    timer.stop()
    if auto_play:timer.start()

func _next():
    if completed:return
    if index==TITLES.size()-1:_finish()
    else:_show_scene(index+1)

func _toggle_auto():
    if completed:return
    auto_play=not auto_play;auto_button.text="Lecture auto : oui" if auto_play else "Lecture auto : non"
    playback_note.text="Lecture automatique · 9 s par scène" if auto_play else "Lecture manuelle · Passez à tout moment"
    if auto_play:timer.start()
    else:timer.stop()

func _stop():
    timer.stop()
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
    if anim and anim.is_valid():
        if timer.paused:anim.pause()
        else:anim.play()

func _exit_tree():
    if timer!=null:_stop()
    if is_instance_valid(art):art.texture=null
    if is_instance_valid(outgoing):outgoing.texture=null
    ART.clear()

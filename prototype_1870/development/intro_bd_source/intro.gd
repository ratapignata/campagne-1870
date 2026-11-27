extends Control
## Prototype indépendant : n'altère aucun système du jeu principal.
signal introduction_finished

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
const ART := [
    preload("res://assets/scene_1.jpg"), preload("res://assets/scene_2.jpg"),
    preload("res://assets/scene_3.jpg"), preload("res://assets/scene_4.jpg"),
    preload("res://assets/scene_5.jpg"), preload("res://assets/scene_6.jpg")
]
var index := 0
var auto_play := false
var timer: Timer
var art: TextureRect
var heading: Label
var description: Label
var counter: Label
var auto_button: Button
var next_button: Button
var previous_button: Button
var anim: Tween

func _ready() -> void:
    _build_ui()
    _show_scene(0)

func _build_ui() -> void:
    var bg := ColorRect.new()
    bg.color = Color("10242b")
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)
    var layout := VBoxContainer.new()
    layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    layout.add_theme_constant_override("separation", 12)
    add_child(layout)
    var title := Label.new()
    title.text = "CAMPAGNE 1870  •  LES ORIGINES DE LA GUERRE"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 27)
    title.add_theme_color_override("font_color", Color("e7cf9c"))
    layout.add_child(title)
    var content := HBoxContainer.new()
    content.size_flags_vertical = Control.SIZE_EXPAND_FILL
    content.add_theme_constant_override("separation", 18)
    layout.add_child(content)
    var art_holder := PanelContainer.new()
    art_holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    art_holder.size_flags_stretch_ratio = 1.4
    content.add_child(art_holder)
    art = TextureRect.new()
    art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    art_holder.add_child(art)
    var info := VBoxContainer.new()
    info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    info.size_flags_stretch_ratio = 1.0
    content.add_child(info)
    heading = Label.new()
    heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    heading.add_theme_font_size_override("font_size", 32)
    heading.add_theme_color_override("font_color", Color("e8d4ab"))
    info.add_child(heading)
    description = Label.new()
    description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    description.size_flags_vertical = Control.SIZE_EXPAND_FILL
    description.add_theme_font_size_override("font_size", 24)
    description.add_theme_color_override("font_color", Color("f1e9d9"))
    info.add_child(description)
    counter = Label.new()
    counter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    counter.add_theme_font_size_override("font_size", 18)
    info.add_child(counter)
    var controls := HBoxContainer.new()
    controls.alignment = BoxContainer.ALIGNMENT_CENTER
    controls.add_theme_constant_override("separation", 18)
    layout.add_child(controls)
    var skip := Button.new()
    skip.text = "Passer l’introduction"
    skip.pressed.connect(_finish)
    controls.add_child(skip)
    previous_button = Button.new()
    previous_button.text = "Précédent"
    previous_button.pressed.connect(func(): _show_scene(index - 1))
    controls.add_child(previous_button)
    auto_button = Button.new()
    auto_button.text = "Lecture auto : non"
    auto_button.pressed.connect(_toggle_auto)
    controls.add_child(auto_button)
    next_button = Button.new()
    next_button.text = "Suivant"
    next_button.pressed.connect(_next)
    controls.add_child(next_button)
    timer = Timer.new()
    timer.wait_time = 9.0
    timer.one_shot = true
    timer.timeout.connect(_next)
    add_child(timer)

func _show_scene(n: int) -> void:
    index = clampi(n, 0, TITLES.size() - 1)
    if anim and anim.is_running():
        anim.kill()
    art.texture = ART[index]
    art.modulate.a = 0.0
    anim = create_tween()
    anim.tween_property(art, "modulate:a", 1.0, 0.65)
    heading.text = "%d. %s" % [index + 1, TITLES[index]]
    description.text = DESCRIPTIONS[index]
    counter.text = "Scène %d / %d" % [index + 1, TITLES.size()]
    previous_button.disabled = index == 0
    next_button.text = "Terminer" if index == TITLES.size() - 1 else "Suivant"
    timer.stop()
    if auto_play:
        timer.start()

func _next() -> void:
    if index == TITLES.size() - 1:
        _finish()
    else:
        _show_scene(index + 1)

func _toggle_auto() -> void:
    auto_play = not auto_play
    auto_button.text = "Lecture auto : oui" if auto_play else "Lecture auto : non"
    if auto_play:
        timer.start()
    else:
        timer.stop()

func _finish() -> void:
    timer.stop()
    introduction_finished.emit()
    # Démonstration autonome : affiche la fin sans accéder au menu du vrai jeu.
    heading.text = "Introduction terminée"
    description.text = "Dans le jeu principal, ce signal permettra d’ouvrir le menu ou la bataille."
    next_button.disabled = true

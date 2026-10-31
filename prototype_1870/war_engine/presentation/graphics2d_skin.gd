extends Control
# Decorative only. Never consumes input or changes its parent's layout.
const BAND=preload("res://assets/graphics2d2/ui/band.svg")
const CARD=preload("res://assets/graphics2d2/ui/card.svg")
const BUTTONS={
 "gold_normal":preload("res://assets/graphics2d2/ui/gold_normal.svg"),
 "gold_hover":preload("res://assets/graphics2d2/ui/gold_hover.svg"),
 "gold_pressed":preload("res://assets/graphics2d2/ui/gold_pressed.svg"),
 "gold_disabled":preload("res://assets/graphics2d2/ui/gold_disabled.svg"),
 "dark_normal":preload("res://assets/graphics2d2/ui/dark_normal.svg"),
 "dark_hover":preload("res://assets/graphics2d2/ui/dark_hover.svg"),
 "dark_pressed":preload("res://assets/graphics2d2/ui/dark_pressed.svg"),
 "dark_disabled":preload("res://assets/graphics2d2/ui/dark_disabled.svg")}
var card=false
var skin: StyleBoxTexture
static var disabled_skin: StyleBoxFlat
static func style(texture: Texture2D) -> StyleBoxTexture:
 var s=StyleBoxTexture.new();s.texture=texture
 s.texture_margin_left=8;s.texture_margin_right=8;s.texture_margin_top=8;s.texture_margin_bottom=8
 s.content_margin_left=12;s.content_margin_right=12;s.content_margin_top=0;s.content_margin_bottom=0
 return s
static func button_style(primary: bool,state: String) -> StyleBox:
 if state=="disabled":
  if disabled_skin==null:
   disabled_skin=StyleBoxFlat.new();disabled_skin.bg_color=Color("10272e")
   disabled_skin.border_color=Color("647c7a");disabled_skin.set_border_width_all(1);disabled_skin.set_corner_radius_all(5)
   disabled_skin.content_margin_left=12;disabled_skin.content_margin_right=12
   disabled_skin.content_margin_top=0;disabled_skin.content_margin_bottom=0
  return disabled_skin
 return style(BUTTONS[("gold_" if primary else "dark_")+state])
func _ready():
 mouse_filter=Control.MOUSE_FILTER_IGNORE;texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
 skin=style(CARD if card else BAND);resized.connect(queue_redraw)
func _draw():
 if skin!=null:draw_style_box(skin,Rect2(Vector2.ZERO,size))

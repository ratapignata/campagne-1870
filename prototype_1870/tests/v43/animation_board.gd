extends "res://war_engine/presentation/map_view.gd"
var terrain_colors=[]
var samples=[]
var phases=[0.04,0.20,0.35,0.58,0.85]
var phase=0.35
var cannon_mode=true
func _draw():
 draw_rect(Rect2(0,0,1600,1200),Color("f6eedb"))
 samples=[]
 for row in range(terrain_colors.size()):
  for column in range(4):
   zoom=[0.42,0.72,1.0,2.3][column]
   var entry=terrain_colors[row];var area=Rect2(column*395+5,row*76+28,385,70)
   draw_rect(area,entry.color)
   draw_string(ThemeDB.fallback_font,area.position+Vector2(5,16),entry.name+" / z="+str(zoom),HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("282828"))
   var origin=area.position+Vector2(12,46);var dest=area.position+Vector2(360,46)
   shot_effect(origin,dest,phase,cannon_mode)
   var muzzle=origin+Vector2(19*zoom,0);var center=muzzle.lerp(dest,(phase-0.12)/0.51)
   if phase>=0.12 and phase<0.63:samples.append({"center":center,"radius":4.5*zoom,"terrain":entry.name,"zoom":zoom})

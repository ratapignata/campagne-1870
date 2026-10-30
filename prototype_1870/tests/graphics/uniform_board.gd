extends "res://war_engine/presentation/map_view.gd"
var sample_index_offset=0
func _draw():
 draw_rect(Rect2(Vector2.ZERO,size),Color("c5cab2"))
 for row in range(3):
  var terrain=["plain","cultivated","forest"][row]
  for col in range(3):
   var p=Vector2(160+col*200,90+row*145)
   draw_colored_polygon(hexagon(p,R),Graphics2D.base_color(Color(engine.pack.terrains[terrain].color)))
   Graphics2D.ground(self,terrain,col*29+sample_index_offset,p,1.0)
   Graphics2D.decor(self,terrain,col*29+sample_index_offset,p,1.0,col==2)
  var at=Vector2(800,90+row*145)
  draw_colored_polygon(hexagon(at,R),Graphics2D.base_color(Color(engine.pack.terrains[terrain].color)))
  Graphics2D.ground(self,terrain,row,at,1.0);Graphics2D.decor(self,terrain,row,at,1.0,false)
  Graphics2D.movement_marker(self,at,1.0)

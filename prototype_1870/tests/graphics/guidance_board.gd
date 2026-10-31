extends Control
const Art=preload("res://war_engine/presentation/graphics2d_art.gd")
const LOCALITY_FONT=preload("res://assets/fonts/DejaVuSerif-Bold.ttf")
var zoom=1.0
var selected=true
var preview=true
func _draw():
	draw_rect(Rect2(Vector2.ZERO,size),Color("d8d7b1"))
	for n in range(4):
		var z=[0.42,0.72,1.05,2.3][n];var p=Vector2(110+n*240,125)
		if selected:Art.selection_brackets(self,p,z)
		draw_rect(Rect2(p-Vector2(26,27)*z,Vector2(52,54)*z),Color("568db4"))
		draw_rect(Rect2(p-Vector2(29,30)*z,Vector2(58,60)*z),Color("ff4545"),false,maxf(1.75,2.25*z))
		Art.movement_marker(self,Vector2(p.x,280),z)
		if preview:Art.route_preview(self,PackedVector2Array([Vector2(p.x-45,380),Vector2(p.x,345),Vector2(p.x+45,380)]),z)
		zoom=z;Art.locality_name(self,Vector2(p.x-45,490),"Wœrth",maxi(11,int(15*z)))

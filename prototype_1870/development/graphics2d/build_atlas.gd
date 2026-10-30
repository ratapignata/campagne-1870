extends SceneTree
func _initialize():
 var data=JSON.parse_string(FileAccess.get_file_as_string("res://development/graphics2d/atlas_manifest.json"))
 var atlas=Image.create(int(data.size[0]),int(data.size[1]),false,Image.FORMAT_RGBA8);atlas.fill(Color.TRANSPARENT)
 for n in range(data.names.size()):
  var name=str(data.names[n]);var svg=FileAccess.get_file_as_string("res://development/graphics2d/svg/"+name+".svg");var image=Image.new()
  if image.load_svg_from_string(svg)!=OK:printerr("SVG failed: ",name);quit(1);return
  atlas.blit_rect(image,Rect2i(Vector2i.ZERO,image.get_size()),Vector2i((n%6)*220+8,(n/6)*193+8))
 var error=atlas.save_png("res://assets/graphics2d/terrain_atlas.png");print("ATLAS ",atlas.get_size()," sprites ",data.names.size()," error ",error);quit(0 if error==OK else 1)

extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const View=preload("res://war_engine/presentation/map_view.gd")
const Art=preload("res://war_engine/presentation/graphics2d_art.gd")
const Store=preload("res://war_engine/platform/save_store.gd")
var checks=0
var failures=0
var taps=[]
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func run():
 var data=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json"));var e=Rules.new(data);e.new_game(0,"hard");e.state.seed=18704315;e.refresh_intel()
 var view=View.new();view.engine=e;view.texts=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/fr.json"));root.add_child(view);view.size=Vector2(1280,448);var state=JSON.stringify(e.state)
 check(e.width==30 and e.height==20 and e.state.units.size()==95,"actual V43.15 map and roster")
 check(Art.regions.size()==12 and Art.FIGURES.get_size()==Vector2(1536,1024),"one reusable painted illustration atlas")
 for name in Art.FIGURE_RECTS:
  var texture=Art.regions[name];check(texture.atlas==Art.FIGURES and texture.filter_clip and Rect2(0,0,1536,1024).encloses(texture.region),"figure region bounded and shared "+name)
 for terrain in data.terrains:check(Art.base_color(Color(data.terrains[terrain].color))==Color(data.terrains[terrain].color),"exact V43.15 terrain palette "+terrain)
 var picture=Art.FIGURES.get_image();check(picture.get_pixel(0,0).a==0 and not picture.is_invisible(),"true transparency around painted illustrations")
 for z in [0.42,0.72,1.05,2.3]:
  view.zoom=z;view.focus=view.world(e.index(Vector2i(14,9)))
  for i in range(600):check(view.pick(view.screen(i))==i,"hex picking unchanged at zoom %s cell %s"%[z,i])
 view.zoom=1.0;view.focus=view.world(e.index(Vector2i(13,10)));var focus=view.focus
 view.cell_tapped.connect(func(i):taps.append(i))
 var p=view.screen(e.index(Vector2i(13,10)));var press=InputEventScreenTouch.new();press.index=0;press.position=p;press.pressed=true;view._gui_input(press)
 var release=InputEventScreenTouch.new();release.index=0;release.position=p;release.pressed=false;view._gui_input(release)
 check(taps==[e.index(Vector2i(13,10))],"single finger tap selects exact original hex")
 press.pressed=true;view._gui_input(press);var drag=InputEventScreenDrag.new();drag.index=0;drag.position=p+Vector2(35,0);view._gui_input(drag);release.position=drag.position;view._gui_input(release)
 check(view.focus!=focus and taps.size()==1,"finger drag pans without firing a tap")
 var a=InputEventScreenTouch.new();a.index=0;a.position=Vector2(400,200);a.pressed=true;view._gui_input(a)
 var b=InputEventScreenTouch.new();b.index=1;b.position=Vector2(600,200);b.pressed=true;view._gui_input(b)
 var zoom_before=view.zoom;drag.index=1;drag.position=Vector2(650,200);view._gui_input(drag)
 check(view.zoom>zoom_before,"two finger pinch changes zoom")
 a.pressed=false;b.pressed=false;view._gui_input(a);view._gui_input(b);check(taps.size()==1,"pinch never selects a unit")
 var anchor=Vector2(500,180);var world_before=(anchor-view.size/2)/view.zoom+view.focus;view.set_zoom(1.4,anchor)
 check(((anchor-view.size/2)/view.zoom+view.focus).distance_to(world_before)<0.001,"zoom keeps exact world anchor")
 check(JSON.stringify(e.state)==state,"map preparation and gestures never mutate engine state")
 var slot=Store.new("user://graphics_compat.json",FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json").sha256_text());var restored=Rules.new(data)
 check(slot.save_game(e) and slot.load_game(restored) and restored.state==e.state,"save schema and complete state remain compatible")
 check(ProjectSettings.get_setting("application/config/custom_user_dir_name")=="1870-prototype-introbd","intro desktop storage isolated from stable and graphics experiment")
 view.queue_free();await process_frame
 print("GRAPHICS CONTRACT ",checks-failures,"/",checks);quit(1 if failures else 0)

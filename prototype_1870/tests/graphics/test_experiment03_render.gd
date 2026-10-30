extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const View=preload("res://war_engine/presentation/map_view.gd")
const Art=preload("res://war_engine/presentation/graphics2d_art.gd")
const Intel=preload("res://war_engine/core/intel.gd")
var checks=0
var failures=0
var board
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func digest(bytes):
 var h=HashingContext.new();h.start(HashingContext.HASH_SHA256);h.update(bytes);return h.finish().hex_encode()
func max_pixel_delta(a: Image,b: Image) -> int:
 var x=a.get_data();var y=b.get_data();var delta=0
 for k in range(x.size()):delta=maxi(delta,absi(int(x[k])-int(y[k])))
 return delta
func _initialize():call_deferred("run")
func frame():
 for k in range(3):board.queue_redraw();await process_frame;await RenderingServer.frame_post_draw
 return root.get_texture().get_image()
func run():
 root.content_scale_mode=Window.CONTENT_SCALE_MODE_DISABLED;root.size=Vector2i(1000,620)
 check(DisplayServer.get_name()!="headless","actual graphical renderer")
 for strength in [1,1999,2000,2900]:check(Art.infantry_figures(strength)==(2 if strength>=2000 else 1),"threshold "+str(strength))
 for r in [{"type":"infantry","low":1500,"high":2000},{"type":"infantry","low":1500,"high":2500}]:check(Art.contact_figures(r)==1,"ambiguous intelligence remains generic")
 check(Art.contact_figures({"type":"infantry","low":2000,"high":2500})==2,"known large estimate")
 check(Art.contact_figures({"type":"infantry","exact_strength":1999})==1 and Art.contact_figures({"type":"infantry","exact_strength":2000})==2,"exact authorized enemy threshold")
 for kind in ["cavalry","artillery","hq"]:check(Art.contact_figures({"type":kind,"exact_strength":2900})==1,"other arms keep their illustration "+kind)
 var pack=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json"));pack.map.elevations.fill(0)
 var e=Rules.new(pack);e.new_game(0,"hard")
 board=load("res://tests/graphics/uniform_board.gd").new();board.engine=e;board.texts={};board.size=root.size;root.add_child(board)
 var picture=await frame();check(picture.save_png("user://uniform_tiles_and_markers.png")==OK,"terrain/marker screenshot")
 var ground_hashes=[]
 for row in range(3):
  var samples=[]
  for col in range(3):samples.append(picture.get_region(Rect2i(127+col*200,62+row*145,66,56)))
  var delta=maxi(max_pixel_delta(samples[0],samples[1]),max_pixel_delta(samples[0],samples[2]))
  print("TILE ",row," maximum GPU byte difference ",delta)
  check(delta<=1,"same rendered tile at three indices within one GPU quantization step "+str(row));ground_hashes.append(digest(samples[0].get_data()))
  var center=picture.get_pixel(800,90+row*145);var edge=picture.get_pixel(805,90+row*145)
  check(center.is_equal_approx(Color("fff2ce")),"opaque ivory center "+str(row))
  check(edge.is_equal_approx(Color("183b37")),"dark marker edge "+str(row))
 check(ground_hashes[0]!=ground_hashes[1] and ground_hashes[1]!=ground_hashes[2],"terrain types stay distinct")
 var p=Art.label_position(board,Vector2(500,250),Vector2(500,212),Vector2(120,20),[Rect2(420,175,160,60)],[],false)
 check(not Rect2(p-Vector2(3,20),Vector2(126,24)).intersects(Rect2(420,175,160,60)),"label avoids an occupied preferred position")
 p=Art.label_position(board,Vector2(500,250),Vector2(500,293),Vector2(120,20),[Rect2(420,260,160,60)],[],true)
 check(p.y>=280,"Spachbach label stays on its existing bank")
 board.queue_free();await process_frame
 board=View.new();board.texts=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/fr.json"));board.size=root.size;root.add_child(board);board.zoom=1.8
 for side in [0,1]:
  e=Rules.new(pack);e.new_game(side,"hard")
  var n=e.unit_index("fr_14" if side==0 else "pru_36")
  for u in e.state.units:u.pending=true
  e.state.units[n].pending=false;e.state.contacts=[{},{}];e.refresh_intel();board.engine=e;board.focus=board.world(e.unit_cell(e.state.units[n]))
  var hashes=[];var bars=[]
  for strength in [1999,2000]:
   e.state.units[n].strength=strength;picture=await frame()
   hashes.append(digest(picture.get_region(Rect2i(455,261,90,72)).get_data()))
   bars.append(digest(picture.get_region(Rect2i(464,339,77,16)).get_data()))
   check(picture.save_png("user://infantry_%s_%s.png"%[side,strength])==OK,"actual infantry threshold screenshot")
  check(hashes[0]!=hashes[1],"production icon changes at 2000, camp "+str(side))
  check(bars[0]==bars[1],"force/flag strip preserved at threshold, camp "+str(side))
 # Two worlds: only hidden live strength/position change; authorized contact remains fixed.
 e=Rules.new(pack);e.new_game(0,"hard")
 for u in e.state.units:u.pending=true
 var foe=e.unit_index("pru_36");e.state.units[foe].pending=false;e.state.contacts=[{},{}]
 var report=Intel.report(e,foe,1,false);report.low=1500;report.high=2500;e.state.contacts[0][str(foe)]=report
 var cells={}
 for i in range(600):cells[str(i)]=true
 e.vision_cache=[{"cells":cells,"levels":{str(foe):1}},{"cells":{},"levels":{}}];board.engine=e;board.focus=board.world(e.index(Vector2i(int(report.cell[0]),int(report.cell[1]))))
 var hidden_hashes=[]
 for strength in [1999,2000,2500]:
  e.state.units[foe].strength=strength;picture=await frame();hidden_hashes.append(digest(picture.get_data()))
 check(hidden_hashes[0]==hidden_hashes[1] and hidden_hashes[1]==hidden_hashes[2],"live hidden strength never changes contact rendering")
 e.vision_cache[0].levels={};picture=await frame();var stale=digest(picture.get_data())
 e.state.units[foe].cell=[0,0];e.state.units[foe].strength=2000;picture=await frame()
 check(digest(picture.get_data())==stale,"hidden movement never moves labels or cached contact")
 board.queue_free();await process_frame
 print("EXPERIMENT 03 RENDER ",checks-failures,"/",checks);quit(1 if failures else 0)

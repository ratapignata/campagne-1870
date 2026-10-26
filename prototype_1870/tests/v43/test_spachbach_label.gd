extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const Board=preload("res://war_engine/presentation/map_view.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 var pack=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json"));var e=Rules.new(pack);var original=e.pack.duplicate(true);var blocked={}
 for edge in pack.map.river_edges:blocked[e.river_key(int(edge.a),int(edge.b))]=true
 var east={e.index(Vector2i(18,19)):true};var queue=east.keys();var head=0
 while head<queue.size():
  var pos=int(queue[head]);head+=1
  for next in e.neighbours(pos):
   if not blocked.has(e.river_key(pos,next)) and not east.has(next):east[next]=true;queue.append(next)
 check(not east.has(e.index(Vector2i(17,11))),"Spachbach hex belongs to western bank, cutting even bridged river edges for classification")
 var source=JSON.parse_string(FileAccess.get_file_as_string("res://development/historical_trial0825/map_candidate.json"))
 check(source.tiles[347].bank=="west","archived cartographic extraction also says western bank")
 var board=Board.new();check(board.settlement_label_offset("Spachbach").y>0,"label below its settlement, away from river")
 check(board.settlement_label_offset("Wœrth")==Vector2(0,-38),"other village labels unchanged")
 check(e.pack==original,"label check does not change terrain or coordinates")
 board.free();print("SPACHBACH LABEL ",checks-failures,"/",checks);quit(1 if failures else 0)

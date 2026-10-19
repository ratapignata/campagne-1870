extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const Store=preload("res://war_engine/platform/save_store.gd")
var checks=0
var failures=0
var actions=[]
func check(ok:bool,what:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",what)
func data():return JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v42_lot8.json"))
func blocked():
 var e=Rules.new(data());e.new_game(0,"medium");e.state.seed=187037;e.state.ai_style=0
 var n=e.unit_index("pru_55");var h=e.unit_index("qg_fr_Raoult");var goal=e.unit_cell(e.state.units[h])
 while int(e.state.turn)<3:
  if int(e.state.side)==1:
   for attempt in range(30):
    if not e.can_act(n) or e.unit_cell(e.state.units[n])==goal:break
    var route=e.path_to(n,goal,true)
    if route.is_empty():break
    var reach=e.reach(n);var dest=-1
    for cell in route:
     if reach.costs.has(cell) and e.unit_at(cell)<0:dest=cell
    if dest<0:break
    var path=e.path_to(n,dest)
    if path.size()<2:break
    var from=e.state.units[n].cell.duplicate();var ap=int(e.state.units[n].ap);var result=e.move(n,path)
    actions.append({"turn":e.state.turn,"side":e.state.side,"from":from,"path":path,"result":result,"to":e.state.units[n].cell.duplicate(),"ap_before":ap,"ap_after":e.state.units[n].ap})
    check(result in ["moved","discovered","capture"] and e.validate(e.state),"actual legal cavalry move")
  check(e.state.units[h].pending and not e.alive(h),"HQ absent only before scheduled arrival")
  e.end_side()
 return e
func _initialize():call_deferred("run")
func run():
 var p=data();var e=Rules.new(p);e.new_game(0,"medium");var h=e.unit_index("qg_fr_Raoult");var c=e.unit_index("pru_55");var goal=e.unit_cell(e.state.units[h])
 check(int(p.units[h].cell[0])==15 and int(p.units[h].cell[1])==4 and int(p.units[h].arrival_turn)==3,"unchanged HQ schedule and coordinates")
 check(p.map.tiles[goal]=="village","actual entry is village, not plain")
 var ids={}
 for u in p.units:ids[u.id]=true
 check(ids.size()==p.units.size(),"all 95 IDs unique")
 check(e.unit_at(goal)==-1 and e.state.units[h].pending,"pending HQ does not occupy tile")
 for i in range(4):e.end_side()
 check(e.state.turn==3 and e.alive(h) and not e.state.units[h].pending and e.unit_at(goal)==h,"free entry appears exactly at T3")
 check(e.visible_to(0,h),"own entered HQ never hidden by fog")
 e=blocked()
 check(e.unit_at(goal)==c and e.state.units[h].pending and not e.alive(h),"legal T2 enemy occupation delays T3 HQ")
 check(e.headquarters(h) and not e.headquarters(c) and e.cavalry(c),"no identity or type swap")
 var store=Store.new("user://blocked_hq.json","v43-raoult");var copy=Rules.new(p)
 var saved=store.save_game(e);var loaded=store.load_game(copy)
 # JSON canonicalization compares every persisted field, without StringName/String key identity.
 check(saved and loaded and JSON.parse_string(JSON.stringify(copy.state))==JSON.parse_string(JSON.stringify(e.state)),"blocked arrival physical save and reload all persisted fields")
 e=copy;e.end_side()
 check(e.state.turn==3 and e.state.side==1 and e.state.units[h].pending,"no enemy-phase HQ spawn")
 var moved=false
 for pos in e.neighbours(goal):
  var path=e.path_to(c,pos)
  if path.size()>1:
   var result=e.move(c,path);moved=result in ["moved","discovered","capture"];break
 check(moved and e.unit_at(goal)<0,"occupant vacates by legal movement, no relocation cheat")
 check(e.state.units[h].pending,"arrival still waits for scheduled phase boundary")
 e.end_side()
 check(e.state.turn==4 and e.state.side==0 and not e.state.units[h].pending and e.unit_at(goal)==h,"HQ enters original hex next own turn after clearing")
 check(e.state.units[h].cell==[15,4] and e.visible_to(0,h) and e.validate(e.state),"entered HQ is valid, visible and unmoved")
 e.state.units[h].strength=0;e.state.units[h].casualties=e.state.units[h].initial_strength;e.state.units[h].ap=0;e.state.units[h].done=true
 e.arrive_reinforcements();check(not e.alive(h) and not e.state.units[h].pending,"destroyed HQ cannot respawn as reinforcement")
 var game=load("res://main.tscn").instantiate();root.add_child(game);game.ai_enabled=false;game.music_player.stop();game.sound_enabled=false;game.close_modal()
 game.engine=blocked();game.map.engine=game.engine;game.playing=true;game.refresh()
 var before=game.engine.state.duplicate(true);var lines=game.hq_arrival_lines(true)
 check(lines.size()==1 and lines[0].contains("Raoult") and lines[0].contains("occupée") and lines[0].contains("15, 4"),"UI explains overdue Raoult and original entry")
 check(not str(lines).contains("pru_55") and game.engine.state==before,"notice neither leaks blocker ID nor mutates state")
 game.show_journal();await process_frame;var text=""
 for node in game.modal_box.find_children("*","RichTextLabel",true,false):text+=node.text
 check(text.contains("Raoult") and text.contains("reportée"),"journal displays arrival explanation")
 game.close_modal();game.selected=game.engine.unit_index("fr_25");game.target=c;game.refresh()
 check(game.context_detail.text.contains("Terrain défendu") and game.context_detail.text.contains("Village"),"charge preview explicitly identifies village")
 game.engine.state.human_side=1
 check(not str(game.hq_arrival_lines()).contains("Raoult"),"enemy HQ schedule not disclosed")
 game.engine=Rules.new(p);game.engine.new_game(1,"medium");game.map.engine=game.engine
 for i in range(6):game.engine.end_side()
 check(game.engine.state.turn==4 and game.engine.state.side==0 and game.hq_arrival_lines(true).is_empty(),"German T4 reinforcements not falsely overdue before German phase")
 check(str(game.hq_arrival_lines()).contains("prévue"),"future own-phase HQ still shown as scheduled")
 game.queue_free();await process_frame
 var report={"checks":checks,"failures":failures,"seed":187037,"legal_cavalry_actions":actions,"finding":"Raoult scheduled T3 (15,4), village; legal cavalry occupation T2 delays arrival. Mechanics unchanged, missing UI explanation corrected."}
 var f=FileAccess.open("user://raoult_report.json",FileAccess.WRITE);f.store_string(JSON.stringify(report,"\t"));f.close()
 print("V43 RAOULT ",checks-failures,"/",checks);quit(1 if failures else 0)

extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
var checks=0
var failures=0
func check(ok:bool,what:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",what)
func fixture(attacking_side:int,terrain:String):
 var p=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json"))
 p.rules.support.enabled=false;p.rules.fog.enabled=false;p.map.tiles.fill("plain");p.map.elevations.fill(0);p.map.river_edges=[];p.map.road_edges=[]
 var f=p.units[24].duplicate(true);var g=p.units[53].duplicate(true);var roster=[]
 var positions=[[9,9],[9,10],[11,9],[11,10]]
 for i in range(4):
  var u=(f if attacking_side==0 else g).duplicate(true);u.id="attacker_"+str(i);u.side=attacking_side;u.cell=positions[i];u.arrival_turn=1;u.initial_strength=400;roster.append(u)
 var d=(g if attacking_side==0 else f).duplicate(true);d.id="defender";d.side=1-attacking_side;d.cell=[10,10];d.arrival_turn=1;d.initial_strength=400;roster.append(d);p.units=roster;p.map.tiles[310]=terrain
 var e=Rules.new(p);e.new_game(attacking_side,"medium");e.state.side=attacking_side;e.state.ai_style=0
 return e
func _initialize():
 var report={"fixture":"Synthetic four fresh 400-man cavalry attackers against one 400-man defender; no support/fog, true plain or village; no resetting defender losses or retreats.","samples":[]}
 for terrain in ["plain","village"]:
  for seed_value in range(64):
   var mirrors=[]
   for side in [0,1]:
    var e=fixture(side,terrain);e.state.seed=430000+seed_value;var events=[];var power=e.attack_power_against(0,4);var defence=e.defence_power_against(4,0)
    for a in range(4):
     if e.unit_cell(e.state.units[4])!=310 or not e.alive(4):break
     var start=e.state.units[a].duplicate(true);var before=e.state.units[4].duplicate(true);var r=e.assault(a,4)
     check(r.status=="ok","successive adjacent charge legal")
     if r.status!="ok":break
     check(r.event.kind=="charge" and not r.event.reaction and int(e.state.units[4].reactions)==1,"sabre has no firearm riposte or reaction consumption")
     check(int(e.state.units[4].strength)+int(e.state.units[4].casualties)+int(e.state.units[4].prisoners)==400,"defender strength accounting exact")
     check(int(before.strength)-int(e.state.units[4].strength)==int(r.event.loss)+int(r.event.prisoners),"losses persist between charges")
     check(e.validate(e.state),"combat, morale, retreats remain valid")
     check(int(start.ap)-int(e.state.units[a].ap)>=8 and e.assault_cost(a)==8,"charge costs two PA; retreat may spend rest")
     events.append({"event":r.event,"attacker_before":start,"attacker_after":e.state.units[a].duplicate(true),"defender_before":before,"defender_after":e.state.units[4].duplicate(true)})
    var compact=[]
    for row in events:compact.append({"loss":row.event.loss,"return_loss":row.event.return_loss,"outcome":row.event.outcome,"morale":row.defender_after.morale,"strength":row.defender_after.strength,"retreat":row.event.retreat})
    mirrors.append(compact)
    if terrain=="plain":check(events.size()==1 and not events[0].event.retreat.is_empty(),"equal cavalry dislodged by first plain charge")
    if seed_value==0:report.samples.append({"terrain":terrain,"attacking_side":side,"seed":430000,"attack_power":power,"defence_power":defence,"events":events})
   check(mirrors[0]==mirrors[1],"identical mechanics and outcomes when camps exchanged")
 report.checks=checks;report.failures=failures
 var f=FileAccess.open("user://cavalry_report.json",FileAccess.WRITE);f.store_string(JSON.stringify(report,"\t"));f.close()
 print("V43 CAVALRY ",checks-failures,"/",checks);quit(1 if failures else 0)

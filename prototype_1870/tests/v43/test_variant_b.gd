extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const Baseline=preload("res://tests/v43/reference_v42_engine.gd")
const Store=preload("res://war_engine/platform/save_store.gd")
var checks=0
var failures=0
func check(ok:bool,what:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",what)
func fixture(kind:String,side:int,terrain:String,size:int=2900,enabled:bool=true,base:bool=false):
 var p=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json"))
 if not enabled:p.rules.assault.erase("infantry_strength_exponent")
 p.rules.support.enabled=false;p.rules.fog.enabled=false;p.map.tiles.fill("plain");p.map.elevations.fill(0);p.map.river_edges=[];p.map.road_edges=[]
 var a=p.units[34 if side==1 else 0].duplicate(true);var b=p.units[0 if side==1 else 34].duplicate(true)
 a.initial_strength=size;b.initial_strength=1000;a.cell=[10,10];b.cell=[10,11];a.arrival_turn=1;b.arrival_turn=1
 if kind=="cavalry":a.weapon="sabre";b.weapon="sabre"
 elif kind=="infantry_cavalry":b.weapon="sabre"
 elif kind=="cavalry_infantry":a.weapon="sabre"
 elif kind=="artillery":b.weapon="krupp" if side==0 else "french_rifled"
 elif kind=="hq":b.weapon="escort_dreyse" if side==0 else "escort_chassepot"
 p.units=[a,b];p.map.tiles[340]=terrain
 var e=Baseline.new(p) if base else Rules.new(p);e.new_game(side,"medium");e.state.side=side;e.state.ai_style=0
 for u in e.state.units:u.formation="line" if u.weapon!="sabre" else "none"
 e.state.units[1].entrenched=terrain=="village";e.state.units[1].deployed=e.artillery(1)
 return e
func _initialize():
 var report={"normalization":"1000 * (strength / 1000)^0.90; symmetric infantry-only melee. Ratios before defensive volley; actual combat samples include unchanged defensive volley.","samples":[]}
 for terrain in ["plain","village"]:
  for side in [0,1]:
   var records=[]
   for base in [true,false]:
    var e=fixture("infantry",side,terrain,2900,true,base);var power=e.attack_power_against(0,1);var defence=e.defence_power_against(1,0);var taken=0;var losses=0;var received=0;var routed=0;var reactions=0
    for seed_value in range(64):
     e=fixture("infantry",side,terrain,2900,true,base);e.state.seed=430000+seed_value;var r=e.assault(0,1)
     check(r.status=="ok" and e.validate(e.state),"actual infantry melee and state valid")
     if r.status=="ok":
      taken+=int(r.event.outcome=="taken");losses+=int(r.event.loss);received+=int(r.event.return_loss);routed+=int(r.event.new_morale=="routed");reactions+=int(r.event.reaction)
      check(int(e.state.units[0].strength)+int(e.state.units[0].casualties)+int(e.state.units[0].prisoners)==2900,"attacker conservation")
      check(int(e.state.units[1].strength)+int(e.state.units[1].casualties)+int(e.state.units[1].prisoners)==1000,"defender conservation")
    records.append({"version":"V42" if base else "V43 B","power":power,"defence":defence,"ratio":power/defence,"taken_of_64":taken,"mean_inflicted":float(losses)/64,"mean_received":float(received)/64,"routed_of_64":routed,"reactions_of_64":reactions})
   report.samples.append({"terrain":terrain,"defender_entrenched":terrain=="village","attacking_side":side,"attacker_strength":2900,"defender_strength":1000,"results":records})
   check(is_equal_approx(records[1].power/records[0].power,pow(2.9,-0.1)) and is_equal_approx(records[1].defence,records[0].defence),"2900 power decreases symmetrically, 1000 anchor unchanged")
 for size in [200,400,1000,2000,2900,4577]:
  var e=fixture("infantry",1,"plain",size);var old=fixture("infantry",1,"plain",size,true,true)
  check(is_equal_approx(e.attack_power_against(0,1),1000*pow(float(size)/1000,0.9)),"normalized attacker formula")
  e.state.units[0].strength=size;e.state.units[1].strength=size
  check(is_equal_approx(e.attack_power_against(0,1),e.defence_power_against(1,0)),"same exponent on defence and attack for equal terrain/formation")
  check(is_equal_approx(e.melee_strength(0,1,float(size)/2),1000*pow(float(size)/2000,0.9)),"post-volley remaining strength uses exponent")
  var rng=RandomNumberGenerator.new();rng.seed=42;var rng2=RandomNumberGenerator.new();rng2.seed=42
  var current=fixture("infantry",1,"plain",size)
  check(current.shot_loss(0,1,rng)==old.shot_loss(0,1,rng2),"infantry fire damage unchanged")
 for kind in ["cavalry","infantry_cavalry","cavalry_infantry","artillery","hq"]:
  for side in [0,1]:
   var e=fixture(kind,side,"plain");var old=fixture(kind,side,"plain",2900,true,true)
   check(is_equal_approx(e.attack_power_against(0,1),old.attack_power_against(0,1)) and is_equal_approx(e.defence_power_against(1,0),old.defence_power_against(1,0)),"non infantry-pair powers unchanged "+kind)
   for seed_value in range(8):
    e=fixture(kind,side,"plain");old=fixture(kind,side,"plain",2900,true,true);e.state.seed=430000+seed_value;old.state.seed=e.state.seed
    check(e.assault(0,1)==old.assault(0,1),"actual non-infantry combat event unchanged "+kind)
 var legacy=fixture("infantry",1,"village",2900,false);var baseline=fixture("infantry",1,"village",2900,true,true)
 legacy.state.seed=777;baseline.state.seed=777
 check(legacy.assault(0,1)==baseline.assault(0,1),"old scenarios without opt-in keep V42 melee")
 var old=Rules.new(JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v42_lot8.json")));old.new_game(0,"medium");old.state.seed=187037
 var old_raw=FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v42_lot8.json");var new_raw=FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json");var p=JSON.parse_string(new_raw);var fresh=Rules.new(p)
 var source=Store.new("user://v42_lot8_legacy.json",old_raw.sha256_text());var destination=Store.new("user://v43_imported.json",new_raw.sha256_text(),p.save_migrations)
 check(source.save_game(old) and destination.import_compatible(fresh,[{"path":source.path,"pack_hash":old_raw.sha256_text()}]),"real V42 physical save migrates into separate V43 slot")
 check(same_persisted_state(fresh.state,old.state),"migration preserves every persisted field")
 check(fresh.pack.id=="regimental_trial_v43" and fresh.pack.rules.assault.infantry_strength_exponent==0.9,"resumed battle adopts variant B for future melee only")
 var copy=Rules.new(p);check(destination.load_game(copy) and copy.state==fresh.state,"V43 save reload stable")
 var units=p.units;var sum=0;var count=0
 for u in units:
  if int(u.side)==1:sum+=int(u.initial_strength);count+=1
 check(sum==95000 and count==50 and int(p.rules.turns)==20 and int(p.unit_types.cavalry.charge_ap)==8,"immutable roster, duration, charge")
 var full=Rules.new(p);full.new_game(0,"medium")
 while not full.state.finished:
  full.end_side();check(full.validate(full.state),"actual 95-unit V43 20-turn boundary valid")
 check(full.state.turn==20 and full.state.loss_history.size()==20,"full roster records exactly 20 turns without extra turn")
 report.checks=checks;report.failures=failures
 var f=FileAccess.open("user://variant_b_report.json",FileAccess.WRITE);f.store_string(JSON.stringify(report,"\t"));f.close()
 print("V43 VARIANT B ",checks-failures,"/",checks);quit(1 if failures else 0)

func same_persisted_state(actual: Dictionary,original: Dictionary) -> bool:
 var copy=actual.duplicate(true)
 if copy.get("objective_layout","")!="v4312":return false
 copy.erase("objective_layout")
 return JSON.parse_string(JSON.stringify(copy))==JSON.parse_string(JSON.stringify(original))

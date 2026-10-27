extends "res://tests/test_ai_compat0833.gd"
const Frozen=preload("res://war_engine/ai/v4311_ai.gd")
func _initialize():
 var p=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json"));profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
 var normal=Rules.new(p);normal.new_game(0,"medium");normal.state.seed=18704311;normal.state.ai_style=0
 var hard=Rules.new(p);hard.new_game(0,"hard");hard.state.seed=18704311;hard.state.ai_style=0
 for u in p.units:
  check(normal.reinforcement_turn(u)==int(u.get("arrival_turn",1)),"Normal schedule preserved "+u.id)
  var expected=int(u.get("arrival_turn",1))
  if int(u.side)==1 and expected>1:expected-=1
  check(hard.reinforcement_turn(u)==expected,"Hard schedule "+u.id)
 check(normal.state.units==hard.state.units,"no initial hidden strength or AP bonus")
 hard.state.turn=2;hard.state.side=1;hard.arrive_reinforcements()
 for id in ["reserve_art_10","reserve_art_11"]:check(not hard.state.units[hard.unit_index(id)].pending,"Prussian guns arrive T2")
 normal.state.turn=2;normal.state.side=1;normal.arrive_reinforcements()
 check(normal.state.units[normal.unit_index("reserve_art_10")].pending,"Normal guns still pending T2")
 check(hard.state.units[hard.unit_index("qg_fr_Raoult")].pending,"Raoult date not accelerated")
 for incoming in hard.observation(1).own_reinforcements:
  var i=hard.unit_index(incoming.id);check(int(incoming.arrival_turn)==hard.reinforcement_turn(hard.state.units[i]),"planning sees own effective schedule")
 # Reduced position on the unchanged map; checks policy, not battle balance.
 var ids=["pru_36","art_pr_Sandrart0","qg_pr_Sandrart","fr_7","art_fr_Pelle0"]
 var small=p.duplicate(true);small.units=[]
 for u in p.units:
  if u.id in ids:small.units.append(u.duplicate(true))
 for side in [0,1]:
  var e=Rules.new(small);e.new_game(0,"medium");e.state.side=side;e.state.seed=42;e.state.ai_style=0;e.refresh_intel()
  var view=e.observation(side);var before=view.duplicate(true);var ref=view.duplicate(true);ref.state.ai_difficulty="hard"
  var former=Frozen.new();former.profiles=profiles
  var current=bot();var chosen=current.choose(view)
  check(chosen==former.choose(ref),"Normal exactly V43.11 Hard side "+str(side));check(view==before,"Normal observation intact")
  check(dispatch(e,chosen) and e.validate(e.state),"Normal action legal")
  e.state.ai_difficulty="hard";view=e.observation(side);before=view.duplicate(true)
  var h=bot();var action=h.choose(view);check(view==before,"Hard observation intact")
  check(dispatch(e,action) and e.validate(e.state),"Hard action legal")
 var ai=bot();ai.settings=profiles.hard
 for id in ["pru_36","pru_40"]:
  var i=hard.unit_index(id);check(ai.operational_goal(hard,i)==hard.index(Vector2i(13,10)),"central formations aim at Woerth")
 for id in ["pru_44","pru_48"]:
  var i=hard.unit_index(id);check(ai.operational_goal(hard,i)==hard.index(Vector2i(22,11)),"two formations reinforce right crossing")
 check(hard.pack==p and normal.pack==p,"scenario map and military rules unchanged")
 var world=Rules.new(small);world.new_game(0,"hard");world.state.side=1;world.state.ai_style=0;world.state.seed=42;world.refresh_intel()
 var twin=Rules.new(small);twin.state=world.state.duplicate(true);var hidden=twin.unit_index("fr_7");twin.state.units[hidden].cell=[2,1];twin.state.units[hidden].strength=117;twin.state.units[hidden].casualties=int(twin.state.units[hidden].initial_strength)-117;twin.refresh_intel()
 check(not world.visible_to(1,world.unit_index("fr_7")) and not twin.visible_to(1,hidden),"both worlds have unseen French infantry")
 var public_a=world.observation(1);var public_b=twin.observation(1);check(public_a==public_b,"new Hard sees identical public state")
 check(bot().choose(public_a)==bot().choose(public_b),"new operational axes do not use hidden enemy truth")
 var pending=Rules.new(p);pending.new_game(0,"hard");pending.state.turn=2;pending.state.side=1
 var slot=Store.new("user://calendar_v4312.json",FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json").sha256_text());var resumed=Rules.new(p)
 check(slot.save_game(pending) and slot.load_game(resumed),"Hard pending reinforcements save roundtrip")
 var gun=resumed.unit_index("reserve_art_10");check(int(resumed.state.units[gun].arrival_turn)==3 and resumed.reinforcement_turn(resumed.state.units[gun])==2,"original and effective date preserved on reload")
 resumed.arrive_reinforcements();check(not resumed.state.units[gun].pending and resumed.validate(resumed.state),"early arrival after reload remains valid")
 print("V43.12 ",checks-failures,"/",checks);quit(1 if failures else 0)

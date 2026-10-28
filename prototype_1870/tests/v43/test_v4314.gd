extends "res://tests/test_ai_compat0833.gd"
const Prior=preload("res://tests/v43/reference_ai_v4313.gd")
const Report=preload("res://war_engine/presentation/battle_report.gd")
func gun_fixture():
 var p=data.duplicate(true);p.units=[];p.rules.support.enabled=false;p.rules.fog.enabled=false;p.map.river_edges=[];p.map.tiles.fill("plain");p.map.elevations.fill(0)
 for id in ["art_pr_Schmidt0","pru_36","fr_7"]:
  for u in data.units:
   if u.id==id:p.units.append(u.duplicate(true))
 var cells=[[13,10],[15,3],[13,1]]
 for n in range(p.units.size()):p.units[n].cell=cells[n];p.units[n].arrival_turn=1
 var e=Rules.new(p);e.new_game(0,"hard");e.state.turn=12;e.state.side=1;e.state.units[0].deployed=true;e.state.units[0].entrenched=true
 for n in [1,2]:e.state.units[n].ap=0;e.state.units[n].done=true
 e.state.objective_owners.elsasshausen=1;e.refresh_intel();return e
func _initialize():
 data=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json"));profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
 var e=gun_fixture();var old=Prior.new();old.profiles=profiles;var ai=bot();var view=e.observation(1,[2]);var copy=view.duplicate(true);var a=old.choose(view);var b=ai.choose(view)
 print("SILENT OBJECTIVE BATTERY ",JSON.stringify(a)," -> ",JSON.stringify(b))
 check(a.kind=="end","reference battery stays on held objective without shot")
 check(b.kind=="limber","battery leaves silent garrison to support observed infantry")
 check(view==copy and dispatch(e,b),"battery decision legal and observation unchanged")
 var move=ai.choose(e.observation(1,[2]));check(move.kind=="move" and dispatch(e,move),"limber followed by legal support movement")
 e.end_side();e.end_side();e.state.units[1].done=true
 var fired=false
 for k in range(6):
  var d=ai.choose(e.observation(1,[2]));print("BATTERY FOLLOW ",JSON.stringify(d))
  if d.kind=="end":break
  check(dispatch(e,d),"battery follow-up legal")
  if d.kind=="fire":fired=true;break
 check(fired,"silent battery really resumes firing after repositioning")
 # A current lane must remain stable, even on a held objective.
 e=gun_fixture();e.state.units[2].cell=[13,5];e.refresh_intel();a=Prior.new();a.profiles=profiles;b=bot().choose(e.observation(1,[2]))
 check(b.kind=="fire" and b==a.choose(e.observation(1,[2])),"useful battery retains reference fire decision")
 # No visible engagement means no invented target or movement mission.
 e=gun_fixture();e.state.units[2].strength=0;e.refresh_intel();ai=bot();b=ai.choose(e.observation(1,[2]));check(b.kind=="end","no observed defender: no invented target")
 # Normal remains the frozen V43.11 policy, byte-for-byte at a decision boundary.
 e=gun_fixture();e.state.ai_difficulty="medium";a=Prior.new();a.profiles=profiles
 check(bot().choose(e.observation(1,[2]))==a.choose(e.observation(1,[2])),"Normal unchanged on reposition fixture")
 # Unsupported advance protection does not alter group assaults or military rules.
 e=gun_fixture();ai=bot();ai.hard_offensive=true;var pe=ai.Rules.new(e.pack,e.state);var n=1;var start=pe.unit_cell(pe.state.units[n]);var dest=pe.index(Vector2i(15,3));pe.set_planning_cell(2,[16,3])
 # Add one observed opposing infantry to create a pincer.
 var foe=pe.state.units[2].duplicate(true);foe.id="visible_second";foe.cell=[15,4];pe.state.units.append(foe)
 var cut={"command_ok":false,"supply_ok":false}
 check(ai.advance_protection(pe,n,start,dest,2,cut)==-INF,"unsupported advance losing both links into visible pincer refused")
 var ally=pe.state.units[1].duplicate(true);ally.id="support";ally.cell=[14,3];pe.state.units.append(ally)
 check(ai.advance_protection(pe,n,start,dest,2,cut)==0,"supported mass advance retains score")
 pe.state.units.pop_back();check(ai.advance_protection(pe,n,start,dest,0,{"command_ok":true,"supply_ok":false})>0,"isolated lone unit favors restoring one link")
 ai.hard_offensive=false;check(ai.advance_protection(pe,n,start,dest,2,cut)==0,"protection does not affect other modes or doctrines")
 # Real network event with details, roundtrip and semantic rejection.
 e=Rules.new(data);e.new_game(0,"hard");var unit=0;e.state.units[unit].cell=[29,0];e.refresh_support(false)
 var event=e.state.support_events[-1];var own={}
 for record in e.state.support_events:
  if record.unit==e.state.units[unit].id and record.has("links"):own=record
 check(not own.is_empty() and own.links.has("command_reason") and own.links.has("hq_id"),"network cut records own reasons and HQ")
 check(e.validate(e.state),"new diagnostic event validates")
 var store=Store.new("user://v4314_links.json","v4314");var restored=Rules.new(data)
 check(store.save_game(e) and store.load_game(restored) and restored.state.support_events==e.state.support_events,"all diagnostic fields save and load")
 var corrupt=e.state.duplicate(true);corrupt.support_events[-1].links={"command_ok":"invalid"};check(not e.validate(corrupt),"invalid diagnostic fields safely rejected")
 var legacy=e.state.duplicate(true)
 for record in legacy.support_events:record.erase("links")
 check(e.validate(legacy),"old saves without diagnostics accepted")
 check(not e.observation(1,[2]).state.has("support_events"),"opponent observation never exposes diagnostic log")
 # Final report uses current objective definitions and the actual 60/20/20 result.
 var texts=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/fr.json"))
 check(Report.build(e,texts).is_empty(),"exact final report refused during ongoing game")
 e.state.finished=true;var text=Report.build(e,texts);var before=JSON.stringify(e.state)
 check(text.contains("Wœrth · 2 points") and not text.contains("Elsasshausen · 2 points"),"current report objective truly Woerth")
 check(text.contains("60 / 20 / 20") and text.contains("TOTAL") and text.contains("CAPITULATIONS"),"report includes scoring and history")
 e.state.objective_layout="v4312";check(Report.build(e,texts).contains("Elsasshausen · 2 points"),"old-layout report preserves original objective")
 e.state.erase("objective_layout");check(JSON.stringify(e.state)==before,"report leaves complete state unchanged")
 print("V43.14 CORE ",checks-failures,"/",checks);quit(1 if failures else 0)

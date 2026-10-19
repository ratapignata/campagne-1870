from pathlib import Path
import json,shutil
r=Path(__file__).resolve().parents[2]
f=r/'packs/1870/prototype.json';shutil.copyfile(f,r/'packs/1870/legacy0815.json');p=json.loads(f.read_text());p['id']='sauer_test_v0816';p['unit_types']['cavalry']['ap']=16;p['rules']['undo_player_discovery_only']=True;f.write_text(json.dumps(p,ensure_ascii=False,indent=2)+'\n')
f=r/'war_engine/core/rules_base.gd';s=f.read_text();s=s.replace('"events":[]}', '"events":[],"undo_reason":"none"}',1)
s=s.replace('func normalize() -> void:\n','func normalize() -> void:\n\tstate.undo_reason=str(state.get("undo_reason","none"))\n',1)
s=s.replace('previous=state.duplicate(true);state.active=n','previous=state.duplicate(true);state.undo_reason="available";state.active=n',1)
s=s.replace('state.owner=state.side;previous={};return "capture"','state.owner=state.side;previous={};state.undo_reason="capture";return "capture"',1)
s=s.replace('previous={};return true\nfunc end_side()', 'previous={};state.undo_reason="rest";return true\nfunc end_side()',1)
s=s.replace('previous={};state.active=-1\n\tif int(state.side)', 'previous={};state.undo_reason="turn";state.active=-1\n\tif int(state.side)',1)
s=s.replace('state.active=n if not u.done else -1;previous={}\n\treturn true','state.active=n if not u.done else -1;previous={};state.undo_reason="deployment"\n\treturn true',1)
s=s.replace('func undo() -> bool:', '''func undo_status() -> String:
	if state.finished:return "finished"
	if not previous.is_empty():return "ok"
	var reason=str(state.get("undo_reason","none"))
	return "none" if reason=="available" else reason
func undo() -> bool:''',1);f.write_text(s)
f=r/'war_engine/core/engine.gd';s=f.read_text()
s=s.replace('state.active=n if not u.done else -1;previous={};refresh_intel();return true','state.active=n if not u.done else -1;previous={};state.undo_reason="formation";refresh_intel();return true',1)
s=s.replace('previous=before if not captured and not discovered and intel_signature(1-int(u.side))==other_before else {}','''var enemy_changed=intel_signature(1-int(u.side))!=other_before
	var enemy_lock=enemy_changed and not bool(pack.rules.get("undo_player_discovery_only",false))
	previous=before if not captured and not discovered and not enemy_lock else {}
	state.undo_reason="capture" if captured else "discovery" if discovered else "information" if enemy_lock else "available"''',1)
s=s.replace('previous={};state.events.append(event)','previous={};state.undo_reason="assault" if event.kind in ["assault","charge"] else "fire";state.events.append(event)',1)
s=s.replace('u.rallied=true;previous={};refresh_intel()','u.rallied=true;previous={};state.undo_reason="rally";refresh_intel()',1)
s=s.replace('u.entrenched=false;previous={}\n\tif best<0','u.entrenched=false;previous={};state.undo_reason="retreat"\n\tif best<0',1)
s=s.replace('safe.erase("contacts");safe.erase("revealed")','safe.erase("contacts");safe.erase("revealed");safe.erase("undo_reason")',1)
s=s.replace('func validate(s: Dictionary) -> bool:\n','func validate(s: Dictionary) -> bool:\n\tif s.get("undo_reason","none") not in ["none","available","capture","turn","rest","deployment","formation","discovery","information","assault","fire","rally","retreat","entrench"]:return false\n',1)
s=s.replace('state.active=n if not u.done else -1;previous={};refresh_intel();return true','state.active=n if not u.done else -1;previous={};state.undo_reason="entrench";refresh_intel();return true',1);f.write_text(s)
f=r/'war_engine/presentation/main.gd';s=f.read_text().replace('save_v0815.json','save_v0816.json').replace('for entry in [["legacy0814.json"','for entry in [["legacy0815.json","save_v0815.json"],["legacy0814.json"')
s=s.replace('if b==actions.undo:return t("undo_unavailable")','if b==actions.undo:return t("undo_"+engine.undo_status())',1)
s=s.replace('var result=engine.move(selected,route);clear_preview();persist()','''var was_halted=bool(engine.state.units[selected].get("river_halt",false))
	var result=engine.move(selected,route)
	if not was_halted and engine.state.units[selected].get("river_halt",false):map.animate_crossing(selected)
	clear_preview();persist()''',1)
s=s.replace('if human_turn() and not map.busy() and engine.undo():clear_preview();persist();refresh(t("hint_undo"))','if human_turn() and not map.busy() and engine.undo():map.crossing_ttl=0;clear_preview();persist();refresh(t("hint_undo"))',1)
s=s.replace('map.feedback_ttl=0;map.combat_ttl=0;ai_clock=0','map.feedback_ttl=0;map.combat_ttl=0;map.crossing_ttl=0;ai_clock=0',1)
s=s.replace('"move":success=engine.move(n,decision.path) in ["moved","capture","discovered"]','''"move":
			var was_halted=bool(engine.state.units[n].get("river_halt",false))
			success=engine.move(n,decision.path) in ["moved","capture","discovered"]
			if success and not was_halted and engine.state.units[n].get("river_halt",false):map.animate_crossing(n)''',1)
f.write_text(s)
f=r/'packs/1870/fr.json';t=json.loads(f.read_text());t['badge']='PROTOTYPE 0.8.16 · SAUER';t['river_preview']='Traversée : +2 PA\nDéplacement terminé sur l’autre rive.'
t.update(undo_none='Aucun déplacement à annuler.',undo_capture='Objectif capturé : retour impossible.',undo_turn='Tour terminé : retour impossible.',undo_rest='Repos engagé : retour impossible.',undo_deployment='Artillerie déplacée ou déployée : retour bloqué.',undo_formation='Formation changée : retour impossible.',undo_discovery='Informations ennemies découvertes :\nretour impossible.',undo_information='Informations actualisées : retour impossible.',undo_assault='Assaut effectué : retour impossible.',undo_fire='Tir effectué : retour impossible.',undo_rally='Ralliement effectué : retour impossible.',undo_retreat='Repli subi : retour impossible.',undo_entrench='Retranchement effectué : retour impossible.',undo_finished='Bataille terminée : retour impossible.')
t['help_basics_body']=t['help_basics_body'].replace('la cavalerie reçoit 5 PA par tour, l’infanterie et l’artillerie 4 PA','la cavalerie, l’infanterie et l’artillerie reçoivent 4 PA par tour').replace('« Annuler mouvement » apparaît seulement lorsqu’une annulation est disponible','« Annuler mouvement » reste visible pendant votre tour')
t['help_basics_body']+='\n\nLe dernier déplacement peut être annulé même à 0 PA : la position, les PA et la possibilité de déplacement sont restaurés. Une nouvelle information ennemie, une capture ou une action engagée bloque ce retour. Dans les nouvelles parties, être simplement observé par l’adversaire ne suffit plus à bloquer l’annulation.'
t['help_river']+='\nUne flèche bleue signale le franchissement prévu dans le trajet. Quelques ondulations accompagnent la traversée effective, sans pause obligatoire. Les fines courbes brunes marquent les changements de niveau du relief ; elles n’ajoutent aucune règle.'
f.write_text(json.dumps(t,ensure_ascii=False,indent=2)+'\n')
for name in ['project.godot','export_presets.cfg']:
 f=r/name;f.write_text(f.read_text().replace('0.8.15','0.8.16').replace('version/code=28','version/code=29'))

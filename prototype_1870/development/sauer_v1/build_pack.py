from pathlib import Path
import json
root=Path(__file__).resolve().parents[2];file=root/'packs/1870/prototype.json';p=json.loads((root/'packs/1870/legacy0813.json').read_text());data=json.loads((root/'development/historical05/sector.json').read_text())
p['id']='sauer_test_v0814';p['historical_status']='ADAPTATION_GAMEPLAY';p['historical_note']='Bataille d’essai fictive sur une interprétation provisoire du secteur Wœrth–Gunstett. Ne représente pas l’ordre de bataille ni le déroulement du 6 août.'
p['rules']['turns']=10;p['rules']['start_hour']=8;p['rules']['river']={'infantry_extra_ap':8,'repairs':False,'historical_status':'ADAPTATION_GAMEPLAY'}
p['terrains']['meadow']={**p['terrains']['plain'],'cost':4,'color':'c3d2ad'}
p['terrains']['cultivated']={**p['terrains']['plain'],'cost':6,'color':'cbbc94','fire_received':.85,'assault_defence':1.1}
p['terrains']['offmap']={**p['terrains']['plain'],'cost':-1,'color':'bcc1ac'}
p['unit_types']['cavalry']['movement_costs'].update(meadow=3,cultivated=6)
p['unit_types']['cavalry']['charge_terrain'].update(meadow=.85,cultivated=.65)
p['map']['tiles']=[t['terrain']if t['active']else'offmap'for t in data['tiles']]
p['map']['elevations']=[t['level']if t['active']else 0 for t in data['tiles']]
p['map']['north_left']=True;p['map']['neighbor_distance_m']=350
p['map']['river_edges']=[{'a':e['a'],'b':e['b'],'bridge':'C3' in e['crossings']}for e in data['river_edges']]
p['map']['view']={'focus_cell':[22,11],'zoom':1.05}
p['objective']={'cell':[22,10],'points':1};p['initial_owner']=0
positions=[[22,10],[20,9],[24,9],[21,7],[22,14],[20,14],[24,14],[23,16],[22,7],[21,16],[25,8],[25,15]]
for u,pos in zip(p['units'],positions):u['cell']=pos;u['command_group']='sauer_test_'+str(u['side'])
p['rules']['support']['supply_sources']=[[[18,3],[25,3]],[[18,17],[25,17]]];p['rules']['support']['rear_rows']=[3,17]
p['map']['labels']=[{'cell':[14,11],'text':'Wœrth'},{'cell':[22,14],'text':'Gunstett'},{'cell':[18,12],'text':'Spachbach'},{'cell':[18,7],'text':'Niederwald'}]
for u in p['units']:
 i=u['cell'][1]*30+u['cell'][0];assert data['tiles'][i]['active'];assert data['tiles'][i]['bank']==('west'if u['side']==0 else'east'),u
file.write_text(json.dumps(p,ensure_ascii=False,indent=2))
tfile=root/'packs/1870/fr.json';t=json.loads(tfile.read_text())
t.update(badge='PROTOTYPE 0.8.14 · SAUER',intro='Prenez ou défendez la sortie du pont.',intro_detail='10 tours · 6 unités par camp · adversaire IA\nBataille d’essai fictive sur le secteur de la Sauer',objective='Sortie du pont',start='Commencer la bataille',river_preview='Traversée : +2 PA · fin du déplacement',river_halt='Traversée effectuée : déplacement terminé pour ce tour.',assault_river='Traverser d’abord, puis attaquer au prochain tour.',terrain_meadow='Prairie',terrain_short_meadow='Prairie',terrain_effect_meadow='Terrain ouvert de vallée. Protection faible.',terrain_cultivated='Cultures difficiles',terrain_short_cultivated='Cultures',terrain_effect_cultivated='Déplacement ralenti et légère protection. Charge moins efficace.',terrain_offmap='Hors secteur',terrain_short_offmap='Limite',terrain_effect_offmap='Limite du scénario d’essai.',help_river='SAUER — RÈGLE SIMPLE\nL’infanterie traverse partout hors pont : coût du terrain +2 PA, puis déplacement terminé jusqu’à son prochain tour. Les PA restants restent utilisables pour les autres actions autorisées. Un assaut à travers la rivière hors pont est impossible : traversez, puis attaquez au tour suivant. Cavalerie et canons doivent passer par le pont routier. Au pont : coût normal. Pas de réparation ni de construction.\nLes chemins et la règle sont identiques pour les deux camps et pour l’IA. Les liaisons de commandement et de ravitaillement restent abstraites ; aucune gestion de convois.\nCette carte et ces forces servent à un exercice de gameplay, pas à une reconstitution complète du 6 août 1870.',north='← N')
tfile.write_text(json.dumps(t,ensure_ascii=False,indent=2))
# UI keeps previous saves via their original pack fingerprints.
pfile=root/'war_engine/presentation/main.gd';s=pfile.read_text().replace('save_v0813.json','save_v0814.json').replace('for entry in [["legacy0811.json"','for entry in [["legacy0813.json","save_v0813.json"],["legacy0811.json"')
s=s.replace('map.focus=Vector2(765,580);map.zoom=1.18;map.feedback_ttl=0','map.focus=map.world(engine.index(Vector2i(22,11))) if engine.pack.map.get("north_left",false) else Vector2(765,580);map.zoom=1.05 if engine.pack.map.get("north_left",false) else 1.18;map.feedback_ttl=0',1)
s=s.replace('saver=SaveStore.new("user://save_v0814.json",raw.sha256_text());has_save=saver.load_game(engine)','saver=SaveStore.new("user://save_v0814.json",raw.sha256_text());has_save=saver.load_game(engine)',1)
s=s.replace('if human_turn() and not map.busy() and engine.rest(selected)','if human_turn() and not map.busy() and engine.rest(selected)')
s=s.replace('elif full_route.size()>1:\n\t\tcontext_label','\t\tif engine.path_has_river(route):context_detail.text=t("river_preview")+"\\n"+t("route_confirm")\n\telif full_route.size()>1:\n\t\tcontext_label',1)
# Above replacement adds indentation from original line; normalize to the intended block.
s=s.replace('\t\t\t\tif engine.path_has_river','\t\tif engine.path_has_river')
s=s.replace('if not human_turn():context_label.text', 'if ours and target<0 and route.is_empty() and engine.state.units[selected].get("river_halt",false):context_detail.text=t("river_halt")\n\tif not human_turn():context_label.text',1)
s=s.replace('for terrain in ["plain","road","forest","village","hill","water","bridge"]:', 'if not engine.river_links.is_empty():content+=t("help_river")+"\\n\\n"\n\t\tfor terrain in (["plain","road","forest","village","meadow","cultivated"] if not engine.river_links.is_empty() else ["plain","road","forest","village","hill","water","bridge"]):',1)
pfile.write_text(s)
# Reflect vertical coordinates so north-left is a proper rotation, with east at top.
pfile=root/'war_engine/presentation/map_view.gd';s=pfile.read_text();s=s.replace('var c=engine.cell(i);return Vector2(c.x*1.5*R,(c.y+0.5*(c.x&1))*sqrt(3.0)*R)','var c=engine.cell(i);var y=(c.y+0.5*(c.x&1))*sqrt(3.0)*R\n\tif engine.pack.map.get("north_left",false):y=(engine.height-0.5)*sqrt(3.0)*R-y\n\treturn Vector2(c.x*1.5*R,y)',1)
s=s.replace('var w=(p-size/2)/zoom+focus;var q=', 'var w=(p-size/2)/zoom+focus\n\tif engine.pack.map.get("north_left",false):w.y=(engine.height-0.5)*sqrt(3.0)*R-w.y\n\tvar q=',1)
s=s.replace('var limit=world(engine.width*engine.height-1)','var limit=Vector2((engine.width-1)*1.5*R,(engine.height-0.5)*sqrt(3.0)*R)',1)
marker='\tif selected>=0 and engine.alive(selected) and (not engine.fog_enabled()'
pos=s.index(marker)
s=s[:pos]+'''\t# River boundaries are public map information. One permanent road bridge; no repairs.
	for edge in engine.pack.map.get("river_edges",[]):
		var a=screen(int(edge.a));var b=screen(int(edge.b));var middle=(a+b)/2
		var normal=(b-a).normalized();var tangent=Vector2(-normal.y,normal.x)*R*zoom/2
		draw_line(middle-tangent,middle+tangent,Color("5792a5"),5*zoom,true)
		if edge.bridge:
			draw_line(middle-normal*14*zoom,middle+normal*14*zoom,Color("ede2bb"),10*zoom,true)
			for sign in [-1,1]:
				var shift=tangent.normalized()*sign*5*zoom
				draw_line(middle-normal*15*zoom+shift,middle+normal*15*zoom+shift,Color("6c5942"),2*zoom,true)
	for location in engine.pack.map.get("labels",[]):
		var c=location.cell;var p=screen(engine.index(Vector2i(int(c[0]),int(c[1]))))+Vector2(0,-38)*zoom
		draw_string_outline(font,p,location.text,HORIZONTAL_ALIGNMENT_CENTER,100*zoom,int(16*zoom),3,Color("ece7d1"))
		draw_string(font,p,location.text,HORIZONTAL_ALIGNMENT_CENTER,100*zoom,int(16*zoom),Color("435749"))
''' +s[pos:]
s=s.replace('texts.north,HORIZONTAL_ALIGNMENT_CENTER','("← N" if engine.pack.map.get("north_left",false) else "N"),HORIZONTAL_ALIGNMENT_CENTER',1)
pfile.write_text(s)
for name in ['project.godot','export_presets.cfg']:
 f=root/name;s=f.read_text().replace('0.8.13','0.8.14').replace('version/code=26','version/code=27');f.write_text(s)
print('Sauer v1 pack ready')

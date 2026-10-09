from pathlib import Path
import json
root=Path(__file__).resolve().parents[1]/'packs/1870'
for name in ['regimental_trial','prototype','three_objectives']:
    data=json.loads((root/(name+'.json')).read_text())
    old=json.loads((root/('legacy0831_'+name+'.json')).read_text())
    expected=[old['terrains'][t].get('visual_type',t) for t in old['map']['tiles']]
    expected=['plain' if t in ['hill','meadow'] else t for t in expected]
    assert data['map']['tiles']==expected
    assert data['map']['show_relief'] is False
    assert not any(t.startswith('height_') or t=='hill' for t in data['map']['tiles'])
    for key in ['river_edges','road_edges','road_exits','labels']:
        assert data['map'].get(key)==old['map'].get(key)
    assert data['weapons']==old['weapons']
    print(name+': terrains restaurés, routes/ponts/armes inchangés')

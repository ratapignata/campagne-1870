"""Original vector UI skins: small reusable nine-patch sources, no game data."""
from pathlib import Path
out = Path(__file__).resolve().parents[2] / 'assets' / 'graphics2d2' / 'ui'
out.mkdir(parents=True, exist_ok=True)
for primary in (False, True):
    for state in ('normal', 'hover', 'pressed', 'disabled'):
        if primary:
            colors = {'normal':('#f2d18c','#d3a75c','#b5823c'), 'hover':('#ffe5a7','#e5b96c','#c5944c'),
                      'pressed':('#b5813c','#c69750','#d1a45f'),'disabled':('#20373a','#122a2e','#10252a')}
        else:
            colors = {'normal':('#233e45','#102a32','#0b2128'),'hover':('#34565b','#1c3d44','#17343b'),
                      'pressed':('#0a2028','#122e36','#1a353c'),'disabled':('#14292e','#0b1f25','#091a20')}
        top,mid,bottom=colors[state]
        edge = '#cda45e' if primary and state != 'disabled' else '#4b696b'
        light = '#fff0c7' if primary and state != 'disabled' else '#a5c1ba'
        svg=f'''<svg xmlns="http://www.w3.org/2000/svg" width="96" height="48" viewBox="0 0 96 48">
<defs><linearGradient id="g" x2="0" y2="1"><stop stop-color="{top}"/><stop offset=".48" stop-color="{mid}"/><stop offset="1" stop-color="{bottom}"/></linearGradient></defs>
<rect x=".6" y=".6" width="94.8" height="46.8" rx="5" fill="url(#g)" stroke="{edge}" stroke-width="1.2"/>
<path d="M7 2.3H89" stroke="{light}" stroke-opacity=".38" stroke-width="1"/>
<path d="M7 45.8H89" stroke="#000b10" stroke-opacity=".45" stroke-width="1"/>
<path d="M3 8V40" stroke="{light}" stroke-opacity=".10" stroke-width="1"/>
</svg>'''
        (out / (('gold_' if primary else 'dark_')+state+'.svg')).write_text(svg)
for kind in ('band','card'):
    top,mid,bottom = ('#17343c','#0d252d','#091c24') if kind=='band' else ('#15323a','#10292f','#0b2229')
    radius=0 if kind=='band' else 4
    svg=f'''<svg xmlns="http://www.w3.org/2000/svg" width="96" height="64" viewBox="0 0 96 64">
<defs><linearGradient id="g" x2="0" y2="1"><stop stop-color="{top}"/><stop offset=".4" stop-color="{mid}"/><stop offset="1" stop-color="{bottom}"/></linearGradient></defs>
<rect x=".5" y=".5" width="95" height="63" rx="{radius}" fill="url(#g)" stroke="#7d754f" stroke-opacity=".32"/>
<path d="M5 2H91M2 5V59" fill="none" stroke="#afc1b7" stroke-opacity=".12"/>
<path d="M5 61.5H91" stroke="#000b12" stroke-opacity=".7"/>
</svg>'''
    (out / (kind+'.svg')).write_text(svg)
print('10 original UI skins written')

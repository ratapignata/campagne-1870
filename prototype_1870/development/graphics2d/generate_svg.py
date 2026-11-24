"""Original deterministic 2D artwork; Python standard library only.
Run from the project root, then run build_atlas.gd with Godot 4.5.1.
"""
from pathlib import Path
import random,json,math
ROOT=Path(__file__).resolve().parent;NAMES=[]
HEX='136,59 102,118 34,118 0,59 34,0 102,0'
def save(name,body,base=None):
 NAMES.append(name)
 defs='''<defs><clipPath id="hex"><polygon points="'''+HEX+'''"/></clipPath>
 <linearGradient id="paper" x1="0" y1="0" x2="1" y2="1"><stop stop-color="#fff4ce" stop-opacity=".18"/><stop offset=".5" stop-color="#f7e7bc" stop-opacity="0"/><stop offset="1" stop-color="#706445" stop-opacity=".09"/></linearGradient>
 <linearGradient id="leaf" x1="0" y1="0" x2="1" y2="1"><stop stop-color="#8e9f6c"/><stop offset=".55" stop-color="#6e8858"/><stop offset="1" stop-color="#506e49"/></linearGradient>
 <linearGradient id="leaf2" x1="0" y1="0" x2="1" y2="1"><stop stop-color="#a2ad78"/><stop offset=".55" stop-color="#84945e"/><stop offset="1" stop-color="#607c50"/></linearGradient></defs>'''
 ground=f'<polygon points="{HEX}" fill="{base}"/>' if base else ''
 svg=f'<svg xmlns="http://www.w3.org/2000/svg" width="204" height="177" viewBox="0 0 136 118">{defs}<g clip-path="url(#hex)">{ground}{body}</g></svg>'
 (ROOT/'svg'/f'{name}.svg').write_text(svg)
def ground(name,base,seed,kind):
 r=random.Random(seed);s=''
 if kind=='cultivated':
  for x,y,w,h,col in [(-6,4,77,55,'#e6d19d'),(58,58,91,70,'#b8b07e'),(-16,67,80,60,'#ceb780')]:
   s+=f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="{col}" opacity=".34" transform="rotate(-12 68 59)"/>'
  for y in range(7,132,7):s+=f'<path d="M-15 {y} L155 {y-30}" fill="none" stroke="#826b43" stroke-width=".65" opacity=".17"/>'
  s+='<path d="M-5 68 L137 38 M58 -2 L84 124" stroke="#86784b" stroke-width="1.1" opacity=".2"/>'
 elif kind=='hill':
  for x in range(3):s+=f'<path d="M-10 {100-x*18} Q68 {14-x*6} 152 {80-x*15}" fill="none" stroke="#f5e2b9" stroke-width="{11-x*2}" opacity=".15"/>'
 elif kind=='water':
  for i in range(12):
   x=r.randrange(4,110);y=r.randrange(6,108);s+=f'<path d="M{x} {y} q6 -2 15 0" stroke="#d2e4d9" opacity=".26" stroke-width="1.1" fill="none"/>'
 else:
  s+='<path d="M-4 50 Q35 20 73 42 T146 37 L146 98 Q70 83 -4 105Z" fill="#acb98b" opacity=".1"/>'
 for i in range(90 if kind=='cultivated' else 65):
  x=r.randrange(1,135);y=r.randrange(1,117);s+=f'<path d="M{x} {y} l{r.choice([1,2,3])} {r.choice([-1,0,1])}" stroke="{r.choice(["#6e8259","#f6e8c5","#9b8b58"])}" opacity=".18" stroke-width=".7"/>'
 s+=f'<polygon points="{HEX}" fill="url(#paper)"/>'
 save(name,s,base)
for kind,base,count in [('plain','#dcd4b4',4),('cultivated','#cbbb8e',4),('meadow','#c6cba6',3),('hill','#c8bd97',2),('forest_ground','#a6b38c',1),('village_ground','#d7c6a2',1),('road','#dcd1b0',1),('water','#86aeb7',1),('bridge','#b9bea3',1)]:
 for v in range(count):ground(f'{kind}_{v}',base,187000+len(NAMES)*37,kind)
def crown(x,y,r,variant):
 rng=random.Random(int(x*37+y*61+r*97));pts=[];count=17
 for j in range(count):
  a=j*math.tau/count;radius=r*rng.uniform(.72,1.10);pts.append((x+math.cos(a)*radius,y+math.sin(a)*radius*.88))
 mids=[((pts[j][0]+pts[(j+1)%count][0])/2,(pts[j][1]+pts[(j+1)%count][1])/2) for j in range(count)]
 path=f'M{mids[-1][0]:.2f} {mids[-1][1]:.2f}'
 for point,mid in zip(pts,mids):path+=f' Q{point[0]:.2f} {point[1]:.2f} {mid[0]:.2f} {mid[1]:.2f}'
 body=f'<ellipse cx="{x+2}" cy="{y+6}" rx="{r*.98}" ry="{r*.7}" fill="#344b35" opacity=".14"/><path d="M{x} {y+4} l1 14" stroke="#776747" stroke-width="1.7"/><path d="{path}Z" fill="url(#{"leaf2" if variant else "leaf"})" stroke="#59734e" stroke-width=".55"/>'
 for j in range(15):
  xx=x+rng.uniform(-.64,.64)*r;yy=y+rng.uniform(-.52,.52)*r
  body+=f'<path d="M{xx:.2f} {yy:.2f} q1.7 -2.2 4.1 -.5" stroke="{rng.choice(["#c5c593","#435f42","#a9b17d"])}" opacity=".26" stroke-width="1.25" fill="none"/>'
 return body
for v in range(4):
 for gap in [False,True]:
  r=random.Random(701+v);positions=[(38,28),(75,25),(102,44),(29,63),(65,58),(91,84),(50,91)]
  if gap:positions=[(35,25),(77,23),(108,46),(23,62),(92,92),(46,98)]
  s=''
  for j,(x,y) in enumerate(positions):s+=crown(x+r.randrange(-4,5),y+r.randrange(-4,5),r.randrange(15,20),j%2)
  save(f'forest_{v}'+('_road' if gap else ''),s)
for v in range(3):
 s='<path d="M26 73 Q61 48 109 72" stroke="#ad9a75" opacity=".5" stroke-width="5" fill="none"/>'
 for j,(x,y) in enumerate([(42,39),(91,32),(30,73),(87,83)]):
  x+=(v-1)*2;w=25 if j%2 else 29;h=15;roof=['#9d6550','#8a6652','#a77854'][(j+v)%3]
  s+=f'<ellipse cx="{x+3}" cy="{y+15}" rx="{w*.7}" ry="6" fill="#68583e" opacity=".16"/><path d="M{x-w/2} {y} h{w} v{h} h-{w}Z" fill="#ede0c1" stroke="#8b7959" stroke-width=".9"/>'
  s+=f'<path d="M{x-w/2-3} {y+1} L{x-2} {y-12} L{x+w/2+3} {y+1}Z" fill="{roof}" stroke="#6f5344" stroke-width="1"/><path d="M{x-2} {y-11} L{x+w/2+1} {y}" stroke="#d3a37b" stroke-width="1.3"/>'
  s+=f'<rect x="{x+5}" y="{y-12}" width="3" height="8" fill="#8d6f57"/><rect x="{x-2}" y="{y+6}" width="4" height="9" fill="#76664d"/>'
  for dx in [-8,6]:s+=f'<rect x="{x+dx}" y="{y+4}" width="3" height="4" fill="#5b7273" stroke="#f5ebd2" stroke-width=".7"/>'
 save(f'village_{v}',s)
(ROOT/'atlas_manifest.json').write_text(json.dumps({'names':NAMES,'cell':[220,193],'padding':8,'sprite':[204,177],'columns':6,'size':[1320,965]},indent=2)+'\n')
print('SVG resources:',len(NAMES))

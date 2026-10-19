from pathlib import Path
import math
from fontTools.ttLib import TTFont
from fontTools.pens.svgPathPen import SVGPathPen
font=TTFont('prototype_1870/assets/fonts/DejaVuSerif-Bold.ttf');glyphs=font.getGlyphSet();cmap=font.getBestCmap();upm=font['head'].unitsPerEm

def lettering(text,cx,y,height,color='#e5c683',tracking=0):
 scale=height/upm;width=sum(font['hmtx'][cmap[ord(c)]][0] for c in text)*scale+max(0,len(text)-1)*tracking
 x=cx-width/2;out=[]
 for c in text:
  name=cmap[ord(c)];pen=SVGPathPen(glyphs);glyphs[name].draw(pen)
  out.append(f'<path d="{pen.getCommands()}" transform="translate({x:.3f},{y}) scale({scale}, {-scale})" fill="{color}"/>')
  x+=font['hmtx'][name][0]*scale+tracking
 return ''.join(out)
def flag(x,y,w,h,french):
 def transform(u,v):return f'{x+u*w:.2f},{y+v*h+math.sin(u*math.pi*2)*h*.065:.2f}'
 parts=[]
 for k,color in enumerate(['#204979','#f4ebd5','#a63b43'] if french else ['#202427','#eee8d7','#a43840']):
  if french:
   points=[transform(k/3+i/3/16,0) for i in range(17)]+[transform((k+1)/3-i/3/16,1) for i in range(17)]
  else:
   points=[transform(i/32,k/3) for i in range(33)]+[transform(1-i/32,(k+1)/3) for i in range(33)]
  parts.append(f'<polygon points="{" ".join(points)}" fill="{color}"/>')
 outline=[transform(i/32,0) for i in range(33)]+[transform(1-i/32,1) for i in range(33)]
 parts.append(f'<polygon points="{" ".join(outline)}" fill="none" stroke="#b49a64" stroke-width="2"/>')
 for u in [.29,.64]:parts.append(f'<path d="M{x+u*w},{y} Q{x+(u+.045)*w},{y+h/2} {x+u*w},{y+h}" fill="none" stroke="#000" stroke-opacity=".13" stroke-width="{w*.028}"/>')
 return ''.join(parts)

root=Path('prototype_1870/assets')
body='<rect x="4" y="4" width="1016" height="312" rx="24" fill="#d9d4bf" stroke="#786542" stroke-width="3"/><rect x="15" y="15" width="994" height="290" rx="16" fill="none" stroke="#aa9460"/>'
body+='<path d="M225 75 L660 291 M799 75 L364 291" stroke="#6d573c" stroke-width="7"/><path d="M225 75 L660 291 M799 75 L364 291" stroke="#cfb273" stroke-width="2"/>'
body+='<g transform="rotate(-18 174 158)">'+flag(44,88,260,148,True)+'</g><g transform="rotate(18 850 158)">'+flag(720,88,260,148,False)+'</g>'
body+='<path d="M332 47 H692 L713 257 Q512 313 311 257Z" fill="#e3dcc5" stroke="#86714c" stroke-width="2"/>'
body+=lettering('CAMPAGNE',514,109,39,'#665034',tracking=2)+lettering('1870',514,241,134,'#665034')
body+=lettering('CAMPAGNE',512,106,39,'#ac7d27',tracking=2)+lettering('1870',512,238,134,'#ac7d27')
(root/'logo.svg').write_text('<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="320" viewBox="0 0 1024 320">'+body+'</svg>')
icon='<rect x="8" y="8" width="496" height="496" rx="78" fill="#d8d2ba" stroke="#8b754b" stroke-width="10"/><path d="M85 126 L386 410 M427 126 L126 410" stroke="#75603f" stroke-width="7"/>'
icon+='<g transform="rotate(-22 123 183)">'+flag(39,114,168,146,True)+'</g><g transform="rotate(22 389 183)">'+flag(305,114,168,146,False)+'</g>'
icon+='<path d="M101 274 H411 V389 Q256 433 101 389Z" fill="#e3dcc5" stroke="#89724c" stroke-width="2"/>'
icon+=lettering('CAMPAGNE',256,311,31,'#705334',tracking=1)+lettering('1870',256,387,85,'#92661e')
Path('prototype_1870/icon.svg').write_text('<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">'+icon+'</svg>')

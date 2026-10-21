from pathlib import Path
import json,os,math
os.environ['MPLCONFIGDIR']='/workspace/v43_audit/runtime/matplotlib'
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import RegularPolygon
from matplotlib.lines import Line2D
b=Path('/workspace/v43_audit');pack=json.loads((b/'diagnostic/packs/1870/regimental_trial_v43.json').read_text());trace=json.loads(next((b/'results/full/data').rglob('trace_T12_A0986.json')).read_text());state=trace['state'];analysis=json.loads(next((b/'results/windows_t12/data').rglob('windows_analysis.json')).read_text());inactive={u['id'] for u in analysis['units'] if u['turn']==12 and not u['actions']}
def xy(cell):
 x,y=cell;return 1.5*x,(19.5-y-0.5*(x%2))*math.sqrt(3)
def cellxy(i):return xy([i%30,i//30])
fig,ax=plt.subplots(figsize=(16,11));fig.patch.set_facecolor('#faf7ed');ax.set_facecolor('#faf7ed')
colors={'plain':'#f5f1df','forest':'#dce7d4','woods':'#dce7d4','village':'#eddfd0','road':'#efe8d3','height':'#e8e0cb','hill':'#e8e0cb','water':'#deecf3'}
for i,t in enumerate(pack['map']['tiles']):ax.add_patch(RegularPolygon(cellxy(i),6,radius=.99,orientation=math.pi/6,facecolor=colors.get(t,'#ece8d9'),edgecolor='#d0cbbd',linewidth=.35))
for edge in pack['map']['river_edges']:
 a=cellxy(edge['a']);c=cellxy(edge['b']);dx,dy=c[0]-a[0],c[1]-a[1];norm=math.hypot(dx,dy);vx,vy=-dy/norm*.52,dx/norm*.52;mx,my=(a[0]+c[0])/2,(a[1]+c[1])/2
 bridge=edge.get('bridge',False) or edge.get('bridge_from_turn',99)<=12
 ax.plot([mx-vx,mx+vx],[my-vy,my+vy],color='#826d50' if bridge else '#4e91ab',linewidth=3 if bridge else 2,zorder=2)
for u in state['units']:
 if u['strength']<=0:continue
 x,y=xy(u['cell']);kind=pack['weapons'][u['weapon']].get('unit_type','infantry');arty=pack['weapons'][u['weapon']].get('requires_deployment',False)
 marker='^' if arty else 's' if kind=='hq' else 'D' if kind=='cavalry' else 'o';side=int(u['side']);edge='#e4ab20' if u['id'] in inactive else 'white'
 ax.scatter([x],[y],s=88 if u['id'] in inactive else 65,c=['#ad4d46' if side==0 else '#344e64'],marker=marker,edgecolors=edge,linewidths=2.2 if u['id'] in inactive else .7,zorder=4)
for goal in pack['objectives']:
 x,y=xy(goal['cell']);ax.scatter([x],[y],s=260,facecolors='none',edgecolors='#896a1d',linewidths=2,zorder=5)
 owner='PR' if state['objective_owners'][goal['id']]==1 else 'FR'
 ax.annotate(f"{goal['id'].capitalize()} ({goal['points']}) · {owner}",(x,y),xytext=(12,8),textcoords='offset points',fontsize=10,weight='bold',color='#604c24',zorder=6)
ax.annotate('N',xy=(1,32),xytext=(5,32),arrowprops={'arrowstyle':'->','color':'#444'},va='center',color='#444')
ax.set_aspect('equal');ax.set_xlim(-1.4,45);ax.set_ylim(-1.2,35);ax.axis('off')
ax.set_title('Diagnostic V43 — fin de la phase prussienne du tour 12\nSimulation chronologique, graine 430012 · Difficile · défense française mobile de test',loc='left',fontsize=16,pad=20)
legend=[Line2D([],[],marker='o',linestyle='',markerfacecolor='#ad4d46',markeredgecolor='white',markersize=9,label='Français'),Line2D([],[],marker='o',linestyle='',markerfacecolor='#344e64',markeredgecolor='white',markersize=9,label='Allemands'),Line2D([],[],marker='o',linestyle='',markerfacecolor='#344e64',markeredgecolor='#e4ab20',markeredgewidth=2,markersize=9,label='Allemand sans commande pendant la phase'),Line2D([],[],marker='^',color='#344e64',linestyle='',markersize=9,label='Artillerie'),Line2D([],[],marker='s',color='#344e64',linestyle='',markersize=9,label='QG'),Line2D([],[],marker='D',color='#344e64',linestyle='',markersize=8,label='Cavalerie')]
ax.legend(handles=legend,loc='upper right',framealpha=.9,fontsize=10)
fig.text(.09,.045,'Vue complète pour audit, brouillard levé dans ce graphique uniquement. Ce n’est pas la partie Android du joueur.\n17 unités sans commande ; 7 unités mobiles ; 106,25 PA restants. Elsasshausen et Niederwald sont prussiens, Frœschwiller française.',fontsize=10,color='#444')
fig.savefig(b/'report/simulation_T12.png',dpi=170,bbox_inches='tight');plt.close(fig)
print('T12 diagnostic map saved')

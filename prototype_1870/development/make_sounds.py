"""Build compact effects from two CC0 recordings; see assets/sounds/CREDITS.txt."""
from pathlib import Path
import subprocess, tempfile, wave
import numpy as np
RATE=44100
BASE=Path(__file__).resolve().parent
OUT=BASE.parent/'assets/sounds'
def read(name):
 with tempfile.TemporaryDirectory() as d:
  p=Path(d)/'decoded.wav'
  subprocess.run(['ffmpeg','-v','error','-i',str(BASE/'audio_sources'/name),'-ar',str(RATE),'-ac','1',str(p)],check=True)
  with wave.open(str(p)) as w:return np.frombuffer(w.readframes(w.getnframes()),dtype='<i2').astype(float)/32768

def fade(x,tail=.14):
 x=x.copy();x-=x.mean();n=min(len(x),int(tail*RATE));x[-n:]*=np.linspace(1,0,n);x[:44]*=np.linspace(0,1,44)
 return x

def write(name,x):
 x=fade(x);x*=.82/max(abs(x).max(),.001)
 with wave.open(str(OUT/name),'wb') as w:
  w.setnchannels(1);w.setsampwidth(2);w.setframerate(RATE);w.writeframes((x*32767).astype('<i2').tobytes())
 print(name,round(len(x)/RATE,2),'s',round(float(np.sqrt(np.mean(x*x))),3),'RMS')

musket=read('musket.mp3');sample=fade(musket[int(.698*RATE):int(1.27*RATE)])
for name,onsets in [('rifle.wav',[0,.063,.119,.218,.305]),('rifle_alt.wav',[0,.041,.132,.201,.286])]:
 x=np.zeros(int(.9*RATE))
 for onset,gain in zip(onsets,[1,.78,.88,.68,.59]):
  k=int(onset*RATE);n=min(len(sample),len(x)-k);x[k:k+n]+=sample[:n]*gain
 write(name,x)
cannon=read('cannon.mp3')
for name,start in [('cannon.wav',.14),('cannon_alt.wav',6.31)]:write(name,fade(cannon[int(start*RATE):int((start+1.4)*RATE)],.35))

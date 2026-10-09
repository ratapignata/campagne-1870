"""Reproducible CC0 ambience edits; see assets/sounds/CREDITS.txt."""
from pathlib import Path
import numpy as np, subprocess, wave, tempfile
R=Path(__file__).resolve().parent;S=R/'audio_sources';O=R.parent/'assets/sounds';RATE=44100

def read(name):
 raw=subprocess.check_output(['ffmpeg','-v','error','-i',str(S/name),'-f','f32le','-ac','1','-ar',str(RATE),'-'])
 return np.frombuffer(raw,dtype='<f4').astype(float)
def norm(x,peak):return x*peak/max(.001,abs(x).max())
cry=read('charge.mp3');steps=read('steps.mp3');N=int(1.15*RATE)
# Short group cry with two offset footstep layers, no weapon report mixed in.
a=norm(cry[int(.25*RATE):int(.25*RATE)+N],.55)
b=norm(steps[int(3*RATE):int(3*RATE)+N],.25)
c=norm(steps[int(3.16*RATE):int(3.16*RATE)+N],.18)
x=norm(a+b+c,.78);x[:int(.02*RATE)]*=np.linspace(0,1,int(.02*RATE));x[-int(.25*RATE):]*=np.linspace(1,0,int(.25*RATE))
with wave.open(str(O/'assault.wav'),'wb') as w:w.setnchannels(1);w.setsampwidth(2);w.setframerate(RATE);w.writeframes((x*32767).astype('<i2').tobytes())
subprocess.run(['ffmpeg','-v','error','-y','-i',str(S/'music.mp3'),'-af','afade=t=in:st=0:d=2,afade=t=out:st=80:d=4','-c:a','libvorbis','-q:a','3',str(O/'slow_world.ogg')],check=True)
print('Assault: 1.15s, peak',round(abs(x).max(),3),'Music: full 84s with fades')

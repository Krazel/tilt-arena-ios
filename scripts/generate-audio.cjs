// Original synthesized demo score and cues. No original Tilt to Live audio.
const fs=require('node:fs'),path=require('node:path');
const rate=22050,out=path.join(__dirname,'../native-ios/Resources');
let seed=98317;
const noise=()=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed/4294967296*2-1;};
function write(name,seconds,sample){
  const n=Math.round(seconds*rate),b=Buffer.alloc(44+n*2);
  b.write('RIFF',0);b.writeUInt32LE(b.length-8,4);b.write('WAVEfmt ',8);b.writeUInt32LE(16,16);
  b.writeUInt16LE(1,20);b.writeUInt16LE(1,22);b.writeUInt32LE(rate,24);b.writeUInt32LE(rate*2,28);
  b.writeUInt16LE(2,32);b.writeUInt16LE(16,34);b.write('data',36);b.writeUInt32LE(n*2,40);
  for(let i=0;i<n;i++){const value=Math.max(-0.95,Math.min(0.95,sample(i/rate,i)));
    b.writeInt16LE(Math.round(value*32767),44+i*2);}
  fs.writeFileSync(path.join(out,name+'.wav'),b);
}
const sin=(f,t)=>Math.sin(2*Math.PI*f*t),beat=60/132;
const notes=[110,138.591,164.814,185,164.814,138.591,123.471,103.826];
write('classic-loop',beat*16,t=>{
  const tick=Math.floor(t/(beat/2)),q=t%(beat/2),bt=t%beat;
  const bass=sin(notes[Math.floor(t/beat)%8],q)*Math.exp(-q*11)*0.24;
  const pluck=(sin(notes[tick%8]*4,q)+sin(notes[tick%8]*8,q)*0.3)*Math.exp(-q*35)*0.08;
  const kick=sin(65+70*Math.exp(-bt*40),bt)*Math.exp(-bt*25)*0.27;
  const snare=Math.floor(t/beat)%2 ? noise()*Math.exp(-bt*40)*0.16 : 0;
  const hat=noise()*Math.exp(-q*120)*0.08;
  const edge=Math.min(1,t*100,(beat*16-t)*100);
  return (bass+pluck+kick+snare+hat)*edge;
});
write('pickup',0.18,t=>sin(540+t*2300,t)*Math.sin(Math.PI*t/0.18)*0.3);
write('hit',0.065,t=>(sin(170-t*900,t)*0.2+noise()*0.15)*Math.exp(-t*65));
write('death',0.5,t=>(sin(180-t*260,t)*0.3+noise()*0.12)*Math.exp(-t*7));
console.log('Generated 4 original PCM WAV assets at 22050 Hz.');

// Original, deterministic synthesis. No recordings or external source material.
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
const root=path.join(__dirname,'..'),dest=path.join(root,'native-ios/Resources'),rate=44100;
let seed=581;const noise=()=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed/2147483648-1;};
const sin=(f,t)=>Math.sin(2*Math.PI*f*t),env=(t,d,a=.008)=>Math.min(1,t/a)*Math.min(1,(d-t)/.035);
const catalog=JSON.parse(fs.readFileSync(path.join(dest,'audio-approved.json')));
const specs={
 pickup:[.28,.72,(t)=>env(t,.28)*(sin(523.25,t)*Math.exp(-t*16)+.3*sin(783.99,t)*Math.exp(-t*20))*.45],
 hit:[.15,.7,(t)=>env(t,.15,.002)*(sin(190,t)*.34+sin(380,t)*.13+noise()*.13)*Math.exp(-t*22)],
 nuke:[.8,.7,(t)=>env(t,.8,.004)*(sin(58+35*Math.exp(-t*15),t)*.36+sin(107,t)*.12+noise()*.2)*Math.exp(-t*5)],
 frost:[.72,.65,(t)=>env(t,.72,.016)*(sin(880,t)*.2+sin(1320,t)*.12+sin(1760,t)*.06+noise()*.025)*Math.exp(-t*4.5)],
 wave:[.32,.6,(t)=>env(t,.32,.01)*(noise()*.18+sin(320-200*t,t)*.28)*Math.sin(Math.PI*t/.32)],
 missiles:[.26,.55,(t)=>env(t,.26)*(noise()*.17+sin(260+500*t,t)*.22)*Math.exp(-t*7)],
 bubble:[.3,.5,(t)=>env(t,.3)*(sin(660,t)*.23+sin(990,t)*.15)*Math.exp(-t*10)],
 spikes:[.22,.5,(t)=>env(t,.22,.003)*(sin(410,t)*.24+sin(870,t)*.08)*Math.exp(-t*12)],
 // Integer cycles per half-second keep the sustained laser loop seamless.
 laser:[.5,.48,(t)=>(sin(180,t)*.2+sin(360,t)*.09+sin(720,t)*.035)*(.85+.15*Math.cos(2*Math.PI*8*t))]
};
for(const [name,[duration,volume,sample]]of Object.entries(specs)){
 const n=Math.round(rate*duration),b=Buffer.alloc(44+n*2);b.write('RIFF');b.writeUInt32LE(b.length-8,4);b.write('WAVEfmt ',8);b.writeUInt32LE(16,16);b.writeUInt16LE(1,20);b.writeUInt16LE(1,22);b.writeUInt32LE(rate,24);b.writeUInt32LE(rate*2,28);b.writeUInt16LE(2,32);b.writeUInt16LE(16,34);b.write('data',36);b.writeUInt32LE(n*2,40);
 for(let i=0;i<n;i++)b.writeInt16LE(Math.round(Math.max(-.95,Math.min(.95,sample(i/rate)))*32767),44+i*2);
 const file='audio-'+name+'.wav';fs.writeFileSync(path.join(dest,file),b);
 catalog.assets[name]={file,volume,proposal:'original-v058-'+name,author:'Krazel Games',source:'Original synthesis: scripts/refresh-audio-v058.cjs',license:'Original project audio',changes:'Synthesized PCM, soft attack/release; continuous phase for laser.',sha256:crypto.createHash('sha256').update(b).digest('hex')};
}
catalog.version=2;catalog.silent=['death','warning','combo'];
fs.writeFileSync(path.join(dest,'audio-approved.json'),JSON.stringify(catalog,null,2)+'\n');
const file=path.join(dest,'Audio-Credits.txt'),credits=fs.readFileSync(file,'utf8');
if(!credits.includes('Original synthesized effects'))fs.appendFileSync(file,'\nOriginal synthesized effects — Krazel Games: orb pickup, enemy hit, explosion, ice, wave, missiles, shield, spikes, laser.\n');
console.log('Updated nine cues; music and UI click preserved.');

const {test}=require('node:test'),assert=require('node:assert/strict');
const catalog=require('../native-ios/Resources/audio-approved.json');
test('bubble deaths vary all five pitches across overlapping voices; rate limit, pause, mute and frozen routing survive',async()=>{
 const {GameSound,soundCues}=await import('../play/sound.js');let now=0,random=0;const players={};
 const sound=new GameSound(catalog,file=>players[file]={currentTime:0,paused:true,plays:0,play(){this.paused=false;this.plays++;return Promise.resolve()},pause(){this.paused=true},addEventListener(){}},()=>now,()=>random);
 const keys=['hit',...catalog.assets.hit.alternates];assert.equal(keys.length,6);
 const files=keys.flatMap(k=>[catalog.assets[k].file,...catalog.assets[k].pitchVariants.map(v=>v.file)]),voices=files.map(f=>players[f]);
 const total=()=>voices.reduce((n,p)=>n+p.plays,0);
 let previous,first;const used=new Set();sound.setMuted(false);sound.startRun();players[catalog.assets['music-a'].file].currentTime=42;
 for(let i=0;i<18;i++){
  now=i*.071;random=[0,0,.999,.999,.5,.5][i%6];const before=voices.map(p=>p.plays);sound.play('hit');
  const changed=voices.map((p,j)=>p.plays>before[j]?j:-1).filter(j=>j>=0);assert.equal(changed.length,1);
  const pitch=changed[0]%5;assert.notEqual(pitch,previous);previous=pitch;used.add(pitch);
  if(i===0){first=voices[changed[0]];first.currentTime=.01;}if(i===5){assert.equal(first.currentTime,.01);assert(!first.paused);}
  sound.play('hit');assert.equal(total(),i+1);
 }
 assert.equal(used.size,5);const active=voices.filter(p=>!p.paused);
 sound.setMode('paused');assert(voices.every(p=>p.paused));sound.setMode('game');assert(active.every(p=>!p.paused));
 assert.equal(players[catalog.assets['music-a'].file].currentTime,42);
 sound.setMuted(true);now=3;const before=total();sound.play('hit');assert.equal(total(),before);assert(voices.every(p=>p.paused&&p.currentTime===0));
 sound.setMuted(false);sound.setMode('menu');sound.play('hit');assert.equal(total(),before);
 assert.deepEqual(soundCues([{kind:'kill',frozen:true}]),['shatter']);
 assert.deepEqual(soundCues(Array(20).fill({kind:'kill'})),['hit']);
});

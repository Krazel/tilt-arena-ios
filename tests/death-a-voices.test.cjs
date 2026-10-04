const {test}=require('node:test'),assert=require('node:assert/strict');
const catalog=require('../native-ios/Resources/audio-approved.json');
test('death A retains rapid-kill tails, rate limit, pause, mute and unchanged frozen routing',async()=>{
 const {GameSound,soundCues}=await import('../play/sound.js');let now=0;const players={};
 const sound=new GameSound(catalog,file=>players[file]={currentTime:0,paused:true,plays:0,play(){this.paused=false;this.plays++;return Promise.resolve()},pause(){this.paused=true},addEventListener(){}},()=>now);
 const keys=['hit',...catalog.assets.hit.alternates],voices=keys.map(k=>players[catalog.assets[k].file]);
 const total=()=>voices.reduce((n,p)=>n+p.plays,0);
 sound.setMuted(false);sound.startRun();
 for(let i=0;i<4;i++){now=i*.071;sound.play('hit');voices[i].currentTime=.01;}
 assert.deepEqual(voices.map(p=>p.plays),[1,1,1,1]);assert.equal(voices[0].currentTime,.01);
 sound.play('hit');assert.equal(total(),4);
 now=.284;sound.play('hit');assert.deepEqual(voices.map(p=>p.plays),[2,1,1,1]);
 sound.setMode('paused');assert(voices.every(p=>p.paused));const before=total();sound.play('hit');assert.equal(total(),before);
 sound.setMode('game');assert(voices.every(p=>!p.paused));sound.setMuted(true);now=1;sound.play('hit');assert(voices.every(p=>p.paused&&p.currentTime===0));
 sound.setMuted(false);sound.setMode('menu');sound.play('hit');assert.equal(total(),before+4);
 sound.startRun();now=2;sound.play('hit');assert.equal(voices[0].plays,4);
 assert.deepEqual(soundCues([{kind:'kill',frozen:true}]),['shatter']);
 assert.deepEqual(soundCues(Array(20).fill({kind:'kill'})),['hit']);
});

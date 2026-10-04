const {test}=require('node:test'),assert=require('node:assert/strict'),fs=require('node:fs');
const catalog=JSON.parse(fs.readFileSync('native-ios/Resources/audio-approved.json'));
test('shield random pitch avoids consecutive repeats and respects pause, mute, single voice and music',async()=>{
 const {GameSound}=await import('../play/sound.js');let time=0,random=0;const voices={};
 const s=new GameSound(catalog,file=>voices[file]={currentTime:0,paused:true,pause(){this.paused=true},play(){this.paused=false;return Promise.resolve()},addEventListener(){}},()=>time,()=>random);
 const files=[catalog.assets.bubble.file,...catalog.assets.bubble.pitchVariants.map(v=>v.file)];
 s.setMuted(false);s.startRun();voices[catalog.assets['music-a'].file].currentTime=42;
 const selected=[];
 for(random of [0,0,.999,.999,.5,.5]){time++;s.play('bubble');const active=files.filter(f=>!voices[f].paused);assert.equal(active.length,1);selected.push(active[0]);assert.equal(voices[active[0]].volume,catalog.assets.bubble.volume);}
 for(let i=1;i<selected.length;i++)assert.notEqual(selected[i],selected[i-1]);
 const last=selected.at(-1);voices[last].currentTime=.2;s.setMode('paused');assert(files.every(f=>voices[f].paused));s.setMode('game');assert.equal(voices[last].currentTime,.2);assert(!voices[last].paused);
 s.setMuted(true);assert(files.every(f=>voices[f].paused));time++;s.play('bubble');assert(files.every(f=>voices[f].paused));
 assert.equal(voices[catalog.assets['music-a'].file].currentTime,42);assert(!Object.keys(s.pitchKeys).some(n=>n!=='bubble'&&!n.startsWith('hit')));
});
test('wave release cancels its charge and exiting cancels all pending effects',async()=>{
 const {GameSound}=await import('../play/sound.js');let time=0;const s=new GameSound(catalog,()=>({currentTime:0,paused:true,pause(){this.paused=true},play(){this.paused=false;return Promise.resolve()},addEventListener(){}}),()=>time);
 s.setMuted(false);s.startRun();s.play('wave-charge');assert(!s.players['wave-charge'].paused);time=.5;s.play('wave');assert(s.players['wave-charge'].paused);assert(!s.players.wave.paused);s.setMode('menu');assert(s.players.wave.paused);
});

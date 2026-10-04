const {test}=require('node:test'),assert=require('node:assert/strict');
const catalog=require('../native-ios/Resources/audio-approved.json');
async function setup(){
 const {GameSound}=await import('../play/sound.js');let now=0;const voices={};
 const sound=new GameSound(catalog,file=>voices[file]={paused:true,currentTime:0,plays:0,play(){this.paused=false;this.plays++;return Promise.resolve()},pause(){this.paused=true},addEventListener(){}},()=>now);
 sound.setMuted(false);sound.startRun();
 const keys=['spikes',...catalog.assets.spikes.deployment.alternates],players=keys.map(k=>voices[catalog.assets[k].file]);
 const frame=(time,events=[],state='running')=>{now=time;return{time,state,events,fields:[],player:{}}};
 const pickup=[{kind:'pickup',power:'spikes'}];return{sound,players,frame,pickup,total:()=>players.reduce((sum,p)=>sum+p.plays,0)};
}
test('spikes B plays eight full overlapping recordings at 120 ms, without double consumption',async()=>{
 const h=await setup();h.sound.consume(h.frame(0,h.pickup));assert.equal(h.total(),1);
 h.players[0].currentTime=.11;
 h.sound.consume(h.frame(.12));h.sound.consume(h.frame(.12));assert.equal(h.total(),2);assert.equal(h.players[0].currentTime,.11);
 h.sound.consume(h.frame(.24));assert.equal(h.players[0].currentTime,.11);assert.equal(h.total(),3);
 for(let beat=3;beat<8;beat++)h.sound.consume(h.frame(beat*.12));
 assert.deepEqual(h.players.map(p=>p.plays),[3,3,2]);h.sound.consume(h.frame(2));assert.equal(h.total(),8);
});
test('spikes deployment pauses with the game, mute/menu/death cancel future blades',async()=>{
 const h=await setup();h.sound.consume(h.frame(0,h.pickup));h.sound.setMode('paused');const count=h.total();
 h.sound.consume(h.frame(.12));assert.equal(h.total(),count);assert(h.players.every(p=>p.paused));
 h.sound.setMode('game');const resumed=h.total();h.sound.consume(h.frame(.12));assert.equal(h.total(),resumed+1);
 h.sound.setMuted(true);const muted=h.total();h.sound.setMuted(false);h.sound.consume(h.frame(.36));assert.equal(h.total(),muted);
 h.sound.consume(h.frame(1,h.pickup));h.sound.setMode('menu');const menu=h.total();h.sound.setMode('game');h.sound.consume(h.frame(1.3));assert.equal(h.total(),menu);
 h.sound.consume(h.frame(2,h.pickup));h.sound.consume(h.frame(2.1,[],'gameOver'));const dead=h.total();h.sound.consume(h.frame(2.5));assert.equal(h.total(),dead);
});
test('a stalled frame skips overdue blades; picking spikes again starts a single new deployment',async()=>{
 const h=await setup();h.sound.consume(h.frame(0,h.pickup));h.sound.consume(h.frame(.5));assert.equal(h.total(),2);
 h.sound.consume(h.frame(.51));assert.equal(h.total(),2);h.sound.consume(h.frame(.6));assert.equal(h.total(),3);
 h.sound.consume(h.frame(.7,h.pickup));const reset=h.total();h.sound.consume(h.frame(.72));assert.equal(h.total(),reset);
 h.sound.consume(h.frame(.82));assert.equal(h.total(),reset+1);
});

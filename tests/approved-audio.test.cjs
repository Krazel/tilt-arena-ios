const {test}=require('node:test'),assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
const {ClassicGame}=require('../native-ios/Resources/classic-core.js');
const resources=path.join(__dirname,'../native-ios/Resources');
const catalog=JSON.parse(fs.readFileSync(path.join(resources,'audio-approved.json')));
const modulePromise=import('../play/sound.js');
function harness(GameSound){let time=0;const players={};const sound=new GameSound(catalog,file=>{const p={currentTime:0,paused:true,plays:0,pause(){this.paused=true},play(){this.paused=false;this.plays++;return Promise.resolve()},addEventListener(name,fn){this[name]=fn}};players[file]=p;return p},()=>time);return{sound,players,advance:()=>{time+=1},p:name=>players[catalog.assets[name].file]};}
test('only selected files ship, with verified hashes, credits and half-second charges',()=>{
 const proposals=new Set(Object.values(catalog.assets).map(a=>a.proposal));
 assert.deepEqual([...proposals].sort(),['music-play-A','music-play-B','music-play-C','music-menu-A','click-A','vortex-A','lightning-A','burn-A','boomerang-A','shatter-A','shatter-B','bounce-B',...['pickup','hit','nuke','frost','wave','missiles','bubble','spikes','laser'].map(n=>'original-v058-'+n)].sort());
 for(const [name,a] of Object.entries(catalog.assets)){
  const b=fs.readFileSync(path.join(resources,a.file));assert.equal(crypto.createHash('sha256').update(b).digest('hex'),a.sha256);
  if(name.endsWith('-charge')){assert.equal(b.readUInt32LE(40)/(b.readUInt32LE(24)*2),.5);}
 }
 const credits=fs.readFileSync(path.join(resources,'Audio-Credits.txt'),'utf8');assert.match(credits,/PeriTune/);assert.match(credits,/spookymodem/);assert.match(credits,/creativecommons.org\/licenses\/by\/3.0/);
});
test('real power events include the newly requested effects at their actual activation',async()=>{
 const {soundCues}=await modulePromise;
 for(const power of ['nuke','missiles','frost','bubble','spikes']){const game=new ClassicGame(7,{spawning:false});game.activate(power);assert.deepEqual(soundCues(game.snapshot().events),['pickup',power]);}
 const wave=new ClassicGame(7,{spawning:false});wave.activate('wave');assert.deepEqual(soundCues(wave.events),['pickup']);for(let i=0;i<60;i++)wave.advance(1/120);assert.deepEqual(soundCues(wave.events),['wave']);
 for(const power of ['burn','boomerang']){
  const game=new ClassicGame(7,{spawning:false});game.activate(power);assert.deepEqual(soundCues(game.snapshot().events),['pickup',power+'-charge']);
  const cues=[];for(let i=0;i<61;i++)cues.push(...soundCues(game.advance(1/120).events));assert.equal(cues.filter(c=>c===power+'-launch').length,1);
 }
 const game=new ClassicGame(7,{spawning:false});game.activate('lightning');assert.deepEqual(soundCues(game.snapshot().events),['pickup','lightning']);
 assert.deepEqual(soundCues([{kind:'death'},{kind:'combo'},{kind:'warning'},{kind:'lightning'}]),[]);
});
test('frozen enemies killed by a weapon still use ice break audio',async()=>{
 const {soundCues}=await modulePromise;const game=new ClassicGame(7,{spawning:false});const e=game.addEnemy(510,320,{activeAt:0,frozenUntil:4});game.kill(e,'dot');assert.equal(game.events[0].frozen,true);assert.deepEqual(soundCues(game.events),['shatter']);
});
test('sustained laser audio resumes through pause and stops exactly with the effect',async()=>{
 const {GameSound}=await modulePromise;const h=harness(GameSound),s=h.sound;s.setMuted(false);s.startRun();
 const frame={state:'running',time:.25,events:[],fields:[],player:{laserRemaining:.95}};s.consume(frame);assert(!h.p('laser').paused);
 s.setMode('paused');assert(h.p('laser').paused);s.setMode('game');assert(!h.p('laser').paused);
 s.setMuted(true);assert(h.p('laser').paused);s.setMuted(false);assert(!h.p('laser').paused);
 s.setSuspended(true);assert(h.p('laser').paused);s.setSuspended(false);assert(!h.p('laser').paused);
 s.consume({...frame,time:1.2,player:{laserRemaining:0}});assert(h.p('laser').paused);
 h.p('music-a').pause();h.advance();s.consume({...frame,time:2,player:{laserRemaining:0}});assert(!h.p('music-a').paused);
});
test('music alternates across runs and track ends, pauses retain position, death uses menu with no death effect',async()=>{
 const {GameSound}=await modulePromise;const h=harness(GameSound),s=h.sound;s.setMuted(false);assert.equal(h.p('music-menu').paused,false);
 s.startRun();assert.equal(s.current,'music-a');assert.equal(h.p('music-menu').paused,true);h.p('music-a').currentTime=42;s.setMode('paused');assert.equal(h.p('music-a').paused,true);s.setMode('game');assert.equal(h.p('music-a').currentTime,42);
 h.p('music-a').ended();assert.equal(s.current,'music-b');s.setMode('menu');assert.equal(h.p('music-b').paused,true);s.startRun();assert.equal(s.current,'music-c');
 s.setMuted(true);assert.ok(Object.values(h.players).every(p=>p.paused));s.setMuted(false);assert.equal(h.p('music-c').paused,false);s.setSuspended(true);assert.ok(Object.values(h.players).every(p=>p.paused));
});
test('pickup and kill may sound together; pause, mute and field expiration cannot leak a charge or vortex',async()=>{
 const {GameSound}=await modulePromise;const h=harness(GameSound),s=h.sound;s.setMuted(false);s.startRun();
 const frame={state:'running',time:1,events:[{kind:'pickup',power:'burn'},{kind:'kill'}],player:{},fields:[{kind:'vortex',remaining:2}]};s.consume(frame);
 assert.equal(h.p('pickup').plays,1);assert.equal(h.p('hit').plays,1);assert.equal(h.p('burn-charge').plays,1);assert.equal(h.p('vortex').paused,false);
 s.consume(frame);assert.equal(h.p('pickup').plays,1);h.p('burn-charge').currentTime=.2;s.setMode('paused');assert.equal(h.p('burn-charge').paused,true);assert.equal(h.p('vortex').paused,true);s.setMode('game');assert.equal(h.p('burn-charge').currentTime,.2);
 h.advance();s.consume({...frame,time:2,events:[{kind:'burnLaunch'}],fields:[]});assert.equal(h.p('burn-charge').paused,true);assert.equal(h.p('burn-launch').plays,1);assert.equal(h.p('vortex').paused,true);
 s.setMode('menu');assert.equal(h.p('burn-launch').paused,true);assert.equal(h.p('burn-launch').currentTime,0);
});
test('both ice variants alternate, chains are coalesced and all UI uses the one approved click',async()=>{
 const {GameSound,soundCues}=await modulePromise;const h=harness(GameSound),s=h.sound;s.setMuted(false);s.startRun();s.play('shatter');h.advance();s.play('shatter');assert.equal(h.p('shatter-a').plays,1);assert.equal(h.p('shatter-b').plays,1);
 assert.deepEqual(soundCues(Array.from({length:30},()=>({kind:'electricPulse'}))),['lightning']);
 s.setMode('paused');h.advance();s.uiClick();assert.equal(h.p('ui').plays,1);s.setMode('menu');h.advance();s.uiClick();assert.equal(h.p('ui').plays,2);
});

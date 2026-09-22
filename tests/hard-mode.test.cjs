const test=require('node:test'),assert=require('node:assert/strict'),fs=require('node:fs'),vm=require('node:vm');
const moduleExport={exports:{}};vm.runInNewContext(fs.readFileSync('native-ios/Resources/classic-core.js','utf8'),{module:moduleExport});
const {ClassicGame,TUNING}=moduleExport.exports;
test('hard opens with 48 scattered warned dots, safe center and two usable pickups; classic is unchanged',()=>{
 const hard=new ClassicGame(91,{mode:'hard'}),classic=new ClassicGame(91);
 assert.equal(hard.snapshot().mode,'hard');assert.equal(hard.enemies.length,48);assert.equal(classic.enemies.length,0);
 assert.equal(hard.pickups.length,2);assert(hard.enemies.every(e=>e.activeAt===1.2 && e.speed===82));
 for(const bounds of [[24,936,52,592],[0,300,0,300],[118,1272,58,592]]){
  const g=new ClassicGame(91,{mode:'hard'});g.resize(...bounds);
  assert(g.enemies.every(e=>Math.hypot(e.x-g.player.x,e.y-g.player.y)>TUNING.spawnClearance));
 }
 for(let i=0;i<60;i++)hard.advance(1/120,{x:0,y:0});assert.equal(hard.state,'running');assert.equal(hard.score,0);
 assert.equal(new ClassicGame(91,{mode:'invalid'}).mode,'classic');
});
test('hard pressure rises sooner, remains bounded, and preserves player controls and power availability',()=>{
 const counts={};
 for(const mode of ['classic','hard']){
  const g=new ClassicGame(37,{mode});counts[mode]=[];
  for(let i=0;i<=240*120;i++){
   g.time=i/120;g.spawnDirector();
   if(i%3600===0)counts[mode].push(g.enemies.length);
   assert(g.enemies.length<=550);assert(g.pickups.length<=5);
  }
  assert(g.enemies.every(e=>e.speed<=(mode==='hard'?145:109)));
 }
 assert(counts.hard[0]>=48);assert(counts.hard[1]>counts.classic[1]*2);assert.equal(counts.hard.at(-1),550);
 const a=new ClassicGame(9,{mode:'hard',spawning:false}),b=new ClassicGame(9,{spawning:false});
 for(let i=0;i<30;i++){a.advance(1/120,{x:1,y:0});b.advance(1/120,{x:1,y:0});}
 assert.deepEqual(a.player,b.player);
 const g=new ClassicGame(9,{mode:'hard'});g.pickups=[];g.advance(1/120,{x:0,y:0});assert.equal(g.pickups.length,1);
});
test('hard runs are deterministic across frame rates and pause does not refill or advance enemies',()=>{
 const run=hz=>{const g=new ClassicGame(8,{mode:'hard'});for(let i=0;i<hz*2;i++)g.advance(1/hz,{x:.15,y:.25});return JSON.stringify(g.snapshot());};
 assert.equal(run(30),run(60));assert.equal(run(60),run(120));
 const g=new ClassicGame(8,{mode:'hard'});g.pause();const before=JSON.stringify(g.snapshot());g.advance(9,{x:1,y:0});assert.equal(JSON.stringify(g.snapshot()),before);
 g.resume();g.advance(1/120,{x:0,y:0});assert.equal(g.snapshot().mode,'hard');assert(g.time>0);
});

test('hard opening is scattered across seeds and formations wait until ten seconds',()=>{
 for(let seed=1;seed<=100;seed++){
  const g=new ClassicGame(seed,{mode:'hard'});
  assert.equal(g.enemies.length,48);
  assert(g.enemies.every(e=>e.formationUntil===0));
  assert.equal(new Set(g.enemies.map(e=>e.x)).size,48);
  assert.equal(new Set(g.enemies.map(e=>e.y)).size,48);
  for(const e of g.enemies)assert(g.enemies.every(other=>e===other||Math.hypot(e.x-other.x,e.y-other.y)>22));
  g.time=1.24;g.spawnDirector();assert.equal(g.enemies.length,48);
  for(let i=150;i<1200;i++){g.time=i/120;g.spawnDirector();}
  assert(!g.events.some(e=>e.kind==='pattern'));
  g.time=10;g.spawnDirector();assert(g.events.some(e=>e.kind==='pattern'));
 }
});

test('hard refills ease the opening and return to the established curve after twelve seconds',()=>{
 for(const time of [0,6,12,30,120]){
  const g=new ClassicGame(28,{mode:'hard',spawning:false});
  g.time=time;g.spawnAt=time;g.patternAt=Infinity;g.pickupAt=Infinity;
  g.spawnDirector();
  const previousPressure=85+time*1.4;
  const previousBatch=2+Math.floor(Math.min(12,previousPressure/12));
  const previousInterval=Math.max(.42,(1.6-previousPressure*.006)*.75);
  if(time<12){assert(g.enemies.length<previousBatch);assert(g.spawnAt-time>previousInterval);}
  else {assert.equal(g.enemies.length,previousBatch);assert(Math.abs(g.spawnAt-time-previousInterval)<1e-12);}
 }
});

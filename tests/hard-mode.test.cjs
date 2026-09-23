const test=require('node:test'),assert=require('node:assert/strict'),fs=require('node:fs'),vm=require('node:vm');
const moduleExport={exports:{}};vm.runInNewContext(fs.readFileSync('native-ios/Resources/classic-core.js','utf8'),{module:moduleExport});
const {ClassicGame,TUNING}=moduleExport.exports;
test('openings have two random safe pickups and enemies arrive separately in both modes',()=>{
 for(const mode of ['classic','hard']){
  const openings=new Set(), powers=new Set(), clocks=new Set();
  for(let seed=1;seed<=100;seed++){
   const g=new ClassicGame(seed,{mode});
   assert(mode==='hard' ? g.enemies.length>=8&&g.enemies.length<=12 : g.enemies.length===0);assert.equal(g.pickups.length,2);
   openings.add(JSON.stringify(g.pickups.map(p=>[p.power,p.x,p.y])));
   clocks.add(g.spawnAt);g.pickups.forEach(p=>powers.add(p.power));
   assert(g.pickups.every(p=>Math.hypot(p.x-g.player.x,p.y-g.player.y)>85));
   assert(Math.hypot(g.pickups[0].x-g.pickups[1].x,g.pickups[0].y-g.pickups[1].y)>65);
   for(const bounds of [[24,936,52,592],[0,300,0,300],[118,1272,58,592]]){
    const h=new ClassicGame(seed,{mode});h.resize(...bounds);
    for(let t=0;t<6*120;t++){
     h.time=t/120;const before=h.enemies.length;h.spawnDirector();
     assert(h.enemies.length-before<=1);assert(!h.events.some(e=>e.kind==='pattern'));
    }
    assert(h.enemies.length>0);
    assert(h.enemies.every(e=>Math.hypot(e.x-h.player.x,e.y-h.player.y)>TUNING.spawnClearance));
    assert(h.enemies.every(e=>e.activeAt>=TUNING.telegraph));
    if(mode==='hard')assert(h.enemies.length<80);
   }
  }
  assert.equal(openings.size,100);assert.equal(clocks.size,100);assert.equal(powers.size,10);
 }
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
 assert(counts.hard[0]>=8&&counts.hard[0]<=12);assert(counts.hard[1]>counts.classic[1]*2);assert.equal(counts.hard.at(-1),550);
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

test('hard opening is gentler across seeds and formations start at varied times after twelve seconds',()=>{
 const starts=new Set();
 for(let seed=1;seed<=100;seed++){
  const g=new ClassicGame(seed,{mode:'hard'});starts.add(g.patternAt);
  assert(g.patternAt>=12&&g.patternAt<=16);
  const opening=g.openingRemaining+g.enemies.length;assert(opening>=36&&opening<=42);
  for(let i=0;i<1200;i++){g.time=i/120;g.spawnDirector();}
  assert(!g.events.some(e=>e.kind==='pattern'));
  assert(g.enemies.length<130);
  g.time=g.patternAt;g.spawnDirector();assert(g.events.some(e=>e.kind==='pattern'));
 }
 assert.equal(starts.size,100);
});

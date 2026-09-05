const {test}=require('node:test');
const assert=require('node:assert/strict');
const fs=require('node:fs');
const vm=require('node:vm');
const {ClassicGame,TUNING,BOUNDS,POWERS,swept,tiltInput}=require('../native-ios/Resources/classic-core.js');
const fresh=()=>new ClassicGame(42,{spawning:false});
const run=(g,seconds,input={x:0,y:0},fps=60)=>{
  for(let i=0;i<Math.round(seconds*fps);i++)g.advance(1/fps,input);
};
const dot=(g,x,y)=>g.addEnemy(x,y,{activeAt:0,speed:0});
test('neutral calibration suppresses drift and landscape orientations mirror correctly',()=>{
  const n={x:-0.5,y:0.1};
  assert.deepEqual(tiltInput(n,n,'landscapeLeft',1),{x:0,y:0});
  const left=tiltInput({x:-0.4,y:0.2},n,'landscapeLeft',1);
  const right=tiltInput({x:-0.4,y:0.2},n,'landscapeRight',1);
  assert.ok(left.x>0&&left.y<0);assert.equal(left.x,-right.x);assert.equal(left.y,-right.y);
  assert.deepEqual(tiltInput({x:-0.501,y:0.102},n,'landscapeLeft',1),{x:0,y:0});
  assert.ok(Math.hypot(...Object.values(tiltInput({x:1,y:1},n,'landscapeLeft',2)))<=1.000001);
});
test('same input produces same motion at 30/60/120 Hz; speed stays isotropic',()=>{
  const games=[30,60,120].map(fps=>{const g=fresh();run(g,0.5,{x:0.5,y:0.3},fps);return g;});
  assert.ok(Math.abs(games[0].player.x-games[2].player.x)<1e-7);
  assert.ok(Math.abs(games[1].player.y-games[2].player.y)<1e-7);
  const d=fresh();run(d,0.5,{x:1,y:1});assert.ok(Math.hypot(d.player.vx,d.player.vy)<=TUNING.speed+1e-7);
});
test('motion brakes quickly and player stays in bounds',()=>{
  const g=fresh();run(g,4,{x:1,y:1});
  assert.equal(g.player.x,BOUNDS.right-7);assert.equal(g.player.y,BOUNDS.top-7);
  run(g,0.25);assert.ok(Math.hypot(g.player.vx,g.player.vy)<2);
});
test('a red-dot collision ends the run once; no health or revival',()=>{
  const g=fresh();dot(g,480,320);g.advance(1/60);
  assert.equal(g.state,'gameOver');const time=g.time;run(g,1);assert.equal(g.time,time);
});
test('swept collision catches crossing rather than only endpoint overlap',()=>{
  assert.equal(swept({x:0,y:0},{x:100,y:0},{x:50,y:0},7),true);
  assert.equal(swept({x:0,y:0},{x:100,y:0},{x:50,y:20},7),false);
});
test('telegraphs are harmless until active, and cannot be farmed for points',()=>{
  const g=fresh();g.addEnemy(480,320,{speed:0});g.activate('nuke');run(g,0.5);
  assert.equal(g.kills,0);assert.equal(g.state,'running');run(g,0.4);assert.equal(g.state,'gameOver');
});
test('nuke has local radius; frost freezes without killing and permits ramming',()=>{
  const g=fresh();dot(g,550,320);dot(g,800,320);g.activate('nuke');
  assert.equal(g.kills,1);assert.equal(g.enemies[1].dead,false);
  const f=fresh();const e=dot(f,550,320);f.activate('frost');run(f,0.1);
  assert.equal(f.kills,0);assert.equal(e.x,550);run(f,0.2,{x:1,y:0});
  assert.equal(f.kills,1);assert.equal(f.state,'running');
});
test('thaw returns collision danger, without permanent invulnerability',()=>{
  const g=fresh();const e=dot(g,700,320);e.frozenUntil=0.1;
  run(g,0.2);e.x=480;g.advance(1/60);assert.equal(g.state,'gameOver');
});
test('bubble survives time, then consumes one hit in a local detonation',()=>{
  const g=fresh();g.activate('bubble');run(g,65);assert.equal(g.player.bubble,true);
  dot(g,480,320);dot(g,530,320);dot(g,750,320);g.advance(1/60);
  assert.equal(g.player.bubble,false);assert.equal(g.kills,2);assert.equal(g.state,'running');
  dot(g,480,320);g.advance(1/60);assert.equal(g.state,'gameOver');
});
test('missiles travel and retarget, never kill instantly at pickup',()=>{
  const g=fresh();for(let i=0;i<5;i++)dot(g,650+i*35,300+i*14);
  g.activate('missiles');assert.equal(g.kills,0);assert.equal(g.projectiles.length,5);
  run(g,2.5);assert.ok(g.kills>=3);assert.equal(g.state,'running');
});
test('wave aims at release heading and only clears its moving front',()=>{
  const g=fresh();dot(g,650,320);dot(g,480,460);g.activate('wave');
  g.player.angle=0;run(g,0.8);assert.equal(g.enemies.find(e=>e.x===650),undefined);
  assert.equal(g.enemies.length,1);assert.equal(g.enemies[0].y,460);
});
test('lightning propagates through connected dots and stops at gaps',()=>{
  const g=fresh();dot(g,540,320);dot(g,620,320);dot(g,700,320);dot(g,860,320);
  g.activate('lightning');assert.equal(g.kills,3);assert.equal(g.enemies[3].dead,false);
});
test('spikes expire and fire leaves a bounded persistent trail',()=>{
  const g=fresh();g.activate('spikes');dot(g,500,320);g.advance(1/60);assert.equal(g.kills,1);
  run(g,5.1);dot(g,480,320);g.advance(1/60);assert.equal(g.state,'gameOver');
  const b=fresh();b.activate('burn');run(b,0.5,{x:1,y:0});assert.ok(b.fields.length>0);
  const at=b.fields[0];dot(b,at.x,at.y);b.advance(1/60);assert.equal(b.kills,1);
  run(b,5);assert.equal(b.fields.length,0);
});
test('vortex attracts both dots and pickups and then expires',()=>{
  const g=fresh();g.activate('vortex',{x:250,y:250});const e=dot(g,350,250);
  const o=g.addPickup('nuke',350,270);run(g,0.2);
  assert.ok(e.x<350);assert.ok(o.x<350);run(g,4.1);assert.equal(g.fields.length,0);
});
test('combo is an uncapped integer with one quadratic settlement',()=>{
  const g=fresh();for(let i=0;i<213;i++)g.kill(dot(g,80,80),'dot');
  assert.equal(g.combo,213);assert.equal(g.score,2130);
  run(g,2.6);assert.equal(g.score,2130+6*213*213);assert.equal(g.combo,0);
  run(g,3);assert.equal(g.score,274344);
  g.kill(dot(g,80,80),'dot');g.die();assert.equal(g.score,274360);
});
test('pause freezes score, durations, projectiles and spawns; resume has no catch-up',()=>{
  const g=new ClassicGame(123);g.activate('spikes');g.activate('missiles');run(g,0.5);
  g.pause();const snapshot=JSON.stringify(g.snapshot());run(g,20);
  assert.equal(JSON.stringify(g.snapshot()),snapshot);g.resume();g.advance(0);
  assert.ok(Math.abs(g.time-0.5)<1e-9);g.advance(100);assert.ok(g.time<0.61);
});
test('a pickup can trigger only once even with multiple substeps',()=>{
  const g=fresh();g.addPickup('bubble',480,320);g.advance(0.1);
  assert.equal(g.score,10);assert.equal(g.pickups.length,0);
});
test('expired pickups cannot be collected and ending a paused run settles only once',()=>{
  const g=fresh();g.addPickup('bubble',480,320).until=0;g.advance(1/60);
  assert.equal(g.player.bubble,false);assert.equal(g.score,0);
  const context=vm.createContext({});vm.runInContext(fs.readFileSync(require.resolve('../native-ios/Resources/classic-core.js'),'utf8'),context);
  context.ClassicAPI.create(4);context.ClassicAPI.pause();
  const ended=JSON.parse(context.ClassicAPI.finish());assert.equal(ended.state,'gameOver');
  assert.equal(JSON.parse(context.ClassicAPI.finish()).score,ended.score);
});
test('seeded director stays deterministic and obeys density/placement budgets',()=>{
  const a=new ClassicGame(12),b=new ClassicGame(12);
  // This is a director soak, not a claim that a human survives these inputs.
  for(let i=0;i<1200;i++) {
    for(const g of [a,b]){g.time=i*0.25;g.spawnDirector();}
  }
  assert.deepEqual(a.snapshot(),b.snapshot());assert.ok(a.enemies.length<=TUNING.maxEnemies);
  assert.ok(a.pickups.length<=TUNING.maxPickups);
  for(const e of a.enemies)assert.ok(e.x>=24&&e.x<=936&&e.y>=52&&e.y<=592);
});
test('every formation is made solely from the same dots',()=>{
  for(const kind of ['line','arrow','ring']){
    const g=fresh();g.spawnPattern(kind);assert.ok(g.enemies.length>=10);
    assert.ok(g.enemies.every(e=>e.activeAt===TUNING.telegraph));
    assert.ok(g.enemies.every(e=>!('elite' in e)));
  }
});
test('bundle global bridge loads without Node APIs and returns JSON for native decoding',()=>{
  const context=vm.createContext({});vm.runInContext(fs.readFileSync(require.resolve('../native-ios/Resources/classic-core.js'),'utf8'),context);
  const first=JSON.parse(context.ClassicAPI.create(19));assert.equal(first.state,'running');
  const next=JSON.parse(context.ClassicAPI.tick(1/60,0.5,0));assert.ok(next.player.x>first.player.x);
  context.ClassicAPI.pause();assert.equal(JSON.parse(context.ClassicAPI.tick(1,1,1)).state,'paused');
  context.ClassicAPI.resume();assert.equal(JSON.parse(context.ClassicAPI.tick(0,0,0)).state,'running');
  assert.equal(POWERS.length,9);
});

const {test}=require('node:test');
const assert=require('node:assert/strict');
const {ClassicGame,TUNING}=require('../native-ios/Resources/classic-core.js');
const fresh=()=>new ClassicGame(42,{spawning:false});
const run=(g,seconds,input={x:0,y:0},fps=120)=>{
  for(let i=0;i<Math.round(seconds*fps);i++)g.advance(1/fps,input);
};
const dot=(g,x,y,options={})=>g.addEnemy(x,y,{activeAt:0,speed:0,...options});

test('stronger player pull leaves the enemy and pickup drift unchanged',()=>{
  const g=fresh();g.activate('vortex',{x:580,y:320});
  assert.ok(Math.abs(g.playerVortexPull().x-200)<1e-8);
  const e=dot(g,680,320),o=g.addPickup('bubble',680,350);
  g.updateFields(TUNING.step);
  assert.ok(Math.abs(e.x-679.2857142857143)<1e-8);
  assert.ok(Math.abs(Math.hypot(o.x-680,o.y-350)-85/120)<1e-8);
  run(g,0.5,{x:-1,y:0});assert.ok(g.player.x<400);
});

test('electricity begins farther away but retains chain gaps and harmless telegraphs',()=>{
  const g=fresh();dot(g,680,320);dot(g,760,320);const gap=dot(g,870,320);
  const pending=dot(g,500,350,{activeAt:1});
  g.activate('lightning');assert.equal(g.kills,2);assert.equal(gap.dead,false);assert.equal(pending.dead,false);
  const bolts=g.events.filter(e=>e.kind==='lightning');assert.equal(bolts[0].toX,680);
  assert.equal(bolts[1].x,680);assert.equal(g.events.find(e=>e.kind==='electricPulse').radius,220);
  for(const [d,hit] of [[219,true],[221,false]]) {
    const edge=fresh(),e=dot(edge,480+d,320);edge.activate('lightning');assert.equal(e.dead,hit);
  }
});

test('boomerang pierces on the outbound and returns to the moved player through new enemies',()=>{
  const g=fresh();g.player.angle=0;dot(g,610,320);dot(g,680,320);g.activate('boomerang');
  run(g,0.4);assert.equal(g.kills,2);assert.equal(g.projectiles.length,1);
  g.player.y=420;run(g,0.15);
  const shot=g.projectiles[0];assert.equal(shot.returning,true);
  const target=dot(g,(shot.x+g.player.x)/2,(shot.y+g.player.y)/2);
  run(g,0.7);assert.equal(target.dead,true);assert.equal(g.kills,3);
  assert.equal(g.projectiles.length,0);assert.equal(g.state,'running');
});

test('boomerangs turn at walls, cap repeated pickups, and cannot persist indefinitely',()=>{
  const g=fresh();g.player.x=g.bounds.right-24;g.player.angle=0;
  g.activate('boomerang');run(g,0.1);assert.equal(g.projectiles.length,0);
  g.player.x=480;
  for(let i=0;i<20;i++)g.activate('boomerang');
  assert.equal(g.projectiles.filter(p=>!p.dead).length,3);
  run(g,3.1,{x:0,y:-1});assert.equal(g.projectiles.length,0);
  assert.equal(g.state,'running');
});

test('boomerangs pause exactly and behave consistently at 30/60/120 Hz',()=>{
  const states=[30,60,120].map(fps=>{
    const g=fresh();g.player.angle=0;g.activate('boomerang');run(g,0.3,undefined,fps);
    g.pause();const snapshot=g.snapshot();run(g,4,{x:1,y:1},fps);
    assert.deepEqual(g.snapshot(),snapshot);g.resume();run(g,0.4,{x:0,y:-0.4},fps);
    assert.equal(g.projectiles[0].returning,true);return g.snapshot();
  });assert.deepEqual(states[0],states[2]);
});

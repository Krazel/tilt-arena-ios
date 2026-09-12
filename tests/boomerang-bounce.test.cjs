const {test}=require('node:test');
const assert=require('node:assert/strict');
const {ClassicGame,TUNING}=require('../native-ios/Resources/classic-core.js');
const run=(g,n,input={x:0,y:0})=>{for(let i=0;i<n;i++)g.advance(1/120,input);};
const launch=()=>{const g=new ClassicGame(42,{spawning:false});g.player.angle=0;g.activate('boomerang');run(g,60);return [g,g.projectiles[0]];};

test('boomerang reflects all four walls and corners without changing speed or leaving the arena',()=>{
  for(const [x,y,vx,vy] of [[913,400,640,0],[47,400,-640,0],[700,569,0,640],[700,75,0,-640],[913,569,640/Math.sqrt(2),640/Math.sqrt(2)]]) {
    const [g,m]=launch();Object.assign(m,{x,y,vx,vy});run(g,1);
    assert.equal(m.bounces,1);assert.ok(Math.abs(Math.hypot(m.vx,m.vy)-640)<1e-8);
    if(vx)assert.ok(m.vx*vx<0);if(vy)assert.ok(m.vy*vy<0);
    assert.ok(m.x>=46&&m.x<=914&&m.y>=74&&m.y<=570);
  }
});

test('nearest enemy contact kills and reflects; enemies behind it and telegraphs remain unharmed',()=>{
  const [g,m]=launch();Object.assign(m,{x:600,y:400,vx:640,vy:0});
  const far=g.addEnemy(637,400,{activeAt:0,speed:0});
  const near=g.addEnemy(633,400,{activeAt:0,speed:0});
  const pending=g.addEnemy(601,400,{activeAt:10,speed:0});
  run(g,1);assert.equal(near.dead,true);assert.equal(far.dead,false);assert.equal(pending.dead,false);
  assert.equal(g.kills,1);assert.equal(m.bounces,1);assert.equal(m.vx,-640);
});

test('intercepting earns exactly one charged relaunch with no pickup points, aimed at release',()=>{
  const [g,m]=launch();const score=g.score;
  Object.assign(m,{x:g.player.x+20,y:g.player.y,vx:-640,vy:0,travelled:200});
  run(g,1);assert.equal(g.projectiles.length,0);assert.equal(g.boomerangAt.length,1);
  assert.equal(g.boomerangAt[0].relaunches,0);assert.equal(g.score,score);
  g.player.angle=Math.PI/2;run(g,59);assert.equal(g.projectiles.length,0);
  run(g,1);const second=g.projectiles[0];assert.ok(second);assert.equal(second.relaunches,0);
  assert.ok(Math.abs(second.angle-Math.PI/2)<1e-8);
  Object.assign(second,{x:g.player.x+20,y:g.player.y,vx:-640,vy:0,travelled:200});
  run(g,1);assert.equal(g.projectiles.length,0);assert.equal(g.boomerangAt.length,0);
  run(g,120);assert.equal(g.projectiles.length,0);assert.equal(g.score,score);
});

test('launch cannot immediately catch itself, while a moving player can intercept later',()=>{
  const [g,m]=launch();assert.equal(g.boomerangAt.length,0);assert.equal(m.relaunches,1);
  Object.assign(m,{x:g.player.x+20,y:g.player.y,vx:-640,vy:0,travelled:0});run(g,1);
  assert.equal(m.dead,undefined);assert.equal(g.boomerangAt.length,0);
  Object.assign(m,{x:500,y:320,vx:0,vy:640,travelled:200});
  g.player.x=479;g.player.y=325;g.player.vx=600;run(g,1,{x:1,y:0});
  assert.equal(m.dead,true);assert.equal(g.boomerangAt.length,1);
});

test('six bounces exhaust the flight even in dense overlaps and pause freezes a recaught charge',()=>{
  const [g,m]=launch();Object.assign(m,{x:700,y:400,vx:640,vy:0,travelled:200});
  for(let i=0;i<12;i++)g.addEnemy(700,400,{activeAt:0,speed:0});
  run(g,1);assert.equal(m.bounces,TUNING.boomerangBounces);assert.equal(m.dead,true);
  assert.equal(g.kills,6);assert.equal(g.projectiles.length,0);
  const [p,shot]=launch();Object.assign(shot,{x:p.player.x+20,y:p.player.y,vx:-640,vy:0,travelled:200});
  run(p,1);run(p,30);p.pause();const frame=p.snapshot();run(p,240);
  assert.deepEqual(p.snapshot(),frame);p.resume();run(p,30);assert.equal(p.projectiles.length,1);
});

test('bouncing is deterministic at 30, 60 and 120 Hz and restored braking preserves normal speed',()=>{
  const states=[30,60,120].map(fps=>{
    const [g,m]=launch();Object.assign(m,{x:900,y:500,vx:640/Math.sqrt(2),vy:640/Math.sqrt(2),travelled:200});
    g.player.y=100;for(let i=0;i<2*fps;i++)g.advance(1/fps,{x:0,y:0});return g.snapshot();
  });assert.deepEqual(states[0],states[1]);assert.deepEqual(states[0],states[2]);
  assert.equal(TUNING.braking,22);assert.equal(TUNING.speed,600);
});

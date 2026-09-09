const {test}=require('node:test');
const assert=require('node:assert/strict');
const {ClassicGame,POWERS,TUNING}=require('../native-ios/Resources/classic-core.js');
const fresh=()=>new ClassicGame(42,{spawning:false});
const run=(g,steps,input={x:0,y:0})=>{for(let i=0;i<steps;i++)g.advance(1/120,input);};

test('every pickup gives ten points, including fire; kills and combos dominate',()=>{
  for(const power of POWERS) {
    const g=fresh();g.activate(power);assert.equal(g.score,10,power);
    g.die();assert.equal(g.score,10,power);
  }
  const g=fresh();g.activate('burn');
  for(let i=0;i<10;i++)g.kill(g.addEnemy(100+i*25,100,{activeAt:0}),'dot');
  assert.equal(g.score,110);assert.equal(g.snapshot().pendingBonus,600);
  g.die();assert.equal(g.score,710);g.die();assert.equal(g.score,710);
});

test('boomerang waits half a second and launches once from the current position and heading',()=>{
  const g=fresh();g.player.angle=0;g.activate('boomerang');
  run(g,30,{x:0,y:0.5});
  assert.ok(g.player.y>320);assert.equal(g.projectiles.length,0);
  assert.equal(g.snapshot().player.boomerangCharging,true);
  assert.ok(Math.abs(g.snapshot().player.boomerangChargeProgress-0.5)<1e-8);
  run(g,29,{x:0,y:0.5});assert.equal(g.projectiles.length,0);
  run(g,1,{x:0,y:0.5});
  assert.equal(g.projectiles.length,1);assert.equal(g.snapshot().player.boomerangCharging,false);
  const shot=g.projectiles[0];assert.ok(Math.abs(shot.angle-Math.PI/2)<1e-8);
  assert.ok(Math.abs(shot.x-g.player.x)<1e-8);assert.ok(shot.y>g.player.y+24);
  assert.equal(g.events.filter(e=>e.kind==='boomerangLaunch').length,1);
  run(g,1);assert.equal(g.events.filter(e=>e.kind==='boomerangLaunch').length,0);
});

test('boomerang charge grants no damage or protection and cannot fire after death',()=>{
  const g=fresh();g.player.angle=0;g.activate('boomerang');
  const ahead=g.addEnemy(540,320,{activeAt:0,speed:0});run(g,30);
  assert.equal(ahead.dead,false);assert.equal(g.kills,0);
  g.addEnemy(g.player.x,g.player.y,{activeAt:0,speed:0});run(g,1);
  assert.equal(g.state,'gameOver');run(g,120);assert.equal(g.projectiles.length,0);
});

test('repeated boomerang pickups cap pending and flying weapons together without postponing every charge',()=>{
  const g=fresh();g.player.angle=0;g.activate('boomerang');run(g,60);
  const oldest=g.projectiles[0];assert.ok(oldest);
  g.activate('boomerang');run(g,12);g.activate('boomerang');g.activate('boomerang');
  assert.equal(oldest.dead,true);assert.equal(g.boomerangAt.length,3);
  run(g,48);assert.equal(g.projectiles.length,1);assert.equal(g.boomerangAt.length,2);
  run(g,12);assert.equal(g.projectiles.length,3);assert.equal(g.boomerangAt.length,0);
});

test('higher normal speed reaches 600 in every direction and brakes without changing the fire boost',()=>{
  for(const input of [{x:1,y:0},{x:0,y:1},{x:1,y:1}]) {
    const g=fresh();g.resize(0,4000,0,4000);g.player.x=1500;g.player.y=1500;
    run(g,120,input);assert.ok(Math.abs(Math.hypot(g.player.vx,g.player.vy)-600)<0.001);
    run(g,36);assert.ok(Math.hypot(g.player.vx,g.player.vy)<1);
  }
  assert.equal(TUNING.fireSpeed,1050);
});

test('difficulty remains time-driven and capped; existing enemies retain birth speed',()=>{
  const early=fresh(),late=fresh();early.rng.next=late.rng.next=()=>0;
  early.spawnAt=late.spawnAt=0;early.patternAt=late.patternAt=Infinity;
  early.pickupAt=late.pickupAt=Infinity;late.time=180;
  early.spawnDirector();late.spawnDirector();
  assert.equal(early.enemies.length,2);assert.equal(late.enemies.length,14);
  assert.ok(Math.abs(late.spawnAt-late.time-0.52)<1e-8);
  assert.equal(early.enemies[0].speed,49);assert.equal(late.enemies[0].speed,90.4);
  early.time=300;assert.equal(early.enemies[0].speed,49);
  const newborn=early.addEnemy(100,100);assert.equal(newborn.speed,109);
  const high=fresh(),low=fresh();high.score=999999;
  high.time=low.time=180;high.spawnAt=low.spawnAt=0;
  high.spawnDirector();low.spawnDirector();assert.deepEqual(high.enemies,low.enemies);
});

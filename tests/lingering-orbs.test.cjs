const test=require('node:test'),assert=require('node:assert/strict');
const {ClassicGame,TUNING}=require('../native-ios/Resources/classic-core.js');
const fresh=()=>new ClassicGame(77,{spawning:false});
const run=(g,time,fps=120)=>{for(let i=0;i<Math.round(time*fps);i++)g.advance(1/fps,{x:0,y:0});};
const dot=(g,x,y,extra={})=>g.addEnemy(x,y,{activeAt:0,speed:0,...extra});
test('blast persists for late arrivals, hits once and stops at expiry without enlarging its radius',()=>{
 const g=fresh();g.activate('nuke',{x:200,y:300});run(g,.8);
 const inside=dot(g,350,300),outside=dot(g,356,300);run(g,.1);
 assert(inside.dead);assert(!outside.dead);assert.equal(g.kills,1);assert.equal(g.score,20);
 run(g,.35);const late=dot(g,200,300);run(g,.1);assert(!late.dead);assert.equal(g.fields.length,0);
});
test('frost catches entrants for two seconds, pauses exactly and eventually thaws',()=>{
 const g=fresh();g.activate('frost',{x:200,y:300});run(g,1);
 const e=dot(g,390,300),outside=dot(g,406,300);run(g,.1);
 assert(e.frozenUntil>g.time);assert.equal(outside.frozenUntil,0);assert.equal(g.kills,0);
 const before=JSON.stringify(g.snapshot());g.pause();run(g,2);g.resume();assert.equal(JSON.stringify(g.snapshot()),before);
 run(g,1);assert.equal(g.fields.length,0);const late=dot(g,200,300);run(g,.1);assert.equal(late.frozenUntil,0);
 run(g,4);assert(e.frozenUntil<g.time);
});
test('swept entry into an active area is resolved before contact damage',()=>{
 const g=fresh();g.player.x=500;g.activate('frost',{x:300,y:320});
 const e=dot(g,510,320,{formationUntil:10,vx:-2400});g.advance(1/120,{x:0,y:0});
 assert(e.dead);assert.equal(g.state,'running');assert.equal(g.kills,1);
});
test('orbs have independent bounded drift and spin, including stationary examples, without consuming director RNG',()=>{
 const g=fresh(),state=g.rng.state;let still=0,moving=0,left=0,right=0,unspun=0;
 for(let i=0;i<300;i++){
  const o=g.addPickup('bubble',200,200),speed=Math.hypot(o.vx,o.vy);
  assert(speed<=18+1e-9);assert(Math.abs(o.spin)<=.6);assert(o.angle>=0&&o.angle<Math.PI*2);
  speed===0?still++:moving++;if(o.spin<0)left++;else if(o.spin>0)right++;else unspun++;
 }
 assert(still&&moving&&left&&right&&unspun);assert.equal(g.rng.state,state);
});
test('drifting orbs bounce at every wall, freeze on pause and can move into the player',()=>{
 for(const [axis,velocity,bound,sign] of [['x','vx','left',-1],['x','vx','right',1],['y','vy','bottom',-1],['y','vy','top',1]]){
  const g=fresh(),o=g.addPickup('bubble',200,200);o.vx=0;o.vy=0;o[axis]=g.bounds[bound]-sign*28;o[velocity]=sign*18;
  run(g,.1);assert.equal(Math.sign(o[velocity]),-sign);
  assert(o.x>=g.bounds.left+28&&o.x<=g.bounds.right-28&&o.y>=g.bounds.bottom+28&&o.y<=g.bounds.top-28);
  const before=[o.x,o.y,o.angle,o.until];g.pause();run(g,1);assert.deepEqual([o.x,o.y,o.angle,o.until],before);
 }
 const g=fresh(),o=g.addPickup('bubble',g.player.x+34,g.player.y);Object.assign(o,{vx:-18,vy:0});run(g,.1);
 assert(g.player.bubble);assert.equal(g.pickups.length,0);assert.equal(g.score,10);
});
test('lingering areas and moving orbs remain deterministic at 30, 60 and 120 fps',()=>{
 const frames=[30,60,120].map(fps=>{const g=fresh();g.addPickup('wave',100,100);g.activate('frost',{x:200,y:300});g.activate('nuke',{x:750,y:300});dot(g,760,300);run(g,1,fps);return g.snapshot();});
 for(const f of frames.slice(1))assert.deepEqual(f,frames[0]);
 assert.equal(TUNING.speed,600);
});

const test=require('node:test'),assert=require('node:assert/strict');
const {ClassicGame,TUNING}=require('../native-ios/Resources/classic-core.js');
test('trial limits change top speed only, keep default, response, braking and game state',()=>{
 const base=new ClassicGame(7,{spawning:false});assert.equal(base.playerSpeed,600);
 for(const speed of [600,660,720,780,840]){
  const g=new ClassicGame(7,{spawning:false,playerSpeed:speed});g.resize(-10000,10000,-10000,10000);
  const dt=1/120;g.advance(dt,{x:1,y:0});assert(Math.abs(g.player.vx/speed-(1-Math.exp(-TUNING.response*dt)))<1e-9);
  for(let i=0;i<120;i++)g.advance(dt,{x:1,y:0});assert(Math.abs(g.player.vx-speed)<.01);
  const before=g.player.vx;g.advance(dt,{x:0,y:0});assert(Math.abs(g.player.vx/before-Math.exp(-TUNING.braking*dt))<1e-9);
  g.pause();const time=g.time,score=g.score;g.setPlayerSpeed(600);g.resume();assert.equal(g.time,time);assert.equal(g.score,score);
  for(let i=0;i<120;i++)g.advance(dt,{x:1,y:0});assert(Math.abs(g.player.vx-600)<.01);
 }
 for(const invalid of [null,0,599,NaN,Infinity,'840'])assert.equal(new ClassicGame(7,{playerSpeed:invalid}).playerSpeed,600);
 assert.equal(TUNING.speed,600);
});

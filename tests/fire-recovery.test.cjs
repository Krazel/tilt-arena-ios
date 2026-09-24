const {test}=require('node:test'),assert=require('node:assert/strict');
const {ClassicGame,TUNING}=require('../native-ios/Resources/classic-core.js');
const run=(g,n)=>{for(let i=0;i<n;i++)g.advance(TUNING.step,{x:0,y:0});};
test('fire exit protects for half a second without killing enemies or consuming a shield',()=>{
 const g=new ClassicGame(71,{spawning:false});g.activate('burn');run(g,120);
 assert(g.snapshot().player.fireRecoveryRemaining>0.44);g.fields=[];
 g.player.bubble=true;const e=g.addEnemy(g.player.x,g.player.y,{activeAt:0,speed:0});
 run(g,30);assert.equal(g.state,'running');assert.equal(e.dead,false);assert.equal(g.player.bubble,true);
 const before=g.snapshot().player.fireRecoveryRemaining;g.pause();g.advance(100,{x:0,y:0});assert.equal(g.snapshot().player.fireRecoveryRemaining,before);g.resume();
 run(g,24);assert.equal(g.player.bubble,false);assert.equal(g.state,'running');
});
test('fire protection expires at the same time at 30, 60 and 120 FPS; normal contacts are lethal again',()=>{
 for(const hz of [30,60,120]){
  const g=new ClassicGame(17,{spawning:false});g.activate('burn');
  for(let i=0;i<hz;i++)g.advance(1/hz,{x:0,y:0});g.fields=[];
  const e=g.addEnemy(g.player.x,g.player.y,{activeAt:0,speed:0});
  while(g.state==='running'&&g.time<2)g.advance(1/hz,{x:0,y:0});
  assert.equal(g.state,'gameOver');assert.equal(e.dead,false);
  assert(Math.abs(g.time-(TUNING.fireCharge+TUNING.fireDash+TUNING.fireRecovery))<1e-7);
 }
 const fresh=new ClassicGame(17,{spawning:false});fresh.addEnemy(fresh.player.x,fresh.player.y,{activeAt:0,speed:0});run(fresh,1);assert.equal(fresh.state,'gameOver');
});
test('a subsequent fire launch renews recovery after that dash, never during charge',()=>{
 const g=new ClassicGame(17,{spawning:false});g.activate('burn');run(g,120);g.activate('burn');
 assert.equal(g.snapshot().player.fireRecoveryRemaining,0);run(g,120);
 assert(g.snapshot().player.fireRecoveryRemaining>0.44);assert(g.player.fireGraceUntil>2.44);
});

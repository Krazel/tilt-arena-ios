const {test}=require('node:test'),assert=require('node:assert/strict');
const {ClassicGame,TUNING}=require('../native-ios/Resources/classic-core.js');
const fresh=()=>{const g=new ClassicGame(58,{spawning:false});Object.assign(g.player,{x:250,y:250,angle:0});return g;};
const run=(g,t,fps=120,input)=>{for(let i=0;i<Math.round(t*fps);i++)g.advance(1/fps,input);};
test('laser pierces in front, respects width/range, ignores telegraphs and does not hit behind',()=>{
 const g=fresh();const opts={activeAt:0,speed:0};
 const hit=g.addEnemy(380,260,opts),hit2=g.addEnemy(680,250,opts);
 const side=g.addEnemy(450,275,opts),behind=g.addEnemy(190,250,opts),far=g.addEnemy(760,250,opts),warning=g.addEnemy(500,250,{speed:0,activeAt:1});
 g.activate('laser');g.advance(1/120);
 assert(hit.dead&&hit2.dead);for(const e of [side,behind,far,warning])assert(!e.dead);
 assert.equal(g.kills,2);assert.equal(g.snapshot().beam.width,TUNING.laserWidth);
});
test('beam follows aiming and clips exactly to every arena edge',()=>{
 const g=fresh();g.activate('laser');
 for(let a=0;a<Math.PI*2;a+=.1){g.player.angle=a;const b=g.snapshot().beam;assert(b.toX>=g.bounds.left-1e-8&&b.toX<=g.bounds.right+1e-8);assert(b.toY>=g.bounds.bottom-1e-8&&b.toY<=g.bounds.top+1e-8);}
 g.advance(.1,{x:0,y:1});const b=g.snapshot().beam;assert(Math.abs(b.toX-g.player.x)<1e-7);assert(b.toY>g.player.y);
 const back=g.addEnemy(g.player.x,g.player.y-12,{activeAt:0,speed:0});g.advance(1/120);assert.equal(g.state,'gameOver');assert(!back.dead);
});
test('laser expires at 1.2 seconds across frame rates; pause preserves it and re-pickup refreshes without stacking',()=>{
 for(const fps of [30,60,120]){const g=fresh();g.activate('laser');run(g,.5,fps);g.pause();g.advance(3);assert(Math.abs(g.snapshot().player.laserRemaining-.7)<1e-8);g.resume();g.activate('laser');run(g,1.2,fps);assert.equal(g.snapshot().beam,null);assert(g.snapshot().player.laserRemaining<1e-8);assert.equal(new ClassicGame(58,{spawning:false}).snapshot().beam,null);}
});
test('laser is in weighted random pool without replacing rare powers',()=>{
 const g=fresh(),counts={};for(let i=0;i<50000;i++){const p=g.choosePower();counts[p]=(counts[p]||0)+1;}
 assert(counts.laser>2000&&counts.laser<3600);assert(counts.spikes<counts.laser);assert(counts.nuke>counts.laser*2);
});

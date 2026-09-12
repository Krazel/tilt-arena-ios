const fs=require('node:fs'),vm=require('node:vm'),assert=require('node:assert/strict');
const {ClassicGame}=require('../native-ios/Resources/classic-core.js');
const driver=fs.readFileSync('capture/driver.js','utf8');
const b={left:118.70646766169155,right:1272.9353233830847,bottom:59.43283582089552,top:592};
const results=[];
for(let seed=1;seed<=100;seed++) {
  const ctx=vm.createContext({});vm.runInContext(driver,ctx);
  const g=new ClassicGame(seed);g.resize(b.left,b.right,b.bottom,b.top);
  let frame=g.snapshot();const events=[];
  for(let i=0;i<65*60&&frame.state==='running';i++) {
    const before=JSON.stringify(frame),input=ctx.CaptureDriver.next(frame,b);
    assert.equal(JSON.stringify(frame),before);assert(Math.hypot(...input)<=1.000001);
    frame=g.advance(1/60,{x:input[0],y:input[1]});
    for(const e of frame.events)if(['pickup','boomerangLaunch','boomerangBounce','boomerangCatch'].includes(e.kind))events.push({time:frame.time,...e});
  }
  const result={seed,time:frame.time,score:frame.score,kills:frame.kills,state:frame.state,events};results.push(result);
  console.log(JSON.stringify({seed,time:Math.round(frame.time),score:frame.score,boomerang:events.filter(e=>e.kind==='boomerangLaunch').length}));
  if(frame.time>64&&events.some(e=>e.kind==='boomerangLaunch'))break;
}
fs.mkdirSync('artifacts/capture-preflight',{recursive:true});
fs.writeFileSync('artifacts/capture-preflight/seeds.json',JSON.stringify({bounds:b,results},null,2)+'\n');
assert(results.some(r=>r.time>64&&r.events.some(e=>e.kind==='boomerangLaunch')),'No suitable unmodified ordinary run found');

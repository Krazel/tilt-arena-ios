// Capture-only: search actual seeded runs using a snapshot-only input driver.
const fs=require('node:fs'),path=require('node:path'),vm=require('node:vm'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const {ClassicGame}=require('../native-ios/Resources/classic-core.js');
const out=process.argv[3]||'artifacts/action-preflight';fs.mkdirSync(out,{recursive:true});
const b=process.argv[2]?JSON.parse(fs.readFileSync(process.argv[2])).bounds:{left:62*640/440+20,right:956*640/440-(62*640/440+20),bottom:20*640/440+26,top:592};
const driver=fs.readFileSync('capture/driver.js','utf8'),best={},runs=[];
const clean=f=>JSON.parse(JSON.stringify(f));
for(let seed=1;seed<=20;seed++){
 const ctx=vm.createContext({});vm.runInContext(driver,ctx);
 const g=new ClassicGame(seed,{mode:'classic'});g.resize(b.left,b.right,b.bottom,b.top);
 let f=g.snapshot(),inputs=[];const candidates={};
 for(let i=0;i<60*60&&f.state==='running';i++){
  const [x,y]=ctx.CaptureDriver.next(f,b);assert(Math.hypot(x,y)<=1.000001);inputs.push([x,y]);
  f=g.advance(1/60,{x,y});if(f.state!=='running')break;
  const enemies=f.enemies.filter(e=>!e.telegraph),frozen=enemies.filter(e=>e.frozen).length;
  const fire=f.fields.filter(e=>e.kind==='fire').length;
  const frost=f.fields.filter(e=>e.kind==='frost'&&e.remaining<e.duration-.15).length;
  const blast=f.fields.filter(e=>e.kind==='blast'&&e.remaining<e.duration-.08).length;
  const wave=f.projectiles.filter(e=>e.kind==='wave').length;
  const scores={
   fire:fire>=6&&f.player.burnUntil>f.time+.4&&enemies.length>=8?Math.min(fire,30)+Math.min(enemies.length,55)+f.combo:0,
   ice:frost&&frozen>=3?frozen*4+blast*15+Math.min(enemies.length,40):0,
   pressure:enemies.length-frozen>=55&&!fire?Math.min(enemies.length-frozen,100):0,
   wave:wave&&enemies.length>=8?wave*15+Math.min(enemies.length,45)+f.combo:0
  };
  for(const [kind,score]of Object.entries(scores))if(score>0&&(!candidates[kind]||score>candidates[kind].quality))candidates[kind]={kind,quality:score,seed,mode:'classic',step:i,time:f.time,snapshot:clean(f)};
 }
 runs.push({seed,time:f.time,score:f.score,enemies:f.enemies.length,kinds:Object.keys(candidates)});
 for(const [kind,c]of Object.entries(candidates))if(!best[kind]||c.quality>best[kind].quality)best[kind]={...c,inputs:inputs.slice(0,c.step+1)};
 console.log(JSON.stringify(runs.at(-1)));
 if(seed>=4&&['fire','ice','pressure','wave'].every(k=>best[k]))break;
}
assert(['fire','ice','pressure'].every(k=>best[k]),'Missing required natural action scenes');
for(const [kind,c]of Object.entries(best)){
 const g=new ClassicGame(c.seed,{mode:c.mode});g.resize(b.left,b.right,b.bottom,b.top);let f;
 for(const [x,y]of c.inputs)f=g.advance(1/60,{x,y});assert.deepEqual(clean(f),c.snapshot);
 c.bounds=b;c.dt=1/60;fs.writeFileSync(path.join(out,kind+'.json'),JSON.stringify(c));
}
const summary={baseCommit:'a52788f01b417aae51bebeeee3676d598aa1d198',coreSHA256:crypto.createHash('sha256').update(fs.readFileSync('native-ios/Resources/classic-core.js')).digest('hex'),driverSHA256:crypto.createHash('sha256').update(driver).digest('hex'),bounds:b,spawning:true,fixtures:false,runs,scenes:Object.fromEntries(Object.entries(best).map(([k,c])=>[k,{seed:c.seed,step:c.step,time:c.time,quality:c.quality,score:c.snapshot.score,enemies:c.snapshot.enemies.length,inputs:c.inputs.length}]))};
fs.writeFileSync(path.join(out,'preflight.json'),JSON.stringify(summary,null,2));console.log(JSON.stringify(summary.scenes));

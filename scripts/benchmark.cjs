const {ClassicGame}=require('../native-ios/Resources/classic-core.js');
const fs=require('node:fs'),path=require('node:path'),os=require('node:os');
const game=new ClassicGame(2308,{spawning:false});
for(let i=0;i<550;i++){
  const a=i*2.39996,r=150+(i%10)*11;
  game.addEnemy(480+Math.cos(a)*r*1.4,320+Math.sin(a)*r,{activeAt:0,speed:0});
}
const samples=[];
for(let i=0;i<4200;i++){
 const start=performance.now();JSON.parse(JSON.stringify(game.advance(1/60,{x:0,y:0})));
 if(i>=600)samples.push(performance.now()-start);
}
samples.sort((a,b)=>a-b);
const report={date:new Date().toISOString(),environment:`${os.platform()} ${os.arch()} Node ${process.version}`,
 scenario:'550 stationary active dots, 60 simulated seconds after warm-up, simulation + JSON round trip',
 samples:samples.length,meanMs:samples.reduce((a,b)=>a+b,0)/samples.length,p95Ms:samples[Math.floor(samples.length*.95)],maxMs:samples.at(-1),
 limitations:'Node/V8 on Windows only. No SpriteKit, JavaScriptCore, Swift decoding, sensor, GPU or native frame rate measured.'};
const out=path.join(__dirname,'../verification');fs.mkdirSync(out,{recursive:true});fs.writeFileSync(path.join(out,'engine-benchmark.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify(report));

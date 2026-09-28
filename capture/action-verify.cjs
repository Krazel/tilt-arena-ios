const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const dir=process.argv[2],results=[];let maxDifference=0;
function compare(a,b,p='frame'){
 if(typeof a==='number'&&typeof b==='number'){const d=Math.abs(a-b);maxDifference=Math.max(maxDifference,d);assert(d<.0001,p+': '+d);return;}
 if(a&&b&&typeof a==='object'&&typeof b==='object'){
  assert.deepEqual(Object.keys(a).sort(),Object.keys(b).sort(),p+' keys');for(const k of Object.keys(a))compare(a[k],b[k],p+'.'+k);return;
 }
 assert.equal(a,b,p);
}
for(const language of ['en','es'])for(const kind of ['fire','ice','pressure','wave']){
 const replay=JSON.parse(fs.readFileSync(path.join(dir,'replays',kind+'.json')));
 const frame=JSON.parse(fs.readFileSync(path.join(dir,language+'-'+kind+'-native.json')));
 compare(frame,replay.snapshot);results.push({language,kind,seed:replay.seed,time:frame.time,score:frame.score,state:frame.state,enemies:frame.enemies.length});
}
fs.writeFileSync(path.join(dir,'native-replay-verification.json'),JSON.stringify({verified:true,maxDifference,results},null,2));
console.log(JSON.stringify({verified:true,maxDifference,scenes:results.length}));

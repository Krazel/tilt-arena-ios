// Re-run every recorded input against the untouched production engine.
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict'),crypto=require('node:crypto');
const {ClassicGame}=require('../native-ios/Resources/classic-core.js');
const root=process.argv[2];assert(root);
const manifest=JSON.parse(fs.readFileSync(path.join(root,'capture-provenance.json')));
const hash=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
assert.equal(hash('native-ios/Resources/classic-core.js'),manifest.engineSHA256);
const results=[];
for(const take of manifest.takes) {
  const dir=path.join(root,`seed-${take.seed}`),start=JSON.parse(fs.readFileSync(path.join(dir,'capture-start.json')));
  assert.equal(start.spawning,true);assert.equal(start.fixtures,false);
  const g=new ClassicGame(take.seed),b=start.bounds;g.resize(b.left,b.right,b.bottom,b.top);
  const lines=fs.readFileSync(path.join(dir,'capture-frames.ndjson'),'utf8').trim().split('\n');
  const events=[];let maximumError=0,previousWall=0,maxGap=0;
  for(const line of lines) {
    const record=JSON.parse(line);assert(Math.hypot(...record.input)<=1.000001);
    const actual=record.frame,expected=g.advance(record.dt,{x:record.input[0],y:record.input[1]});
    for(const key of ['state','score','kills','combo'])assert.equal(actual[key],expected[key],`seed ${take.seed}, time ${actual.time}, ${key}`);
    const delta=Math.hypot(actual.player.x-expected.player.x,actual.player.y-expected.player.y);
    maximumError=Math.max(maximumError,delta);assert(delta<0.001,`Position mismatch at ${actual.time}: ${delta}`);
    assert(Math.abs(actual.time-expected.time)<1e-8);
    assert.deepEqual(actual.events.map(e=>[e.kind,e.power||null]),expected.events.map(e=>[e.kind,e.power||null]));
    assert.equal(actual.enemies.length,expected.enemies.length);
    if(previousWall)maxGap=Math.max(maxGap,record.wall-previousWall);previousWall=record.wall;
    for(const e of actual.events)if(['pickup','boomerangLaunch','boomerangBounce','boomerangCatch','death'].includes(e.kind))events.push({time:actual.time,wall:record.wall,...e});
  }
  assert.equal(hash(path.join(root,take.video)),take.sha256);
  results.push({seed:take.seed,frames:lines.length,seconds:g.time,state:g.state,score:g.score,kills:g.kills,
    replayMatches:true,maximumPositionError:maximumError,maximumFrameWallGap:maxGap,events});
}
const result={checkedAt:new Date().toISOString(),version:'0.3.9',build:'1',engineSHA256:manifest.engineSHA256,
  replayedWith:'Production ClassicGame, same seed/bounds and every recorded dt/input; no overrides',results};
fs.writeFileSync(path.join(root,'replay-verification.json'),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify(result));

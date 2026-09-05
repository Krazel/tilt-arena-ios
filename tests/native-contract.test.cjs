const {test}=require('node:test'),assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path');
const base=path.join(__dirname,'../native-ios');
test('all native sound assets are valid finite mono 16-bit PCM resources',()=>{
  for(const name of ['classic-loop','pickup','hit','death']){
    const b=fs.readFileSync(path.join(base,'Resources',name+'.wav'));
    assert.equal(b.toString('ascii',0,4),'RIFF');assert.equal(b.toString('ascii',8,12),'WAVE');
    assert.equal(b.readUInt32LE(4)+8,b.length);assert.equal(b.readUInt16LE(20),1);
    assert.equal(b.readUInt16LE(22),1);assert.equal(b.readUInt16LE(34),16);
    assert.equal(b.readUInt32LE(40)+44,b.length);
    let peak=0;for(let i=44;i<b.length;i+=2)peak=Math.max(peak,Math.abs(b.readInt16LE(i)));
    assert.ok(peak>1000&&peak<32767);
  }
});
test('native JSON decoder contract includes every produced frame and event property',()=>{
  const source=fs.readFileSync(path.join(base,'Sources/ClassicBridge.swift'),'utf8');
  const {ClassicGame,POWERS}=require('../native-ios/Resources/classic-core.js');
  const g=new ClassicGame(17,{spawning:false});
  for(const p of POWERS){g.addEnemy(510,320,{activeAt:0});g.activate(p);}
  const frame=g.advance(1/60);
  for(const key of Object.keys(frame))assert.match(source,new RegExp('\\b'+key+'\\b'));
  assert.ok(JSON.stringify(frame).length>300);
});

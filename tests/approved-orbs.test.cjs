const {test}=require('node:test');
const assert=require('node:assert/strict');
const fs=require('node:fs');
const crypto=require('node:crypto');
const manifest=JSON.parse(fs.readFileSync('native-ios/Resources/approved-orbs.json'));
test('approved orb resource is the unchanged selected reference with valid second-row crops',()=>{
  const sheet=fs.readFileSync('native-ios/Resources/ink-tide-approved-orbs.png');
  assert.equal(crypto.createHash('sha256').update(sheet).digest('hex'),manifest.sourceSHA256);
  assert.deepEqual([sheet.readUInt32BE(16),sheet.readUInt32BE(20)],manifest.sourceSize);
  assert.deepEqual(Object.keys(manifest.regions),['nuke','wave','frost','bubble','lightning']);
  for(const region of Object.values(manifest.regions)){
    const [x,y,w,h]=region.crop;
    assert.equal(y,368);assert.equal(w,256);assert.equal(h,256);
    assert(x>=0&&x+w<=1536&&y+h<=1024);
    assert(region.mask.every(p=>p.length===2&&p.every(v=>Number.isFinite(v)&&v>=0&&v<=256)));
    const xs=region.mask.map(p=>p[0]);
    assert(Math.abs((Math.max(...xs)-Math.min(...xs))*region.displaySize/256-49.96617812852311)<.001);
  }
});

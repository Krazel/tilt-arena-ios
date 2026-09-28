const {test}=require('node:test');
const assert=require('node:assert/strict');
const fs=require('node:fs');
const crypto=require('node:crypto');
const manifest=JSON.parse(fs.readFileSync('native-ios/Resources/approved-orbs.json'));
test('approved orb originals retain valid crops, dimensions and transparent PNGs',()=>{
  const sheet=fs.readFileSync('native-ios/Resources/ink-tide-approved-orbs.png');
  assert.equal(crypto.createHash('sha256').update(sheet).digest('hex'),manifest.sourceSHA256);
  assert.deepEqual([sheet.readUInt32BE(16),sheet.readUInt32BE(20)],manifest.sourceSize);
  assert.deepEqual(Object.keys(manifest.regions).sort(),['nuke','wave','frost','bubble','lightning','vortex','boomerang','laser','burn','spikes','missiles'].sort());
  for(const region of Object.values(manifest.regions)){
    const [x,y,w,h]=region.crop;
    const png=region.image?fs.readFileSync(`native-ios/Resources/${region.image}.png`):sheet;
    assert(x>=0&&y>=0&&x+w<=png.readUInt32BE(16)&&y+h<=png.readUInt32BE(20));
    assert.equal(w,h);
    assert(region.mask.every(p=>p.length===2&&p.every(v=>Number.isFinite(v)&&v>=0&&v<=256)));
    if(region.image){assert.equal(png[25],6);assert.equal(region.displaySize,56);}
    else {assert.equal(y,368);assert.equal(w,256);}
  }
});

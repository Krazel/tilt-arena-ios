const test = require('node:test');
const assert = require('node:assert/strict');
const helper = import('../scripts/altool-result.mjs');
test('altool rejects a zero exit code with the observed Apple 504 upload failure', async () => {
  const {requireAltoolSuccess} = await helper;
  assert.throws(() => requireAltoolSuccess({status:0,stderr:'Failed to upload package.\nUPLOAD FAILED with 1 error\nFailed to upload part number 6. (504)'}, 'upload'));
});
test('altool needs explicit success and propagates failed or missing exits', async () => {
  const {requireAltoolSuccess} = await helper;
  for (const result of [{status:0,stdout:''},{status:1,stdout:'UPLOAD SUCCEEDED'},{status:null,error:new Error('spawn failed')}]) {
    assert.throws(() => requireAltoolSuccess(result,'upload'));
  }
  assert.throws(() => requireAltoolSuccess({status:0,stdout:'VERIFY SUCCEEDED'},'upload'));
});
test('altool accepts confirmed upload or validation and captures delivery ID', async () => {
  const {requireAltoolSuccess} = await helper;
  const id='5bf8af06-4f1d-4833-b7ed-aea00fdc37f8';
  assert.equal(requireAltoolSuccess({status:0,stderr:`UPLOAD SUCCEEDED with no errors\nDelivery UUID: ${id}`},'upload'),id);
  assert.equal(requireAltoolSuccess({status:0,stdout:'VERIFY SUCCEEDED with no errors'},'validate'),undefined);
});

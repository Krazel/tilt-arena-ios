import fs from 'node:fs';
import path from 'node:path';
import {asc} from '../scripts/asc-client.mjs';

const root = process.cwd();
const setId = 'f8b717f4-aa35-495a-a863-6ae04c3ef036';
const dir = path.join(root, 'artifacts/asc-v039-screenshots-1290-en');

async function upload(filePath) {
  const fileName = path.basename(filePath);
  const bytes = fs.readFileSync(filePath);
  const reserve = await asc('POST', '/v1/appScreenshots', {
    data: {
      type: 'appScreenshots',
      attributes: {fileSize: bytes.length, fileName},
      relationships: {appScreenshotSet: {data: {type: 'appScreenshotSets', id: setId}}}
    }
  });
  const id = reserve.data.id;
  for (const op of reserve.data.attributes.uploadOperations || []) {
    const start = op.offset || 0;
    const chunk = bytes.subarray(start, start + op.length);
    const headers = {};
    for (const h of op.requestHeaders || []) headers[h.name] = h.value;
    const response = await fetch(op.url, {method: op.method, headers, body: chunk});
    if (!response.ok) throw new Error(`asset upload ${fileName} ${response.status} ${await response.text()}`);
  }
  const committed = await asc('PATCH', `/v1/appScreenshots/${id}`, {
    data: {type: 'appScreenshots', id, attributes: {uploaded: true}}
  });
  return {id, fileName, state: committed.data.attributes.assetDeliveryState?.state};
}

const listed = await asc('GET', `/v1/appScreenshotSets/${setId}/appScreenshots?limit=50`);
for (const shot of listed.data || []) await asc('DELETE', `/v1/appScreenshots/${shot.id}`);

const files = fs.readdirSync(dir).filter(x => /^gameplay-\d\d-1290\.png$/.test(x)).sort();
const result = [];
for (const file of files) result.push(await upload(path.join(dir, file)));
await new Promise(resolve => setTimeout(resolve, 3500));
for (const item of result) {
  const verify = await asc('GET', `/v1/appScreenshots/${item.id}`);
  item.state = verify.data.attributes.assetDeliveryState?.state;
  item.width = verify.data.attributes.imageAsset?.width;
  item.height = verify.data.attributes.imageAsset?.height;
  item.errors = verify.data.attributes.assetDeliveryState?.errors || [];
}
console.log(JSON.stringify(result, null, 2));

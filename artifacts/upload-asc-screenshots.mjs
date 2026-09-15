import fs from 'node:fs';
import path from 'node:path';
import {asc} from '../scripts/asc-client.mjs';
const root=process.cwd();
const targets=[
  {locale:'es-ES',setId:'fa3cb4a1-f3fd-437d-8046-debb0b7dca5b',dir:'artifacts/asc-v039-screenshots-1290'},
  {locale:'en-US',setId:'f8b717f4-aa35-495a-a863-6ae04c3ef036',dir:'artifacts/asc-v039-screenshots-1290'}
];
async function del(id){await asc('DELETE',`/v1/appScreenshots/${id}`);}
async function upload(setId,filePath){
  const fileName=path.basename(filePath), bytes=fs.readFileSync(filePath);
  const reserve=await asc('POST','/v1/appScreenshots',{data:{type:'appScreenshots',attributes:{fileSize:bytes.length,fileName},relationships:{appScreenshotSet:{data:{type:'appScreenshotSets',id:setId}}}}});
  const id=reserve.data.id;
  for(const op of reserve.data.attributes.uploadOperations||[]){
    const start=op.offset||0, chunk=bytes.subarray(start,start+op.length); const headers={}; for(const h of op.requestHeaders||[]) headers[h.name]=h.value;
    const response=await fetch(op.url,{method:op.method,headers,body:chunk}); if(!response.ok) throw new Error(`asset upload ${fileName} ${response.status} ${await response.text()}`);
  }
  const committed=await asc('PATCH',`/v1/appScreenshots/${id}`,{data:{type:'appScreenshots',id,attributes:{uploaded:true}}});
  return {id,fileName,state:committed.data.attributes.assetDeliveryState?.state};
}
const result=[];
for(const target of targets){
  const listed=await asc('GET',`/v1/appScreenshotSets/${target.setId}/appScreenshots?limit=50`);
  for(const shot of listed.data||[]) await del(shot.id);
  const files=fs.readdirSync(path.join(root,target.dir)).filter(x=>/^gameplay-\d\d-1290\.png$/.test(x)).sort();
  for(const file of files) result.push({...target, ...(await upload(target.setId,path.join(root,target.dir,file)))});
}
await new Promise(r=>setTimeout(r,3500));
for(const x of result){const v=await asc('GET',`/v1/appScreenshots/${x.id}`);x.state=v.data.attributes.assetDeliveryState?.state;x.width=v.data.attributes.imageAsset?.width;x.height=v.data.attributes.imageAsset?.height;x.errors=v.data.attributes.assetDeliveryState?.errors||[];}
console.log(JSON.stringify(result,null,2));

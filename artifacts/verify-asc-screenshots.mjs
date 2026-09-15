import {asc} from '../scripts/asc-client.mjs';
for(const [l,id] of [['es','fa3cb4a1-f3fd-437d-8046-debb0b7dca5b'],['en','f8b717f4-aa35-495a-a863-6ae04c3ef036']]){const x=await asc('GET',`/v1/appScreenshotSets/${id}/appScreenshots?limit=50`); console.log(l,JSON.stringify((x.data||[]).map(s=>({id:s.id,file:s.attributes.fileName,state:s.attributes.assetDeliveryState?.state,image:s.attributes.imageAsset,errors:s.attributes.assetDeliveryState?.errors})),null,2));}


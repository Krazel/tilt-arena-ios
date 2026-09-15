import {asc} from '../scripts/asc-client.mjs';
const appId='6809193185';
const infoId='677f5a7f-c656-4d15-89b3-0351d2f021d4';
const versionId='ce35253d-6a58-48d2-b42a-2fb5de18c021';
const app=await asc('GET',`/v1/apps/${appId}`);
const info=await asc('GET',`/v1/appInfos/${infoId}`);
const infoLoc=await asc('GET',`/v1/appInfos/${infoId}/appInfoLocalizations?limit=50`);
const version=await asc('GET',`/v1/appStoreVersions/${versionId}`);
const versionLoc=await asc('GET',`/v1/appStoreVersions/${versionId}/appStoreVersionLocalizations?limit=50`);
const reviewDetail=await asc('GET',`/v1/appStoreVersions/${versionId}/appStoreReviewDetail`);
const build=await asc('GET',`/v1/appStoreVersions/${versionId}/build`);
const age=await asc('GET',`/v1/appInfos/${infoId}/ageRatingDeclaration`);
const category=await asc('GET',`/v1/appInfos/${infoId}/primaryCategory`);
const subcategory=await asc('GET',`/v1/appInfos/${infoId}/primarySubcategoryOne`);
const base=await asc('GET',`/v1/appPriceSchedules/${appId}/baseTerritory`);
const prices=await asc('GET',`/v1/appPriceSchedules/${appId}/manualPrices?include=appPricePoint,territory&fields[appPricePoints]=customerPrice,proceeds&fields[territories]=currency&limit=50`);
const screenshots={};
for(const loc of versionLoc.data||[]){
  const sets=await asc('GET',`/v1/appStoreVersionLocalizations/${loc.id}/appScreenshotSets?limit=50`);
  screenshots[loc.attributes.locale]=[];
  for(const set of sets.data||[]){
    const shots=await asc('GET',`/v1/appScreenshotSets/${set.id}/appScreenshots?limit=50`);
    screenshots[loc.attributes.locale].push({id:set.id,type:set.attributes.screenshotDisplayType,shots:(shots.data||[]).map(s=>({id:s.id,fileName:s.attributes.fileName,state:s.attributes.assetDeliveryState?.state,width:s.attributes.imageAsset?.width,height:s.attributes.imageAsset?.height,errors:s.attributes.assetDeliveryState?.errors||[]}))});
  }
}
const summary={app:app.data.attributes,info:info.data.attributes,appInfoLocalizations:infoLoc.data.map(x=>x.attributes),version:version.data.attributes,versionLocalizations:versionLoc.data.map(x=>({id:x.id,locale:x.attributes.locale,descriptionLength:x.attributes.description?.length,promotionalText:x.attributes.promotionalText,marketingUrl:x.attributes.marketingUrl,supportUrl:x.attributes.supportUrl})),reviewDetail:reviewDetail.data,build:build.data&&{id:build.data.id,attrs:build.data.attributes},category:category.data?.id,subcategory:subcategory.data?.id,age:age.data?.attributes,baseTerritory:base.data,prices:prices.data?.map(x=>({id:x.id,attributes:x.attributes,territory:x.relationships?.territory?.data?.id,point:x.relationships?.appPricePoint?.data?.id,included:prices.included?.filter(y=>y.id===x.relationships?.appPricePoint?.data?.id||y.id===x.relationships?.territory?.data?.id).map(y=>({type:y.type,id:y.id,attributes:y.attributes}))})),screenshots};
console.log(JSON.stringify(summary,null,2));

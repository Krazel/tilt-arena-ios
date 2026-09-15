import {asc} from '../scripts/asc-client.mjs';
const id='6809193185';
await asc('PATCH',`/v1/apps/${id}`,{data:{type:'apps',id,attributes:{contentRightsDeclaration:'DOES_NOT_USE_THIRD_PARTY_CONTENT',primaryLocale:'en-US'}}});
const x=await asc('GET',`/v1/apps/${id}`); console.log(JSON.stringify({contentRightsDeclaration:x.data.attributes.contentRightsDeclaration,primaryLocale:x.data.attributes.primaryLocale},null,2));


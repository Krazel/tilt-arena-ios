import {asc} from '../scripts/asc-client.mjs';

const privacyPolicyUrl = 'https://krazel.github.io/tilt-arena/privacy/';
const supportUrl = 'https://krazel.github.io/tilt-arena/support/';
const appInfoLocalizations = {
  '8f2cfdfd-7a32-4cb0-8963-6bf79445bda6': 'es-ES',
  '63a400a2-63c1-4205-b95f-bf41666edd13': 'en-US'
};
const versionLocalizations = {
  '8a155d5b-1864-4d8c-b026-53c7854ca0d0': 'es-ES',
  '76440ee6-cf7f-4159-80de-913be03f8f52': 'en-US'
};

for (const [id, locale] of Object.entries(appInfoLocalizations)) {
  await asc('PATCH', `/v1/appInfoLocalizations/${id}`, {
    data: {type: 'appInfoLocalizations', id, attributes: {privacyPolicyUrl}}
  });
  console.log(`privacy ${locale} ${privacyPolicyUrl}`);
}

for (const [id, locale] of Object.entries(versionLocalizations)) {
  await asc('PATCH', `/v1/appStoreVersionLocalizations/${id}`, {
    data: {type: 'appStoreVersionLocalizations', id, attributes: {supportUrl}}
  });
  console.log(`support ${locale} ${supportUrl}`);
}

const info = await asc('GET', '/v1/appInfos/677f5a7f-c656-4d15-89b3-0351d2f021d4/appInfoLocalizations?limit=50');
const versions = await asc('GET', '/v1/appStoreVersions/ce35253d-6a58-48d2-b42a-2fb5de18c021/appStoreVersionLocalizations?limit=50');
console.log(JSON.stringify({
  appInfoLocalizations: (info.data || []).map(x => ({id: x.id, locale: x.attributes.locale, privacyPolicyUrl: x.attributes.privacyPolicyUrl})),
  versionLocalizations: (versions.data || []).map(x => ({id: x.id, locale: x.attributes.locale, supportUrl: x.attributes.supportUrl}))
}, null, 2));

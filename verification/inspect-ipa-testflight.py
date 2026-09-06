"""Verify an iPhone IPA's platform, architecture, resources and CI checksum."""
import hashlib
import json
import plistlib
import struct
import sys
import zipfile
from pathlib import Path

ipa = Path(sys.argv[1])
root = Path(__file__).resolve().parents[1]
manifest = json.loads((ipa.parent / 'build.json').read_text())
config = json.loads((root / 'store/testflight.json').read_text())
assert hashlib.sha256(ipa.read_bytes()).hexdigest() == manifest['sha256']
with zipfile.ZipFile(ipa) as bundle:
    assert bundle.testzip() is None
    prefix = 'Payload/TiltArena.app/'
    info = plistlib.loads(bundle.read(prefix + 'Info.plist'))
    assert info['CFBundleSupportedPlatforms'] == ['iPhoneOS']
    assert info['CFBundleIdentifier'] == 'com.dmkr.tiltarena'
    assert info['CFBundleShortVersionString'] == manifest['version'] == config['marketingVersion']
    assert info['CFBundleVersion'] == manifest['build'] == sys.argv[2]
    assert info['DTSDKName'].startswith('iphoneos26')
    assert info['ITSAppUsesNonExemptEncryption'] is False
    assert prefix + 'enemy-dot-v03.png' not in bundle.namelist()
    assert prefix + 'embedded.mobileprovision' in bundle.namelist()
    assert prefix + '_CodeSignature/CodeResources' in bundle.namelist()
    assert prefix + 'Assets.car' in bundle.namelist()
    privacy = plistlib.loads(bundle.read(prefix + 'PrivacyInfo.xcprivacy'))
    assert privacy['NSPrivacyTracking'] is False
    assert privacy['NSPrivacyCollectedDataTypes'] == []
    assert privacy == plistlib.loads((root / 'native-ios/Resources/PrivacyInfo.xcprivacy').read_bytes())
    assert manifest['signatureVerified'] and manifest['uploadAccepted']
    code = bundle.read(prefix + info['CFBundleExecutable'])
    magic, cpu, _, _, commands = struct.unpack_from('<5I', code)
    assert magic == 0xfeedfacf and cpu == 0x0100000c
    offset, platforms, encrypted = 32, [], []
    for _ in range(commands):
        command, size = struct.unpack_from('<2I', code, offset)
        assert size >= 8 and offset + size <= len(code)
        if command == 0x32:  # LC_BUILD_VERSION
            platforms.append(struct.unpack_from('<I', code, offset + 8)[0])
        if command == 0x2c:  # LC_ENCRYPTION_INFO_64
            encrypted.append(struct.unpack_from('<I', code, offset + 16)[0])
        offset += size
    assert platforms == [2], platforms  # PLATFORM_IOS, not IOSSIMULATOR
    assert not any(encrypted)
    resources = {}; optimizedImages = {}
    for name in ['classic-core.js', 'classic-loop.wav', 'death.wav', 'hit.wav', 'pickup.wav', 'orb-glass-v03.png', 'energy-spark-v03.png']:
        data = bundle.read(prefix + name)
        original = (root / 'native-ios' / 'Resources' / name).read_bytes()
        if name.endswith('.png') and b'CgBI' in data[:24]:
            def dimensions(png):
                at = png.index(b'IHDR') + 4
                return struct.unpack_from('>II', png, at)
            assert dimensions(data) == dimensions(original)
            optimizedImages[name] = {'format':'Apple CgBI PNG', 'dimensions':dimensions(data),
                                     'sourceSHA256':hashlib.sha256(original).hexdigest(),
                                     'verification':'Dimensions and ZIP CRC; rendered appearance checked separately in native QA'}
        else:
            assert data == original, name
        resources[name] = hashlib.sha256(data).hexdigest()
    result = dict(manifest, zipCRCValid=True, verifiedMachOPlatform='iOS',
                  verifiedArchitecture='arm64', encrypted=False,
                  engineAndAudioMatchCanonicalSource=True, resourceSHA256=resources, optimizedImages=optimizedImages,
                  embeddedProvisioningProfile=(prefix + 'embedded.mobileprovision') in bundle.namelist(),
                  executablePermission=oct(bundle.getinfo(prefix + info['CFBundleExecutable']).external_attr >> 16))
(root / 'verification' / ('ipa-v' + manifest['version'].replace('.', '') + '-testflight-build' + sys.argv[2] + '.json')).write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result, indent=2))

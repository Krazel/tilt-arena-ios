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
manifest = json.loads((ipa.parent / 'manifest.json').read_text())
assert hashlib.sha256(ipa.read_bytes()).hexdigest() == manifest['sha256']
with zipfile.ZipFile(ipa) as bundle:
    assert bundle.testzip() is None
    prefix = 'Payload/TiltArena.app/'
    info = plistlib.loads(bundle.read(prefix + 'Info.plist'))
    assert info['CFBundleSupportedPlatforms'] == ['iPhoneOS']
    assert info['CFBundleIdentifier'] == 'com.dmkr.tiltarena'
    assert info['CFBundleShortVersionString'] == manifest['version'] == '0.2.0'
    assert info['CFBundleVersion'] == manifest['build'] == '3'
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
    resources = {}
    for name in ['classic-core.js', 'classic-loop.wav', 'death.wav', 'hit.wav', 'pickup.wav']:
        data = bundle.read(prefix + name)
        assert data == (root / 'native-ios' / 'Resources' / name).read_bytes(), name
        resources[name] = hashlib.sha256(data).hexdigest()
    result = dict(manifest, zipCRCValid=True, verifiedMachOPlatform='iOS',
                  verifiedArchitecture='arm64', encrypted=False,
                  resourcesMatchCanonicalSource=True, resourceSHA256=resources,
                  embeddedProvisioningProfile=(prefix + 'embedded.mobileprovision') in bundle.namelist(),
                  executablePermission=oct(bundle.getinfo(prefix + info['CFBundleExecutable']).external_attr >> 16))
(root / 'verification' / 'ipa-build3.json').write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result, indent=2))

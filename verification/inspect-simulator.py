"""Inspect the downloaded simulator archive without extracting executable files."""
import hashlib
import json
import plistlib
import sys
import tarfile
from pathlib import Path

archive = Path(sys.argv[1])
root = Path(__file__).resolve().parents[1]
run = json.loads((root / 'verification' / 'build2-run.json').read_text(encoding='utf-8-sig'))
assert run['conclusion'] == 'success'
with tarfile.open(archive, 'r:gz') as bundle:
    def read(name):
        return bundle.extractfile('TiltArena.app/' + name).read()
    info = plistlib.loads(read('Info.plist'))
    assert info['CFBundleIdentifier'] == 'com.dmkr.tiltarena'
    assert info['CFBundleShortVersionString'] == '0.2.0'
    assert info['CFBundleVersion'] == '2'
    assert info['CFBundleSupportedPlatforms'] == ['iPhoneSimulator']
    executable = read(info['CFBundleExecutable'])
    assert executable[:4].hex() in ['cffaedfe', 'feedfacf', 'cafebabe', 'bebafeca']
    resources = {}
    for name in ['classic-core.js', 'classic-loop.wav', 'death.wav', 'hit.wav', 'pickup.wav']:
        data = read(name)
        assert data == (root / 'native-ios' / 'Resources' / name).read_bytes(), name
        resources[name] = hashlib.sha256(data).hexdigest()
    result = {
        'purpose': 'Local-QA simulator',
        'sourceCommit': run['headSha'],
        'runURL': run['url'],
        'archive': archive.name,
        'sha256': hashlib.sha256(archive.read_bytes()).hexdigest(),
        'archiveBytes': archive.stat().st_size,
        'version': info['CFBundleShortVersionString'],
        'build': info['CFBundleVersion'],
        'bundleIdentifier': info['CFBundleIdentifier'],
        'platforms': info['CFBundleSupportedPlatforms'],
        'minimumOS': info.get('MinimumOSVersion'),
        'xcode': info.get('DTXcode'),
        'sdk': info.get('DTSDKName'),
        'executableMagic': executable[:4].hex(),
        'resourcesMatchCanonicalSource': True,
        'resourceSHA256': resources,
        'physicalDeviceTested': False,
        'testFlightUploaded': False,
    }
output = root / 'verification' / 'simulator-artifact.json'
output.write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
print(json.dumps(result, indent=2))

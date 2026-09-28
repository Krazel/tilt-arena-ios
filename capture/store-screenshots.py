"""Capture the original verified 0.5.8 simulator binary on a larger iPhone.

Only the external test runner is new. Replace the intermediate app produced by
build-for-testing with the original artifact before test-without-building.
No IPA, signing credentials, App Store or TestFlight operations exist here.
"""
import hashlib, json, os, pathlib, plistlib, shutil, subprocess, tarfile

ROOT = pathlib.Path.cwd()
OUT = ROOT / 'artifacts/asc-screenshots'
OUT.mkdir(parents=True, exist_ok=True)
BASE = 'a52788f01b417aae51bebeeee3676d598aa1d198'
ARCHIVE_SHA = 'be05add994f69e3423a83ab4ba937be32f3ad4fd455a92756e5a7d5a6cdf849d'

def run(*args, cwd=ROOT):
    return subprocess.check_output(args, cwd=cwd, text=True, stderr=subprocess.STDOUT).strip()

def hashed_tree(path):
    return {str(p.relative_to(path)): hashlib.sha256(p.read_bytes()).hexdigest()
            for p in sorted(path.rglob('*')) if p.is_file()}

assert not run('git', 'diff', BASE, '--', 'native-ios/Sources', 'native-ios/Resources', 'native-ios/project.yml'), 'Production source changed'
archive = ROOT / 'artifacts/original-simulator/TiltArena-0.5.8-build1-simulator.tar.gz'
assert hashlib.sha256(archive.read_bytes()).hexdigest() == ARCHIVE_SHA
source_dir = ROOT / 'artifacts/original-app'
source_dir.mkdir()
with tarfile.open(archive) as tar:
    tar.extractall(source_dir, filter='data')
original = source_dir / 'TiltArena.app'
original_hashes = hashed_tree(original)
info = plistlib.loads((original / 'Info.plist').read_bytes())
assert info['CFBundleShortVersionString'] == '0.5.8' and str(info['CFBundleVersion']) == '1'
assert info['UIDeviceFamily'] == [1]
assert (original / 'classic-core.js').read_bytes() == (ROOT / 'native-ios/Resources/classic-core.js').read_bytes()
runtime = next(r['identifier'] for r in json.loads(run('xcrun', 'simctl', 'list', 'runtimes', '--json'))['runtimes'] if r['isAvailable'] and r['name'] == 'iOS 26.2')
device = run('xcrun', 'simctl', 'create', 'Tilt Arena Store iPhone 16 Pro Max', 'com.apple.CoreSimulator.SimDeviceType.iPhone-16-Pro-Max', runtime)
target = ROOT / 'native-ios'
derived = ROOT / 'artifacts/asc-derived'
result = OUT / 'StoreScreenshots.xcresult'
provenance = dict(baseCommit=BASE, captureCommit=os.environ.get('GITHUB_SHA'), run=os.environ.get('GITHUB_RUN_ID'),
    originalArtifactId=10801108467, originalRun=35982949271, archiveSHA256=ARCHIVE_SHA,
    version='0.5.8', build='1', device='iPhone 16 Pro Max simulator', deviceID=device, runtime=runtime,
    expectedLandscapePixels=[2868,1320], deviceFamily=info['UIDeviceFamily'], originalAppFiles=original_hashes,
    sourcesUnchanged=True, originalAppReused=False, fixtures=False, spawning=True,
    input='Existing simulator drag input, driven externally by XCTest',
    localization=['en-US','es-ES'], physicalDevice=False, ipaGenerated=False, appleUpload=False)
(OUT / 'provenance.json').write_text(json.dumps(provenance, indent=2) + '\n')
try:
    run('xcrun', 'simctl', 'boot', device)
    run('xcrun', 'simctl', 'bootstatus', device, '-b')
    run('xcodegen', 'generate', cwd=target)
    cmd = ['xcodebuild', '-project', 'TiltArena.xcodeproj', '-scheme', 'TiltArena',
           '-destination', f'platform=iOS Simulator,id={device}', '-derivedDataPath', str(derived),
           'CODE_SIGNING_ALLOWED=NO', '-parallel-testing-enabled', 'NO']
    with (OUT / 'test-runner-build.log').open('w') as log:
        subprocess.run(cmd + ['build-for-testing'], cwd=target, stdout=log, stderr=subprocess.STDOUT, check=True)
    app_target = derived / 'Build/Products/Debug-iphonesimulator/TiltArena.app'
    assert app_target.resolve().is_relative_to(derived.resolve())
    shutil.rmtree(app_target)
    shutil.copytree(original, app_target)
    assert hashed_tree(app_target) == original_hashes
    provenance['originalAppReused'] = True
    (OUT / 'provenance.json').write_text(json.dumps(provenance, indent=2) + '\n')
    with (OUT / 'capture-tests.log').open('w') as log:
        completed = subprocess.run(cmd + ['-resultBundlePath', str(result),
            '-only-testing:TiltArenaUITests/StoreCaptureTests/testStoreScreenshotsInBothLanguages',
            'test-without-building'], cwd=target, stdout=log, stderr=subprocess.STDOUT)
    provenance['testExitCode'] = completed.returncode
    provenance['originalAppStillIdenticalAfterTest'] = hashed_tree(app_target) == original_hashes
    (OUT / 'provenance.json').write_text(json.dumps(provenance, indent=2) + '\n')
    completed.check_returncode()
finally:
    if result.exists():
        subprocess.run(['xcrun', 'xcresulttool', 'export', 'attachments', '--path', str(result), '--output-path', str(OUT / 'raw')])
    subprocess.run(['xcrun', 'simctl', 'shutdown', device])

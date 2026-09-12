"""Mac CI only: simctl records the real display, production rules, simulated input."""
import hashlib, json, os, pathlib, shutil, signal, subprocess, time

root = pathlib.Path.cwd()
out = root/'artifacts/gameplay-capture'; out.mkdir(parents=True, exist_ok=True)
def run(*args, timeout=300, cwd=None):
    return subprocess.check_output(args, text=True, stderr=subprocess.STDOUT, timeout=timeout, cwd=cwd).strip()
runtime = next(r['identifier'] for r in json.loads(run('xcrun','simctl','list','runtimes','--json'))['runtimes'] if r['isAvailable'] and r['name']=='iOS 26.2')
device = run('xcrun','simctl','create','Tilt Arena Capture','com.apple.CoreSimulator.SimDeviceType.iPhone-16-Pro',runtime)
metadata = dict(version='0.3.9',build='1',baseProductionCommit='c733e9ed4c05070cb19ac28fce6d3b5f8775e9f6',
    captureCommit=os.environ.get('GITHUB_SHA'),run=os.environ.get('GITHUB_RUN_ID'),device=device,
    deviceName='iPhone 16 Pro',runtime=runtime,xcode=run('xcodebuild','-version'),
    renderer='Production SwiftUI/SpriteKit, temporary input and telemetry overlay only',
    engine='Unmodified production JavaScriptCore resource',spawning=True,fixtures=False,
    input='Snapshot-only CaptureDriver, no state mutation',audio='simctl raw video; supply original music separately for marketing edit',
    physicalDevice=False,pcBuild=False,appleUpload=False,takes=[])
(out/'capture-provenance.json').write_text(json.dumps(metadata,indent=2)+'\n')
try:
    run('xcrun','simctl','boot',device)
    run('xcrun','simctl','bootstatus',device,'-b',timeout=420)
    target = root/'artifacts/capture-target/native-ios'
    run('xcodegen','generate',cwd=target)
    with (out/'build.log').open('w') as log:
        subprocess.run(['xcodebuild','-project','TiltArena.xcodeproj','-scheme','TiltArena','-configuration','Debug',
            '-sdk','iphonesimulator','-destination',f'platform=iOS Simulator,id={device}',
            '-derivedDataPath','DerivedData','CODE_SIGNING_ALLOWED=NO','build'],cwd=target,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=600)
    app=target/'DerivedData/Build/Products/Debug-iphonesimulator/TiltArena.app'
    canonical=(root/'native-ios/Resources/classic-core.js').read_bytes()
    assert (app/'classic-core.js').read_bytes()==canonical
    metadata['engineSHA256']=hashlib.sha256(canonical).hexdigest()
    shutil.copyfile(root/'artifacts/capture-target/source-resources.json',out/'source-resources.json')
    for seed in [2,7]:
        run('xcrun','simctl','uninstall',device,'com.dmkr.tiltarena') if seed!=2 else None
        run('xcrun','simctl','install',device,str(app))
        take=out/f'seed-{seed}';take.mkdir()
        launch=['xcrun','simctl','launch',device,'com.dmkr.tiltarena','--capture-gameplay',f'--capture-seed={seed}']
        run(*launch);time.sleep(4)
        docs=pathlib.Path(run('xcrun','simctl','get_app_container',device,'com.dmkr.tiltarena','data'))/'Documents'
        video=take/'gameplay-raw.mp4'
        command=['xcrun','simctl','io',device,'recordVideo','--codec=h264',str(video)]
        with (take/'record.log').open('w') as log:
            started=time.time();rec=subprocess.Popen(command,stdout=log,stderr=subprocess.STDOUT)
            try:
                time.sleep(2);assert rec.poll() is None,'Recorder exited'
                (docs/'capture-go').touch()
                deadline=time.monotonic()+150;shot=0
                while not (docs/'capture-done.json').exists():
                    if time.monotonic()>deadline:raise TimeoutError('Capture did not finish')
                    startfile=docs/'capture-start.json'
                    if startfile.exists():
                        start=json.loads(startfile.read_text())
                        if shot<4 and time.time()-start['startedWall']>[10,25,40,55][shot]:
                            run('xcrun','simctl','io',device,'screenshot',str(take/f'gameplay-{shot:02}.png'));shot+=1
                    time.sleep(0.4)
                time.sleep(0.5)
            finally:
                rec.send_signal(signal.SIGINT);rec.wait(timeout=30)
                for name in ['capture-start.json','capture-done.json','capture-frames.ndjson']:
                    if (docs/name).exists():shutil.copyfile(docs/name,take/name)
            assert video.exists() and video.stat().st_size>100000
            metadata['takes'].append(dict(seed=seed,video=str(video.relative_to(out)),recordCommand=command,
                launchCommand=launch,recordProcessStartedWall=started,sha256=hashlib.sha256(video.read_bytes()).hexdigest(),
                done=json.loads((take/'capture-done.json').read_text())))
        (out/'capture-provenance.json').write_text(json.dumps(metadata,indent=2)+'\n')
        run('xcrun','simctl','terminate',device,'com.dmkr.tiltarena')
    assert sum(t['done']['gameTime'] for t in metadata['takes'])>=40,'Insufficient gameplay'
finally:
    subprocess.run(['xcrun','simctl','shutdown',device],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
print(json.dumps(metadata))

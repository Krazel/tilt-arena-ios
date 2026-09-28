import hashlib, json, os, pathlib, plistlib, shutil, subprocess, time
ROOT=pathlib.Path.cwd();OUT=ROOT/'artifacts/action-capture';OUT.mkdir(parents=True,exist_ok=True)
BASE='a52788f01b417aae51bebeeee3676d598aa1d198'
def run(*args,cwd=ROOT):
    p=subprocess.run(args,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,cwd=cwd)
    if p.returncode:print(p.stdout,flush=True);p.check_returncode()
    return p.stdout.strip()
assert not run('git','diff',BASE,'--','native-ios/Sources','native-ios/Resources','native-ios/project.yml')
runtime=next(r['identifier'] for r in json.loads(run('xcrun','simctl','list','runtimes','--json'))['runtimes'] if r['isAvailable'] and r['name']=='iOS 26.2')
device=run('xcrun','simctl','create','Tilt Arena Action Screenshots','com.apple.CoreSimulator.SimDeviceType.iPhone-16-Pro-Max',runtime)
target=ROOT/'artifacts/action-target/native-ios';app=target/'DerivedData/Build/Products/Debug-iphonesimulator/TiltArena.app'
meta=dict(baseCommit=BASE,captureCommit=os.environ.get('GITHUB_SHA'),run=os.environ.get('GITHUB_RUN_ID'),version='0.5.8',build='1',device='iPhone 16 Pro Max simulator',runtime=runtime,fixtures=False,spawning=True,controls='Verified normal-input replay',mask='ignored',independentSceneRuns=True,ipaGenerated=False,appleUpload=False,captures=[])
def start(language):
    subprocess.run(['xcrun','simctl','uninstall',device,'com.dmkr.tiltarena'],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
    run('xcrun','simctl','install',device,str(app))
    run('xcrun','simctl','launch',device,'com.dmkr.tiltarena','--capture-action','--theme-ink-qa','-AppleLanguages',f'({language})','-AppleLocale','es_ES' if language=='es' else 'en_US')
    docs=pathlib.Path(run('xcrun','simctl','get_app_container',device,'com.dmkr.tiltarena','data'))/'Documents'
    deadline=time.monotonic()+45
    while not (docs/'capture-ready.json').exists():
        if time.monotonic()>deadline:raise TimeoutError('Native capture ready')
        time.sleep(.2)
    time.sleep(1)
    return docs
try:
    run('xcrun','simctl','boot',device);run('xcrun','simctl','bootstatus',device,'-b')
    run('xcodegen','generate',cwd=target)
    print('Building simulator-only capture adapter',flush=True)
    with (OUT/'simulator-build.log').open('w') as log:
        subprocess.run(['xcodebuild','-project','TiltArena.xcodeproj','-scheme','TiltArena','-configuration','Debug','-sdk','iphonesimulator','-destination',f'platform=iOS Simulator,id={device}','-derivedDataPath','DerivedData','CODE_SIGNING_ALLOWED=NO','build'],cwd=target,stdout=log,stderr=subprocess.STDOUT,check=True)
    assert (app/'classic-core.js').read_bytes()==(ROOT/'native-ios/Resources/classic-core.js').read_bytes()
    info=plistlib.loads((app/'Info.plist').read_bytes());assert info['UIDeviceFamily']==[1]
    shutil.copyfile(ROOT/'artifacts/action-target/provenance.json',OUT/'source-provenance.json')
    docs=start('en');shutil.copyfile(docs/'capture-ready.json',OUT/'native-viewport.json')
    print('Finding natural replays at actual native bounds',flush=True)
    subprocess.run(['node','capture/action-preflight.cjs',str(OUT/'native-viewport.json'),str(OUT/'replays')],check=True)
    run('xcrun','simctl','terminate',device,'com.dmkr.tiltarena')
    scenes={k:json.loads((OUT/'replays'/f'{k}.json').read_text()) for k in ['fire','ice','pressure','wave']}
    groups={name:[(name,scene)] for name,scene in scenes.items()}
    for language in ['en','es']:
        for _,shots in groups.items():
            seed=shots[0][1]['seed']
            docs=start(language)
            current=json.loads((docs/'capture-ready.json').read_text())['bounds']
            assert current==next(iter(scenes.values()))['bounds'],current
            shots.sort(key=lambda p:p[1]['step']);longest=shots[-1][1]
            config=dict(seed=seed,inputs=longest['inputs'],shots=[dict(name=n,step=s['step']) for n,s in shots])
            (docs/'capture-config.json').write_text(json.dumps(config));(docs/'capture-go').touch()
            deadline=time.monotonic()+len(longest['inputs'])/60*4+60;received=set()
            print(f'Replaying {language}, seed {seed}: {[n for n,_ in shots]}',flush=True)
            while len(received)<len(shots):
                if (docs/'capture-error.json').exists():raise RuntimeError((docs/'capture-error.json').read_text())
                request=docs/'capture-request.json'
                if request.exists():
                    shot=json.loads(request.read_text());name=shot['name'];assert name not in received
                    time.sleep(.15)
                    image=OUT/f'{language}-{name}.png'
                    run('xcrun','simctl','io',device,'screenshot','--mask','ignored',str(image))
                    frame=OUT/f'{language}-{name}-native.json';shutil.copyfile(docs/f'capture-{name}.json',frame)
                    shutil.copyfile(docs/f'capture-{name}-timing.json',OUT/f'{language}-{name}-timing.json')
                    meta['captures'].append(dict(language=language,name=name,seed=seed,step=shot['step'],file=image.name,sha256=hashlib.sha256(image.read_bytes()).hexdigest(),nativeFrame=frame.name))
                    received.add(name);request.unlink()
                    if len(received)<len(shots):(docs/'capture-resume').touch()
                if time.monotonic()>deadline:raise TimeoutError(f'Replay {language}/{seed}')
                time.sleep(.1)
            run('xcrun','simctl','terminate',device,'com.dmkr.tiltarena')
    # Compare all captured native simulation snapshots with independently replayed Node snapshots.
    run('node','capture/action-verify.cjs',str(OUT))
    meta['verified']=True
finally:
    (OUT/'capture-provenance.json').write_text(json.dumps(meta,indent=2))
    subprocess.run(['xcrun','simctl','shutdown',device])

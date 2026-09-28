"""Apply capture-input and snapshot hooks to an isolated simulator source copy."""
import hashlib, json, pathlib, shutil, sys
source = pathlib.Path('native-ios')
target = pathlib.Path(sys.argv[1] if len(sys.argv)>1 else 'artifacts/action-target/native-ios')
assert not target.exists()
shutil.copytree(source, target, ignore=shutil.ignore_patterns('*.xcodeproj','DerivedData'))
patches=[]
def patch(name,old,new):
    p=target/'Sources'/name
    s=p.read_text();assert s.count(old)==1,(name,old)
    p.write_text(s.replace(old,new));patches.append(dict(file=name,before=old,after=new))
patch('ClassicScene.swift','private var bridge: ClassicBridge?','private var bridge: ClassicBridge?\n    private let actionCapture = ActionCapture()')
patch('ClassicScene.swift','configureViewport(viewSize: view.bounds.size, insets: view.window?.safeAreaInsets ?? .zero)',
      'configureViewport(viewSize: view.bounds.size, insets: view.window?.safeAreaInsets ?? .zero)\n        ActionCapture.waitForStart(scene: self)')
patch('ClassicScene.swift','gameFrame = try bridge?.create(spawning: !uiTesting || ProcessInfo.processInfo.arguments.contains("--hard-opening-qa"), mode: session.mode)',
      'gameFrame = ActionCapture.enabled ? try bridge?.create(seed: ActionCapture.configuration.seed, spawning: true, mode: .classic) : try bridge?.create(spawning: !uiTesting || ProcessInfo.processInfo.arguments.contains("--hard-opening-qa"), mode: session.mode)')
patch('ClassicScene.swift','let dt = lastTime.map { currentTime - $0 } ?? 0; lastTime = currentTime',
      'let dt = ActionCapture.enabled ? actionCapture.beginFrame(currentTime, scene: self) : (lastTime.map { currentTime - $0 } ?? 0); lastTime = currentTime')
patch('ClassicScene.swift','input = touchVector','input = ActionCapture.enabled ? actionCapture.nextInput() : touchVector')
patch('ClassicScene.swift','    private func render(', '    override func didFinishUpdate() {\n        if ActionCapture.enabled, session?.phase == .running, let frame = gameFrame {\n            actionCapture.record(frame, raw: bridge?.captureLastJSON ?? "{}", scene: self)\n        }\n    }\n    private func render(')
patch('ClassicBridge.swift','private let decoder = JSONDecoder()', 'private let decoder = JSONDecoder()\n    private(set) var captureLastJSON = "{}"')
patch('ClassicBridge.swift','return result\n    }\n    private func decode',
      'if ["create", "resize", "tick"].contains(name) { captureLastJSON = result.toString() }\n        return result\n    }\n    private func decode')
shutil.copyfile('capture/ActionCapture.swift',target/'Sources/ActionCapture.swift')
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
original={p.relative_to(source).as_posix():sha(p) for p in source.rglob('*') if p.is_file() and ('Resources' in p.parts or 'Sources' in p.parts)}
modified={name:sha(target/name) for name in original if sha(target/name)!=original[name]}
assert set(modified)=={'Sources/ClassicScene.swift','Sources/ClassicBridge.swift'}
renderer=(source/'Sources/ClassicScene.swift').read_text().split('    private func render(')[1]
assert (target/'Sources/ClassicScene.swift').read_text().split('    private func render(')[1]==renderer
(target.parent/'provenance.json').write_text(json.dumps(dict(originalHashes=original,changedCaptureAdapterFiles=modified,exactPatch=patches,resourcesIdentical=True,renderMethodAndFollowingCodeIdentical=True,byteIdenticalToDistributedApp=False),indent=2))
print('Only simulator input/replay/capture hooks differ; production engine/assets/render unchanged.',flush=True)

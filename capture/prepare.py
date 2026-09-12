"""Create an isolated simulator target; canonical production source stays untouched."""
import hashlib, json, pathlib, shutil, sys

source = pathlib.Path('native-ios')
target = pathlib.Path('artifacts/capture-target/native-ios')
assert not target.exists(), 'Use a fresh target; never overwrite another capture'
shutil.copytree(source, target, ignore=shutil.ignore_patterns('*.xcodeproj', 'DerivedData'))
def patch(name, old, new):
    path = target / 'Sources' / name
    text = path.read_text(encoding='utf-8')
    assert text.count(old) == 1, (name, old)
    path.write_text(text.replace(old, new), encoding='utf-8')
patch('ClassicScene.swift', 'private var bridge: ClassicBridge?', 'private var bridge: ClassicBridge?\n    private let captureHarness = CaptureHarness()')
patch('ClassicScene.swift', 'configureViewport(viewSize: view.bounds.size, insets: view.window?.safeAreaInsets ?? .zero)', '''configureViewport(viewSize: view.bounds.size, insets: view.window?.safeAreaInsets ?? .zero)
        if CaptureHarness.enabled {
            CaptureHarness.waitForStart { [weak self] in
                guard let self = self else { return }
                self.session?.posture = .normal
                self.play(restart: true)
            }
        }''')
patch('ClassicScene.swift', 'gameFrame = try bridge?.create(spawning: !uiTesting)', 'gameFrame = CaptureHarness.enabled ? try bridge?.create(seed: CaptureHarness.seed, spawning: true) : try bridge?.create(spawning: !uiTesting)')
patch('ClassicScene.swift', 'lastTime = nil; touchOrigin = nil; touchVector = (0, 0)', '''lastTime = nil; touchOrigin = nil; touchVector = (0, 0)
            if CaptureHarness.enabled { captureHarness.start(bounds: arenaBounds, screen: view?.bounds.size ?? .zero) }''')
patch('ClassicScene.swift', 'input = touchVector', 'input = CaptureHarness.enabled ? try bridge?.captureInput(bounds: arenaBounds) ?? (0,0) : touchVector')
patch('ClassicScene.swift', 'gameFrame = next; render(next)', '''gameFrame = next; render(next)
                if CaptureHarness.enabled { captureHarness.record(next, raw: bridge?.captureLastJSON ?? "{}", input: input, dt: dt) }''')
patch('ClassicBridge.swift', 'private let decoder = JSONDecoder()', 'private let decoder = JSONDecoder()\n    private(set) var captureLastJSON = "{}"\n    private var captureDriverLoaded = false')
patch('ClassicBridge.swift', 'private func call(_ name: String, _ args: [Any]) throws -> JSValue {', '''func captureInput(bounds: CGRect) throws -> (Double, Double) {
        if !captureDriverLoaded {
            guard let url = Bundle.main.url(forResource: "capture-driver", withExtension: "js") else { throw Failure.missingEngine }
            context.evaluateScript(try String(contentsOf: url, encoding: .utf8))
            captureDriverLoaded = true
        }
        let b = "{left:\\(bounds.minX),right:\\(bounds.maxX),bottom:\\(bounds.minY),top:\\(bounds.maxY)}"
        guard let value = context.evaluateScript("CaptureDriver.next(\\(captureLastJSON),\\(b))"),
              let result = value.toArray() as? [Double], result.count == 2 else { throw Failure.invalidFrame }
        if let exception = context.exception { throw Failure.script(exception.toString()) }
        return (result[0], result[1])
    }
    private func call(_ name: String, _ args: [Any]) throws -> JSValue {''')
# Cache the result of normal API calls without another tick or state mutation.
patch('ClassicBridge.swift', 'return result\n    }\n    private func decode', 'if ["create", "resize", "tick"].contains(name) { captureLastJSON = result.toString() }\n        return result\n    }\n    private func decode')
shutil.copyfile('capture/CaptureHarness.swift', target/'Sources/CaptureHarness.swift')
shutil.copyfile('capture/driver.js', target/'Resources/capture-driver.js')
hashes = {p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in (source/'Resources').glob('*') if p.is_file()}
for name, digest in hashes.items():
    assert hashlib.sha256((target/'Resources'/name).read_bytes()).hexdigest() == digest
pathlib.Path('artifacts/capture-target/source-resources.json').write_text(json.dumps(hashes,indent=2)+'\n')
print('Isolated input/capture overlay prepared; all production resources identical.')

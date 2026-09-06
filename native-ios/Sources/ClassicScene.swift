import SpriteKit
import CoreMotion
import UIKit

final class ClassicScene: SKScene {
    weak var session: GameSession?
    let sound = ClassicSound()
    var reduceEffects = false
    private let motion = CMMotionManager()
    private var bridge: ClassicBridge?
    private let world = SKNode(), effects = SKNode(), hud = SKNode()
    private let arenaDecoration = SKNode()
    private lazy var vfx = ClassicVFX(layer: effects)
    private(set) var arenaBounds = CGRect(x: 24, y: 52, width: 912, height: 540)
    private var objects: [String: SKNode] = [:], textures: [String: SKTexture] = [:]
    private let arrow = SKNode()
    private var bubble = SKShapeNode(), spikes = SKShapeNode()
    private let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    private let comboLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let bestLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
    private let comboBar = SKSpriteNode(color: UIColor(hex: "d5f56b"), size: CGSize(width: 240, height: 3))
    private var gameFrame: ClassicFrame?, lastTime: Double?
    private var calibratedOrientation: UIInterfaceOrientation = .unknown
    private var samples: [(x: Double, y: Double)] = []
    private var calibrationStart = 0.0, motionTimestamp = -1.0
    private var restartAfterCalibration = true
    private var touchVector = (x: 0.0, y: 0.0), touchOrigin: CGPoint?
    private var calibrationFrames = 0
    private var calibrationReturnPhase: GameSession.Phase = .menu
    private var sensorGraceUntil = 0.0
    private var trailTime = 0.0
    #if DEBUG
    private let uiTesting = ProcessInfo.processInfo.arguments.contains("--ui-testing")
    private let visualPreview = ProcessInfo.processInfo.arguments.contains("--visual-qa")
    #endif

    override init() {
        super.init(size: CGSize(width: 960, height: 640))
        scaleMode = .aspectFit; backgroundColor = UIColor(hex: "16260f")
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }
    override func didMove(to view: SKView) {
        guard world.parent == nil else { return }
        view.preferredFramesPerSecond = 60; isUserInteractionEnabled = true
        addChild(world); addChild(hud); addChild(effects)
        world.zPosition = 0; effects.zPosition = 5; hud.zPosition = 10
        world.addChild(arenaDecoration)
        drawArena(); drawPlayer(); drawHUD(); startMotion()
        configureViewport(viewSize: view.bounds.size, insets: view.window?.safeAreaInsets ?? .zero)
    }
    func configureViewport(viewSize: CGSize, insets: UIEdgeInsets) {
        guard viewSize.width > 0, viewSize.height > 0 else { return }
        let scale = 640 / viewSize.height
        let nextSize = CGSize(width: viewSize.width * scale, height: 640)
        let side = max(insets.left, insets.right) * scale + 20
        let nextBounds = CGRect(x: side, y: max(52, insets.bottom * scale + 26),
            width: nextSize.width - 2 * side, height: 0)
        let rect = CGRect(x: nextBounds.minX, y: nextBounds.minY, width: nextBounds.width,
                          height: 592 - nextBounds.minY)
        guard rect.width >= 300, rect.height >= 300, size != nextSize || arenaBounds != rect else { return }
        size = nextSize; arenaBounds = rect
        if arenaDecoration.parent != nil { drawArena(); layoutHUD() }
        if gameFrame != nil {
            do { gameFrame = try resizeEngine(); if let frame = gameFrame { render(frame) } }
            catch { session?.fail(error) }
        } else { arrow.position = CGPoint(x: arenaBounds.midX, y: arenaBounds.midY) }
    }
    private func resizeEngine() throws -> ClassicFrame? {
        try bridge?.resize(left: arenaBounds.minX, right: arenaBounds.maxX,
                           bottom: arenaBounds.minY, top: arenaBounds.maxY)
    }
    override func willMove(from view: SKView) { motion.stopDeviceMotionUpdates(); sound.pause() }
    func startMotion() {
        guard motion.isDeviceMotionAvailable, !motion.isDeviceMotionActive else { return }
        motion.deviceMotionUpdateInterval = 1.0 / 60
        motion.startDeviceMotionUpdates(using: .xArbitraryZVertical)
    }
    func calibrate(restart: Bool) {
        guard let session = session else { return }
        do { if bridge == nil { bridge = try ClassicBridge() } }
        catch { session.fail(error); return }
        calibrationReturnPhase = session.phase
        startMotion(); restartAfterCalibration = restart
        samples = []; calibrationFrames = 0; motionTimestamp = -1
        calibrationStart = ProcessInfo.processInfo.systemUptime
        calibratedOrientation = view?.window?.windowScene?.interfaceOrientation ?? .landscapeLeft
        session.message = "Mantén el iPhone quieto y cómodo un instante."
        #if targetEnvironment(simulator)
        session.message = "Simulador: arrastra desde cualquier punto para mover la flecha."
        #else
        guard motion.isDeviceMotionAvailable else {
            session.message = "Este dispositivo no ofrece el sensor de movimiento necesario."
            session.phase = .failed; return
        }
        #endif
        session.phase = .calibrating
    }
    private func sampleCalibration() {
        let orientation = view?.window?.windowScene?.interfaceOrientation ?? calibratedOrientation
        if orientation != calibratedOrientation {
            calibratedOrientation = orientation; samples = []; calibrationFrames = 0
        }
        #if targetEnvironment(simulator)
        calibrationFrames += 1
        if calibrationFrames > 45 { beginAfterCalibration() }
        #else
        let now = ProcessInfo.processInfo.systemUptime
        if let m = motion.deviceMotion, m.timestamp != motionTimestamp {
            motionTimestamp = m.timestamp; samples.append((m.gravity.x, m.gravity.y))
            if samples.count > 45 { samples.removeFirst() }
            if samples.count == 45 {
                let nx = samples.map(\.x).reduce(0, +) / 45, ny = samples.map(\.y).reduce(0, +) / 45
                let spread = samples.map { hypot($0.x - nx, $0.y - ny) }.max() ?? 1
                if spread < 0.025 {
                    session?.saveCustom(TiltProfile.sampled(x: nx, y: ny, landscapeRight: calibratedOrientation == .landscapeRight))
                    beginAfterCalibration(); return
                }
            }
        }
        if now - calibrationStart > 12 {
            session?.message = samples.isEmpty
                ? "No llega información del sensor. Revisa los permisos de movimiento en Ajustes y vuelve a intentarlo."
                : "No se ha podido fijar una postura estable. Apoya los brazos y vuelve a intentarlo."
            session?.phase = .failed
        }
        #endif
    }
    private func beginAfterCalibration() {
        #if targetEnvironment(simulator)
        session?.saveCustom(.preset(.normal))
        #endif
        play(restart: restartAfterCalibration)
    }
    func cancelCalibration() {
        session?.phase = calibrationReturnPhase == .paused ? .paused : .menu
        session?.message = ""
    }
    func play(restart: Bool) {
        guard let session = session else { return }
        if session.posture == .custom && !session.hasCustom { calibrate(restart: restart); return }
        startMotion()
        calibratedOrientation = view?.window?.windowScene?.interfaceOrientation ?? .landscapeLeft
        sensorGraceUntil = ProcessInfo.processInfo.systemUptime + 1
        do {
            if bridge == nil { bridge = try ClassicBridge() }
            if restart {
                for node in objects.values { node.removeFromParent() }; objects.removeAll()
                effects.removeAllChildren()
                #if DEBUG
                gameFrame = try bridge?.create(spawning: !uiTesting)
                #else
                gameFrame = try bridge?.create()
                #endif
                gameFrame = try resizeEngine()
                #if DEBUG
                if visualPreview { gameFrame = try bridge?.visualFrame(left: arenaBounds.minX, right: arenaBounds.maxX) }
                #endif
            } else { try bridge?.resume(); gameFrame = try bridge?.tick(dt: 0, x: 0, y: 0) }
            lastTime = nil; touchOrigin = nil; touchVector = (0, 0)
            world.isPaused = false; effects.isPaused = false
            session.message = ""; session.phase = .running
            if let frame = gameFrame { render(frame) }; sound.playMusic()
        } catch { session.fail(error) }
    }
    func pauseRun(message: String = "") {
        guard session?.phase == .running else { return }
        do { try bridge?.pause() } catch { session?.fail(error); return }
        halt(); session?.message = message; session?.phase = .paused
    }
    func halt() {
        lastTime = nil; touchVector = (0,0); touchOrigin = nil
        world.isPaused = true; effects.isPaused = true; sound.pause()
    }
    func suspend() {
        if session?.phase == .running { pauseRun() }
        else if session?.phase == .calibrating { cancelCalibration() }
        motion.stopDeviceMotionUpdates()
    }
    func menu() { halt(); session?.phase = .menu; session?.message = ""; startMotion() }
    func finishPausedRun() {
        do { if let result = try bridge?.finish() { gameFrame = result; session?.finish(result) } }
        catch { session?.fail(error) }
    }
    override func update(_ currentTime: TimeInterval) {
        guard let session = session else { return }
        if session.phase == .calibrating { sampleCalibration(); lastTime = nil; return }
        guard session.phase == .running else { lastTime = nil; return }
        #if DEBUG
        if visualPreview, let frame = gameFrame {
            render(frame)
            if currentTime - trailTime > 0.65 {
                trailTime = currentTime
                vfx.show(ClassicFrame.Event(kind: "blast", x: arenaBounds.minX + 150, y: 200, radius: 90, angle: nil, toX: nil, toY: nil, color: "ffb52a", power: nil, value: nil, bonus: nil), reduced: reduceEffects)
                vfx.show(ClassicFrame.Event(kind: "lightning", x: arenaBounds.midX - 70, y: 160, radius: nil, angle: nil, toX: arenaBounds.midX + 70, toY: 260, color: "eeefff", power: nil, value: nil, bonus: nil), reduced: reduceEffects)
            }
            return
        }
        #endif
        let orientation = view?.window?.windowScene?.interfaceOrientation ?? calibratedOrientation
        if orientation != calibratedOrientation {
            calibratedOrientation = orientation
            pauseRun(message: "Has girado el iPhone. Pulsa Reanudar cuando estés cómodo."); return
        }
        let dt = lastTime.map { currentTime - $0 } ?? 0; lastTime = currentTime
        do {
            var input = (0.0, 0.0)
            #if targetEnvironment(simulator)
            input = touchVector
            #else
            guard let m = motion.deviceMotion, ProcessInfo.processInfo.systemUptime - m.timestamp < 0.5 else {
                if ProcessInfo.processInfo.systemUptime < sensorGraceUntil { lastTime = nil; return }
                pauseRun(message: "Esperando al sensor. Pulsa Reanudar para volver a intentarlo."); return
            }
            let delta = session.activeProfile.motionDelta(x: m.gravity.x, y: m.gravity.y, z: m.gravity.z,
                                                         landscapeRight: orientation == .landscapeRight)
            input = try bridge?.tilt(gx: delta.x, gy: delta.y, nx: 0, ny: 0,
                orientation: orientation == .landscapeRight ? "landscapeRight" : "landscapeLeft",
                sensitivity: session.sensitivity) ?? (0,0)
            #endif
            if let next = try bridge?.tick(dt: dt, x: input.0, y: input.1) {
                gameFrame = next; render(next)
                if next.state == "gameOver" { halt(); effects.isPaused = false; session.finish(next); sound.play("death") }
            }
        } catch { session.fail(error) }
    }
    #if targetEnvironment(simulator)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard session?.phase == .running else { return }; touchOrigin = touches.first?.location(in: self)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard session?.phase == .running, let origin = touchOrigin, let point = touches.first?.location(in: self) else { return }
        let dx = Double(point.x-origin.x)/70, dy = Double(point.y-origin.y)/70
        let magnitude = max(1, hypot(dx,dy)); touchVector = (dx/magnitude,dy/magnitude)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) { touchVector=(0,0);touchOrigin=nil }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) { touchVector=(0,0);touchOrigin=nil }
    #endif

    private func drawArena() {
        arenaDecoration.removeAllChildren()
        let background = SKSpriteNode(texture: ClassicArt.background(size: size))
        background.position = CGPoint(x:size.width/2,y:size.height/2);background.zPosition = -10;arenaDecoration.addChild(background)
        let border = SKShapeNode(rect: arenaBounds,cornerRadius:16)
        border.strokeColor = UIColor(hex:"e3efc9").withAlphaComponent(0.65);border.lineWidth=2
        border.fillColor = .clear;arenaDecoration.addChild(border)
    }
    private func drawPlayer() {
        arrow.addChild(ClassicArt.node(style:"arrow"));arrow.zPosition=4
        arrow.position=CGPoint(x:480,y:320);world.addChild(arrow)
        bubble = SKShapeNode(circleOfRadius:26);bubble.strokeColor=UIColor(hex:"7bde83")
        bubble.lineWidth=3;bubble.fillColor=UIColor(hex:"7bde83").withAlphaComponent(0.12);arrow.addChild(bubble)
        spikes = SKShapeNode(path:ClassicArt.star(radius:35,inner:24,points:12))
        spikes.strokeColor=UIColor(hex:"b5d8ff");spikes.lineWidth=2;spikes.fillColor = .clear;arrow.addChild(spikes)
        bubble.isHidden=true;spikes.isHidden=true
    }
    private func drawHUD() {
        for label in [scoreLabel,comboLabel,bestLabel] {
            label.fontColor=UIColor(hex:"f0f5d9");label.fontSize=22
            label.verticalAlignmentMode = .center;hud.addChild(label)
        }
        scoreLabel.position=CGPoint(x:30,y:615);scoreLabel.horizontalAlignmentMode = .left;scoreLabel.text="0"
        bestLabel.position=CGPoint(x:930,y:615);bestLabel.horizontalAlignmentMode = .right
        bestLabel.fontSize=16;bestLabel.text="RÉCORD  \(session?.best ?? 0)"
        comboLabel.position=CGPoint(x:30,y:28);comboLabel.horizontalAlignmentMode = .left;comboLabel.fontSize=18
        comboLabel.text="ENLAZA LAS ARMAS"
        comboBar.anchorPoint=CGPoint(x:0,y:0.5);comboBar.position=CGPoint(x:30,y:12);hud.addChild(comboBar)
        layoutHUD()
    }
    private func layoutHUD() {
        scoreLabel.position = CGPoint(x: arenaBounds.minX + 6, y: 615)
        bestLabel.position = CGPoint(x: arenaBounds.maxX - 72, y: 615)
        comboLabel.position = CGPoint(x: arenaBounds.minX + 6, y: arenaBounds.minY - 23)
        comboBar.position = CGPoint(x: arenaBounds.minX + 6, y: arenaBounds.minY - 39)
    }
    private func sprite(key: String, style: String) -> SKNode {
        if let node = objects[key] { return node }
        let node: SKNode
        if style == "dot" { node = ClassicArt.node(style: style) }
        else if let cached = textures[style] { node=SKSpriteNode(texture:cached) }
        else {
            let shape=ClassicArt.node(style:style)
            if let rendered=view?.texture(from:shape) { textures[style]=rendered;node=SKSpriteNode(texture:rendered) }
            else { node=shape }
        }
        node.name=style;world.addChild(node);objects[key]=node
        if style == "missileShot" { vfx.attachMissileTrail(to: node, reduced: reduceEffects) }
        return node
    }
    private func render(_ frame: ClassicFrame) {
        var alive=Set<String>()
        for dot in frame.enemies {
            let key="d\(dot.id)";alive.insert(key)
            let node=sprite(key:key,style:"dot");node.position=CGPoint(x:dot.x,y:dot.y)
            (node as? SKShapeNode)?.fillColor = UIColor(hex: dot.frozen ? "70dce9" : "ff5658")
            node.alpha=dot.telegraph ? 0.22+0.12*sin(frame.time*18) : (dot.thawing ? 0.65+0.35*sin(frame.time*22) : 1)
            node.setScale(dot.telegraph ? 1.45 : 1);node.zPosition=2
        }
        for orb in frame.pickups {
            let key="o\(orb.id)";alive.insert(key)
            let node=sprite(key:key,style:orb.power);node.position=CGPoint(x:orb.x,y:orb.y);node.zPosition=3
            node.setScale(reduceEffects ? 1 : 1+0.04*sin(frame.time*4+Double(orb.id)))
            node.alpha=orb.remaining<2 ? 0.55+0.45*sin(frame.time*10) : 1
        }
        for shot in frame.projectiles {
            let key="p\(shot.id)";alive.insert(key)
            let node=sprite(key:key,style:shot.kind == "wave" ? "waveShot" : "missileShot")
            node.position=CGPoint(x:shot.x,y:shot.y);node.zRotation=shot.angle;node.zPosition=3
        }
        for field in frame.fields {
            let key="f\(field.id)";alive.insert(key)
            let node=sprite(key:key,style:field.kind == "vortex" ? "vortexField" : "fire")
            node.position=CGPoint(x:field.x,y:field.y);node.zPosition=1
            node.alpha=min(0.8,field.remaining);node.zRotation=reduceEffects ? 0 : frame.time*2
        }
        for key in Array(objects.keys) where !alive.contains(key) { objects.removeValue(forKey:key)?.removeFromParent() }
        arrow.position=CGPoint(x:frame.player.x,y:frame.player.y);arrow.zRotation=frame.player.angle
        bubble.isHidden = !frame.player.bubble;spikes.isHidden=frame.player.spikesUntil<=frame.time
        scoreLabel.text="\(frame.score.formatted())"
        comboLabel.text=frame.combo>0 ? "COMBO  \(frame.comboBase) × \(frame.combo)" : "ENLAZA LAS ARMAS"
        comboBar.xScale=frame.comboRemaining;bestLabel.text="RÉCORD  \(max(session?.best ?? 0,frame.score).formatted())"
        var particles=0
        for event in frame.events {
            if event.kind == "kill" { if particles<12 { showEffect(event);particles+=1 } }
            else { showEffect(event) }
        }
        if frame.events.contains(where:{$0.kind=="pickup"}) { sound.play("pickup") }
        else if frame.events.contains(where:{$0.kind=="kill"}) { sound.play("hit") }
    }
    private func showEffect(_ event: ClassicFrame.Event) { vfx.show(event, reduced: reduceEffects) }
}

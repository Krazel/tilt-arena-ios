import SpriteKit
import CoreMotion
import UIKit

final class ClassicScene: SKScene {
    weak var session: GameSession?
    let sound = ClassicSound()
    var reduceEffects = false
    private(set) var theme = VisualTheme.read()
    private let motion = CMMotionManager()
    private var bridge: ClassicBridge?
    private let world = SKNode(), effects = SKNode(), hud = SKNode()
    private let arenaDecoration = SKNode()
    private lazy var vfx = ClassicVFX(layer: effects)
    private(set) var arenaBounds = CGRect(x: 24, y: 52, width: 912, height: 540)
    private var objects: [String: SKNode] = [:], textures: [String: SKTexture] = [:]
    private var textureAnchors: [String: CGPoint] = [:]
    private var fireCharge = ThemedCharge(.fire, theme: VisualTheme.read())
    private var waveCharge = ThemedCharge(.wave, theme: VisualTheme.read())
    private var boomerangCharge = ThemedCharge(.boomerang, theme: VisualTheme.read())
    private let arrow = SKNode()
    private var bubble = SKShapeNode()
    private var spikes = ClassicSpikes(theme: VisualTheme.read())
    private let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    private let comboLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let bestLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
    private let comboBar = SKSpriteNode(color: UIColor(hex: "d5f56b"), size: CGSize(width: 240, height: 3))
    private var gameFrame: ClassicFrame?, lastTime: Double?
    private var calibratedOrientation: UIInterfaceOrientation = .unknown
    private var calibrationStart = 0.0
    private var restartAfterCalibration = true
    private var touchVector = (x: 0.0, y: 0.0), touchOrigin: CGPoint?
    private var calibrationReturnPhase: GameSession.Phase = .menu
    private var sensorGraceUntil = 0.0
    private var trailTime = 0.0
    #if DEBUG
    var frameForVerification: ClassicFrame? { gameFrame }
    private let uiTesting = ProcessInfo.processInfo.arguments.contains("--ui-testing")
    private let lingeringAreasPreview = ProcessInfo.processInfo.arguments.contains("--lingering-areas-qa")
    private let visualPreview = ProcessInfo.processInfo.arguments.contains("--visual-qa")
    private let freezeVFXPreview = ProcessInfo.processInfo.arguments.contains("--freeze-vfx-qa")
    private let selectedVFXPreview = ProcessInfo.processInfo.arguments.contains("--selected-vfx-qa")
    private let chargeVFXPreview = ProcessInfo.processInfo.arguments.contains("--charge-vfx-qa")
    private let waveVFXPreview = ProcessInfo.processInfo.arguments.contains("--wave-vfx-qa")
    private let turnFirePreview = ProcessInfo.processInfo.arguments.contains("--turn-fire-qa")
    private let spikesPreview = ProcessInfo.processInfo.arguments.contains("--spikes-vfx-qa")
    private let spikesWarningPreview = ProcessInfo.processInfo.arguments.contains("--spikes-warning-qa")
    private let newPowersPreview = ProcessInfo.processInfo.arguments.contains("--new-powers-qa")
    private let bouncingPreview = ProcessInfo.processInfo.arguments.contains("--bouncing-qa")
    private let recaughtPreview = ProcessInfo.processInfo.arguments.contains("--recaught-qa")
    private let boomerangChargePreview = ProcessInfo.processInfo.arguments.contains("--boomerang-charge-qa")
    private let electricityPreview = ProcessInfo.processInfo.arguments.contains("--electricity-qa")
    private let explosionPreview = ProcessInfo.processInfo.arguments.contains("--explosion-vfx-qa")
    private let explosionTailPreview = ProcessInfo.processInfo.arguments.contains("--explosion-tail-qa")
    private var previewStarted: Double?
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
        vfx.theme = theme
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
        calibrationStart = ProcessInfo.processInfo.systemUptime
        calibratedOrientation = view?.window?.windowScene?.interfaceOrientation ?? .landscapeLeft
        session.message = GameText.calibrationHold
        #if targetEnvironment(simulator)
        session.message = GameText.simulatorDrag
        #else
        guard motion.isDeviceMotionAvailable else {
            session.message = GameText.noMotionSensor
            session.phase = .failed; return
        }
        #endif
        session.phase = .calibrating
        // Core Motion is already running in the menu. Capture its current
        // filtered gravity now; wait only if the sensor has not produced it yet.
        sampleCalibration()
    }
    private func sampleCalibration() {
        let orientation = view?.window?.windowScene?.interfaceOrientation ?? calibratedOrientation
        calibratedOrientation = orientation
        #if targetEnvironment(simulator)
        beginAfterCalibration()
        #else
        let now = ProcessInfo.processInfo.systemUptime
        if let m = motion.deviceMotion,
           let profile = TiltProfile.capture(x: m.gravity.x, y: m.gravity.y, z: m.gravity.z,
                timestamp: m.timestamp, now: now, landscapeRight: calibratedOrientation == .landscapeRight) {
            session?.saveCustom(profile)
            beginAfterCalibration(); return
        }
        if now - calibrationStart > 2 {
            session?.message = GameText.sensorPermission
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
        guard session?.phase == .calibrating else { return }
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
                gameFrame = try bridge?.create(spawning: !uiTesting || ProcessInfo.processInfo.arguments.contains("--hard-opening-qa"), mode: session.mode)
                #else
                gameFrame = try bridge?.create(mode: session.mode)
                #endif
                gameFrame = try resizeEngine()
                #if DEBUG
                if lingeringAreasPreview { gameFrame = try bridge?.lingeringAreasFrame(left: arenaBounds.minX, right: arenaBounds.maxX) }
                if visualPreview { gameFrame = try bridge?.visualFrame(left: arenaBounds.minX, right: arenaBounds.maxX) }
                if spikesPreview { gameFrame = try bridge?.spikesVFXFrame(left: arenaBounds.minX, right: arenaBounds.maxX, warning: spikesWarningPreview) }
                if newPowersPreview { gameFrame = try bridge?.newPowersFrame(left: arenaBounds.minX, right: arenaBounds.maxX, bouncing: bouncingPreview, electricity: electricityPreview, charging: boomerangChargePreview, recaught: recaughtPreview) }
                if explosionPreview { gameFrame = try bridge?.explosionFrame(left: arenaBounds.minX, right: arenaBounds.maxX) }
                if selectedVFXPreview { gameFrame = try bridge?.selectedVFXFrame(left: arenaBounds.minX, right: arenaBounds.maxX, charging: chargeVFXPreview, wave: waveVFXPreview, turning: turnFirePreview) }
                #endif
            } else { try bridge?.resume(); gameFrame = try bridge?.tick(dt: 0, x: 0, y: 0) }
            lastTime = nil; touchOrigin = nil; touchVector = (0, 0)
            world.isPaused = false; effects.isPaused = false
            session.message = ""; session.phase = .running
            if let frame = gameFrame { render(frame) }; sound.playMusic()
            #if DEBUG
            if explosionPreview {
                let blast: SKNode
                if theme == .inkTide {
                    let ink = InkExplosion(radius: 155, color: InkArt.gold, reduced: reduceEffects)
                    ink.removeAllActions(); ink.update(elapsed: explosionTailPreview ? 0.4 : 0.16); blast = ink
                } else {
                    let original = ClassicExplosion(radius: 155, color: UIColor(hex: "ffb52a"), reduced: reduceEffects)
                    original.removeAllActions(); original.update(elapsed: explosionTailPreview ? 0.4 : 0.16); blast = original
                }
                blast.position = CGPoint(x: arenaBounds.minX + 280, y: 290); effects.addChild(blast)
            }
            #endif
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
        if explosionPreview || lingeringAreasPreview || ProcessInfo.processInfo.arguments.contains("--hard-opening-qa") { return }
        if newPowersPreview {
            // Rendered once by play(); don't replay transient events each frame.
            if previewStarted == nil { previewStarted = currentTime }
            if currentTime - (previewStarted ?? currentTime) >= 0.06 { effects.isPaused = true }
            return
        }
        if selectedVFXPreview || spikesPreview, let frame = gameFrame { render(frame); return }
        if visualPreview, let frame = gameFrame {
            render(frame)
            if freezeVFXPreview {
                if previewStarted == nil {
                    previewStarted = currentTime
                    vfx.show(ClassicFrame.Event(kind: "freeze", x: arenaBounds.minX + 230, y: 300, radius: 205, angle: nil, toX: nil, toY: nil, color: "72ddff", power: nil, value: nil, bonus: nil), reduced: reduceEffects)
                    vfx.show(ClassicFrame.Event(kind: "blast", x: arenaBounds.maxX - 220, y: 300, radius: 155, angle: nil, toX: nil, toY: nil, color: "ffb52a", power: nil, value: nil, bonus: nil), reduced: reduceEffects)
                }
                if currentTime - (previewStarted ?? currentTime) >= 0.22 { effects.isPaused = true }
                return
            }
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
            pauseRun(message: GameText.rotatedPhone); return
        }
        let dt = lastTime.map { currentTime - $0 } ?? 0; lastTime = currentTime
        do {
            var input = (0.0, 0.0)
            #if targetEnvironment(simulator)
            input = touchVector
            #else
            guard let m = motion.deviceMotion, ProcessInfo.processInfo.systemUptime - m.timestamp < 0.5 else {
                if ProcessInfo.processInfo.systemUptime < sensorGraceUntil { lastTime = nil; return }
                pauseRun(message: GameText.waitingForSensor); return
            }
            let delta = session.activeProfile.motionDelta(x: m.gravity.x, y: m.gravity.y, z: m.gravity.z,
                                                         landscapeRight: orientation == .landscapeRight)
            input = try bridge?.tilt(gx: delta.x, gy: delta.y, nx: 0, ny: 0,
                orientation: orientation == .landscapeRight ? "landscapeRight" : "landscapeLeft",
                sensitivity: 1) ?? (0,0)
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

    /// Rebuild presentation while retaining the exact paused simulation frame.
    func setTheme(_ next: VisualTheme) {
        guard next != theme else { return }
        theme = next; vfx.theme = next
        fireCharge = ThemedCharge(.fire, theme: next)
        waveCharge = ThemedCharge(.wave, theme: next)
        boomerangCharge = ThemedCharge(.boomerang, theme: next)
        spikes = ClassicSpikes(theme: next)
        guard world.parent != nil else { return }
        for node in objects.values { node.removeFromParent() }
        objects.removeAll(); textures.removeAll(); textureAnchors.removeAll()
        effects.removeAllChildren(); arrow.removeAllChildren(); arrow.removeFromParent()
        hud.removeAllChildren(); drawArena(); drawPlayer(); drawHUD()
        if let frame = gameFrame { render(frame, replayEvents: false) }
    }
    private func drawArena() {
        arenaDecoration.removeAllChildren()
        let background = SKSpriteNode(texture: theme == .inkTide ? InkArt.arena : ClassicArt.background(size: size))
        background.size = size
        background.position = CGPoint(x:size.width/2,y:size.height/2);background.zPosition = -10;arenaDecoration.addChild(background)
        let border = SKShapeNode(rect: arenaBounds,cornerRadius:16)
        border.strokeColor = theme == .inkTide ? InkArt.gold.withAlphaComponent(0.22) : UIColor(hex:"e3efc9").withAlphaComponent(0.65);border.lineWidth=theme == .inkTide ? 1 : 2
        border.fillColor = .clear;arenaDecoration.addChild(border)
    }
    private func drawPlayer() {
        fireCharge.zPosition = -0.1; arrow.addChild(fireCharge)
        waveCharge.zPosition = 0.1; arrow.addChild(waveCharge)
        boomerangCharge.zPosition = 0.2; arrow.addChild(boomerangCharge)
        arrow.addChild(ClassicArt.node(style:"arrow", theme: theme));arrow.zPosition=4
        arrow.position=CGPoint(x:480,y:320);world.addChild(arrow)
        bubble = SKShapeNode(circleOfRadius:32);bubble.strokeColor=UIColor(hex:"7bde83")
        bubble.lineWidth=3;bubble.fillColor=UIColor(hex:"7bde83").withAlphaComponent(0.12);arrow.addChild(bubble)
        bubble.glowWidth = 2
        if theme == .inkTide {
            bubble.path = InkArt.ringPath(radius: 32)
            bubble.strokeColor = InkArt.teal; bubble.fillColor = InkArt.teal.withAlphaComponent(0.08)
            bubble.lineWidth = 4; bubble.glowWidth = 0
        }
        arrow.addChild(spikes)
        bubble.isHidden=true;spikes.isHidden=true
    }
    private func drawHUD() {
        for label in [scoreLabel,comboLabel,bestLabel] {
            label.fontColor=theme == .inkTide ? InkArt.paper : UIColor(hex:"f0f5d9");label.fontSize=22
            label.fontName = theme == .inkTide ? "AvenirNextCondensed-Heavy" : (label === scoreLabel ? "AvenirNext-Heavy" : (label === bestLabel ? "AvenirNext-DemiBold" : "AvenirNext-Bold"))
            label.verticalAlignmentMode = .center;hud.addChild(label)
        }
        scoreLabel.position=CGPoint(x:30,y:615);scoreLabel.horizontalAlignmentMode = .left;scoreLabel.text="0"
        bestLabel.position=CGPoint(x:930,y:615);bestLabel.horizontalAlignmentMode = .right
        bestLabel.fontSize=16;bestLabel.text="\(GameText.best)  \(session?.best ?? 0)"
        comboLabel.position=CGPoint(x:30,y:28);comboLabel.horizontalAlignmentMode = .left;comboLabel.fontSize=18
        comboLabel.text=GameText.chainPowers
        comboBar.anchorPoint=CGPoint(x:0,y:0.5);comboBar.position=CGPoint(x:30,y:12);hud.addChild(comboBar)
        comboBar.color = theme == .inkTide ? InkArt.gold : UIColor(hex: "d5f56b")
        layoutHUD()
    }
    private func layoutHUD() {
        hud.children.filter { $0.name == "ink-hud-backing" }.forEach { $0.removeFromParent() }
        if theme == .inkTide {
            // Paper borders must never reduce the contrast of score or combo text.
            for rect in [CGRect(x: arenaBounds.minX, y: 600, width: 200, height: 30),
                         CGRect(x: arenaBounds.maxX - 292, y: 600, width: 228, height: 30),
                         CGRect(x: arenaBounds.minX, y: arenaBounds.minY - 45, width: 270, height: 37)] {
                let backing = SKShapeNode(rect: rect, cornerRadius: 3)
                backing.name = "ink-hud-backing"; backing.zPosition = -1
                backing.fillColor = UIColor(hex: "181817").withAlphaComponent(0.86)
                backing.strokeColor = .clear; hud.addChild(backing)
            }
        }
        scoreLabel.position = CGPoint(x: arenaBounds.minX + 6, y: 615)
        bestLabel.position = CGPoint(x: arenaBounds.maxX - 72, y: 615)
        comboLabel.position = CGPoint(x: arenaBounds.minX + 6, y: arenaBounds.minY - 23)
        comboBar.position = CGPoint(x: arenaBounds.minX + 6, y: arenaBounds.minY - 39)
    }
    private func sprite(key: String, style: String) -> SKNode {
        if let node = objects[key] { return node }
        let node: SKNode
        if style == "dot" { node = ClassicArt.node(style: style, theme: theme) }
        else if let cached = textures[style] { node=SKSpriteNode(texture:cached) }
        else {
            let shape=ClassicArt.node(style:style, theme: theme)
            let bounds = shape.calculateAccumulatedFrame()
            if let rendered=view?.texture(from:shape) {
                textures[style]=rendered;node=SKSpriteNode(texture:rendered)
                // Preserve authored origin for asymmetric crescents and flame tongues.
                textureAnchors[style]=CGPoint(x: -bounds.minX/bounds.width, y: -bounds.minY/bounds.height)
            }
            else { node=shape }
        }
        if let sprite = node as? SKSpriteNode, let anchor = textureAnchors[style] { sprite.anchorPoint = anchor }
        node.name=style;world.addChild(node);objects[key]=node
        if style == "missileShot" { vfx.attachMissileTrail(to: node, reduced: reduceEffects) }
        if style == "boomerangShot" { vfx.attachBoomerangTrail(to: node, reduced: reduceEffects) }
        return node
    }
    private func render(_ frame: ClassicFrame, replayEvents: Bool = true) {
        var alive=Set<String>()
        for dot in frame.enemies {
            let key="d\(dot.id)";alive.insert(key)
            let node=sprite(key:key,style:"dot"), previous = objects[key]?.position ?? .zero
            (node as? SKShapeNode)?.fillColor = UIColor(hex: dot.frozen ? "70dce9" : "ff5658")
            if theme == .inkTide, let ink = node as? SKSpriteNode {
                ink.color = InkArt.blue; ink.colorBlendFactor = dot.frozen ? 1 : 0
                let dx = dot.x - Double(previous.x), dy = dot.y - Double(previous.y)
                if ink.userData == nil { ink.zRotation = atan2(frame.player.y - dot.y, frame.player.x - dot.x) }
                else if !dot.frozen && hypot(dx, dy) > 0.05 { ink.zRotation = atan2(dy, dx) }
                if ink.userData == nil { ink.userData = NSMutableDictionary() }
            }
            node.position=CGPoint(x:dot.x,y:dot.y)
            node.alpha=dot.telegraph ? 0.22+0.12*sin(frame.time*18) : (dot.thawing ? 0.65+0.35*sin(frame.time*22) : 1)
            node.setScale(dot.telegraph ? 1.45 : 1);node.zPosition=3.5
        }
        for orb in frame.pickups {
            let key="o\(orb.id)";alive.insert(key)
            let node=sprite(key:key,style:orb.power);node.position=CGPoint(x:orb.x,y:orb.y);node.zPosition=3
            node.zRotation=reduceEffects ? 0 : orb.angle
            node.setScale((56.0 / 42.0) * (reduceEffects ? 1 : 1+0.04*sin(frame.time*4+Double(orb.id))))
            node.alpha=orb.remaining<2 ? 0.55+0.45*sin(frame.time*10) : 1
        }
        for shot in frame.projectiles {
            let key="p\(shot.id)";alive.insert(key)
            let style = shot.kind == "boomerang" ? "boomerangShot" : (shot.kind == "wave" ? "waveShot" : "missileShot")
            let node=sprite(key:key,style:style)
            node.position=CGPoint(x:shot.x,y:shot.y)
            node.zRotation=shot.kind == "boomerang" && !reduceEffects ? frame.time * 14 : shot.angle
            node.zPosition=3
        }
        for field in frame.fields {
            let key="f\(field.id)";alive.insert(key)
            if field.kind == "blast" || field.kind == "frost" {
                let node: ClassicAreaEffect
                if let existing = objects[key] as? ClassicAreaEffect { node = existing }
                else {
                    node = ClassicAreaEffect(kind: field.kind, radius: CGFloat(field.radius), theme: theme, reduced: reduceEffects)
                    world.addChild(node); objects[key] = node
                }
                node.position = CGPoint(x: field.x, y: field.y); node.zPosition = 1
                node.update(remaining: field.remaining, duration: field.duration)
                continue
            }
            let style = field.kind == "vortex" ? "vortexField" : "fire"
            let node=sprite(key:key,style:style)
            node.position=CGPoint(x:field.x,y:field.y);node.zPosition=1
            node.alpha=min(field.kind == "fire" ? 1 : 0.85,field.remaining)
            node.zRotation=field.kind != "vortex" ? field.angle : (reduceEffects ? 0 : frame.time * -1.7)
            if field.kind == "vortex" { node.setScale(field.radius / 200) }
            if field.kind == "fire" { node.yScale = reduceEffects ? 1 : 0.9 + 0.1 * sin(frame.time * 12 + Double(field.id)) }
        }
        for key in Array(objects.keys) where !alive.contains(key) { objects.removeValue(forKey:key)?.removeFromParent() }
        arrow.position=CGPoint(x:frame.player.x,y:frame.player.y);arrow.zRotation=frame.player.angle
        bubble.isHidden = !frame.player.bubble
        spikes.update(time: frame.time, until: frame.player.spikesUntil, heading: frame.player.angle, reduced: reduceEffects)
        bubble.glowWidth = reduceEffects || theme == .inkTide ? 0 : 2
        fireCharge.update(progress: frame.player.fireChargeProgress, active: frame.player.fireChargeUntil > frame.time, reduced: reduceEffects)
        waveCharge.update(progress: frame.player.waveChargeProgress, active: frame.player.waveCharging, reduced: reduceEffects)
        boomerangCharge.update(progress: frame.player.boomerangChargeProgress, active: frame.player.boomerangCharging, reduced: reduceEffects)
        scoreLabel.text="\(frame.score.formatted())"
        comboLabel.text=frame.combo>0 ? "COMBO  \(frame.comboBase) × \(frame.combo)" : GameText.chainPowers
        comboBar.xScale=frame.comboRemaining;bestLabel.text="\(GameText.best)  \(max(session?.best ?? 0,frame.score).formatted())"
        guard replayEvents else { return }
        var particles=0
        for event in frame.events {
            if event.kind == "kill" { if particles<12 { showEffect(event);particles+=1 } }
            else { showEffect(event) }
        }
        if frame.events.contains(where:{$0.kind=="pickup"}) { sound.play("pickup") }
        else if frame.events.contains(where:{$0.kind=="kill"}) { sound.play("hit") }
    }
    private func showEffect(_ event: ClassicFrame.Event) {
        // These powers are drawn from their live fields, so visuals cannot outlive damage.
        if event.kind == "freeze" || (event.kind == "blast" && event.power == "nuke") { return }
        vfx.show(event, reduced: reduceEffects)
    }
}

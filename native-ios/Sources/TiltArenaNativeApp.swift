import SwiftUI
import SpriteKit
import CoreMotion
import UIKit

@main
struct TiltArenaNativeApp: App {
  var body: some Scene {
    WindowGroup {
      GameView()
        .ignoresSafeArea()
        .statusBarHidden(true)
    }
  }
}

struct GameView: View {
  @State private var scene = TiltArenaScene()

  var body: some View {
    SpriteView(scene: scene, options: [.ignoresSiblingOrder])
      .ignoresSafeArea()
      .onAppear {
        scene.scaleMode = .resizeFill
      }
  }
}

final class TiltArenaScene: SKScene {
  private enum Mode {
    case menu
    case running
    case paused
    case gameOver
  }

  private enum Power: CaseIterable {
    case frost
    case missiles
    case vortex
    case shield
    case spikes
    case shock

    var color: UIColor {
      switch self {
      case .frost: return UIColor(red: 0.53, green: 0.72, blue: 0.76, alpha: 1)
      case .missiles: return UIColor(red: 0.77, green: 0.66, blue: 0.34, alpha: 1)
      case .vortex: return UIColor(red: 0.56, green: 0.47, blue: 0.66, alpha: 1)
      case .shield: return UIColor(red: 0.50, green: 0.67, blue: 0.43, alpha: 1)
      case .spikes: return UIColor(red: 0.91, green: 0.93, blue: 0.82, alpha: 1)
      case .shock: return UIColor(red: 0.53, green: 0.72, blue: 0.76, alpha: 1)
      }
    }

    var duration: TimeInterval {
      switch self {
      case .frost: return 0
      case .missiles: return 0
      case .vortex: return 3.5
      case .shield: return 6.5
      case .spikes: return 5.5
      case .shock: return 0
      }
    }
  }

  private struct Enemy {
    let node: SKNode
    let radius: CGFloat
    var speed: CGFloat
    var elite: Bool
    var frozenUntil: TimeInterval
  }

  private struct Pickup {
    let node: SKNode
    let power: Power
    let radius: CGFloat
    let expiresAt: TimeInterval
  }

  private let motionManager = CMMotionManager()
  private let worldNode = SKNode()
  private let hudNode = SKNode()
  private let overlayNode = SKNode()
  private var arenaRect = CGRect.zero
  private var mode: Mode = .menu
  private var player = SKShapeNode()
  private var playerVelocity = CGVector.zero
  private var playerAngle: CGFloat = -.pi / 2
  private var touchInput = CGVector.zero
  private var hasTouchInput = false
  private var enemies: [Enemy] = []
  private var pickups: [Pickup] = []
  private var effects: [SKNode] = []
  private var score = 0
  private var best = UserDefaults.standard.integer(forKey: "native.tiltarena.best")
  private var combo: CGFloat = 1
  private var maxCombo = 1
  private var comboExpiresAt: TimeInterval = 0
  private var elapsed: TimeInterval = 0
  private var lastUpdate: TimeInterval = 0
  private var spawnAt: TimeInterval = 0
  private var pickupAt: TimeInterval = 2.0
  private var invulnerableUntil: TimeInterval = 0
  private var shieldUntil: TimeInterval = 0
  private var spikesUntil: TimeInterval = 0
  private var vortexUntil: TimeInterval = 0
  private var vortexPoint = CGPoint.zero
  private let playerHitbox: CGFloat = 8
  private let playerVisualRadius: CGFloat = 34
  private let paper = UIColor(red: 0.91, green: 0.96, blue: 0.73, alpha: 1)
  private let paperDark = UIColor(red: 0.80, green: 0.90, blue: 0.62, alpha: 1)
  private let ink = UIColor(red: 0.07, green: 0.09, blue: 0.04, alpha: 1)
  private let enemyRed = UIColor(red: 0.89, green: 0.19, blue: 0.20, alpha: 1)
  private let enemyStroke = UIColor(red: 0.56, green: 0.13, blue: 0.12, alpha: 1)
  private let cream = UIColor(red: 1.00, green: 0.98, blue: 0.90, alpha: 1)

  private var scoreLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
  private var comboLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
  private var timeLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
  private var pauseNode = SKNode()

  override init(size: CGSize) {
    super.init(size: size)
    commonInit()
  }

  convenience init() {
    self.init(size: CGSize(width: 960, height: 640))
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  private func commonInit() {
    backgroundColor = paper
    addChild(worldNode)
    addChild(hudNode)
    addChild(overlayNode)
    isUserInteractionEnabled = true
    startMotion()
  }

  override func didMove(to view: SKView) {
    view.isMultipleTouchEnabled = false
    layoutScene()
    showMenu()
  }

  override func didChangeSize(_ oldSize: CGSize) {
    layoutScene()
  }

  private func layoutScene() {
    removeAllChildren()
    worldNode.removeAllChildren()
    hudNode.removeAllChildren()
    overlayNode.removeAllChildren()
    addChild(worldNode)
    addChild(hudNode)
    addChild(overlayNode)
    backgroundColor = paper

    let targetRatio: CGFloat = 3.0 / 2.0
    var width = size.width
    var height = width / targetRatio
    if height > size.height {
      height = size.height
      width = height * targetRatio
    }
    arenaRect = CGRect(
      x: (size.width - width) / 2 + 14,
      y: (size.height - height) / 2 + 14,
      width: width - 28,
      height: height - 28
    )

    drawBackground()
    drawHUD()
    if mode == .menu {
      showMenu()
    } else if mode == .gameOver {
      showGameOver()
    }
  }

  private func drawBackground() {
    let outer = SKShapeNode(rect: CGRect(x: arenaRect.minX - 12, y: arenaRect.minY - 12, width: arenaRect.width + 24, height: arenaRect.height + 24), cornerRadius: 6)
    outer.fillColor = paperDark.withAlphaComponent(0.42)
    outer.strokeColor = .clear
    worldNode.addChild(outer)

    let arena = SKShapeNode(rect: arenaRect)
    arena.fillColor = paper.withAlphaComponent(0.92)
    arena.strokeColor = ink.withAlphaComponent(0.64)
    arena.lineWidth = 2
    worldNode.addChild(arena)

    for index in 0..<8 {
      let radius = CGFloat(24 + (index % 4) * 24)
      let x = arenaRect.minX + CGFloat((index * 137) % Int(max(1, arenaRect.width)))
      let y = arenaRect.minY + CGFloat((index * 83) % Int(max(1, arenaRect.height)))
      let circle = SKShapeNode(circleOfRadius: radius)
      circle.position = CGPoint(x: x, y: y)
      circle.strokeColor = UIColor(red: 0.48, green: 0.60, blue: 0.32, alpha: 0.13)
      circle.lineWidth = 2
      circle.fillColor = .clear
      worldNode.addChild(circle)
    }

    for index in 0..<24 {
      let dot = SKShapeNode(circleOfRadius: CGFloat(1 + index % 3))
      let x = arenaRect.minX + CGFloat((index * 59) % Int(max(1, arenaRect.width)))
      let y = arenaRect.minY + CGFloat((index * 41) % Int(max(1, arenaRect.height)))
      dot.position = CGPoint(x: x, y: y)
      dot.fillColor = UIColor(red: 0.48, green: 0.60, blue: 0.32, alpha: 0.14)
      dot.strokeColor = .clear
      worldNode.addChild(dot)
    }
  }

  private func drawHUD() {
    scoreLabel = hudLabel(text: "Score   0", x: arenaRect.minX + 58, align: .left)
    comboLabel = hudLabel(text: "Combo   x1", x: arenaRect.minX + 180, align: .left)
    timeLabel = hudLabel(text: "Time   00:00", x: arenaRect.maxX - 120, align: .left)
    hudNode.addChild(scoreLabel)
    hudNode.addChild(comboLabel)
    hudNode.addChild(timeLabel)

    pauseNode = makePauseButton()
    pauseNode.position = CGPoint(x: arenaRect.maxX - 22, y: arenaRect.maxY - 18)
    hudNode.addChild(pauseNode)
  }

  private func hudLabel(text: String, x: CGFloat, align: SKLabelHorizontalAlignmentMode) -> SKLabelNode {
    let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
    label.text = text
    label.fontColor = ink
    label.fontSize = 15
    label.horizontalAlignmentMode = align
    label.verticalAlignmentMode = .center
    label.position = CGPoint(x: x, y: arenaRect.maxY - 18)
    return label
  }

  private func makePauseButton() -> SKNode {
    let node = SKNode()
    let ring = SKShapeNode(circleOfRadius: 15)
    ring.strokeColor = ink
    ring.lineWidth = 2
    ring.fillColor = .clear
    node.addChild(ring)
    for x in [-5, 5] {
      let bar = SKShapeNode(rectOf: CGSize(width: 3.5, height: 16), cornerRadius: 1.5)
      bar.fillColor = ink
      bar.strokeColor = .clear
      bar.position.x = CGFloat(x)
      node.addChild(bar)
    }
    return node
  }

  private func resetRun() {
    worldNode.removeAllChildren()
    overlayNode.removeAllChildren()
    enemies.removeAll()
    pickups.removeAll()
    effects.removeAll()
    drawBackground()

    score = 0
    combo = 1
    maxCombo = 1
    elapsed = 0
    spawnAt = 0
    pickupAt = 1.4
    comboExpiresAt = 0
    playerVelocity = .zero
    invulnerableUntil = 1.6
    shieldUntil = 0
    spikesUntil = 0
    vortexUntil = 0
    mode = .running

    player = makePlayer()
    player.position = CGPoint(x: arenaRect.midX, y: arenaRect.midY)
    worldNode.addChild(player)
    for index in 0..<6 {
      spawnEnemy(edgePoint(angle: CGFloat(index) * .pi * 2 / 6), speedScale: 0.85)
    }
    spawnPickup()
    updateHUD()
  }

  private func showMenu() {
    mode = .menu
    overlayNode.removeAllChildren()
    let panel = makePanel(width: 430, height: 188)
    panel.position = CGPoint(x: size.width / 2, y: size.height / 2)
    overlayNode.addChild(panel)
    addOverlayLabel("Evita los puntos", size: 34, weight: "AvenirNext-Heavy", y: 50)
    addOverlayLabel("Inclina o arrastra. Un toque enemigo acaba la partida.", size: 15, weight: "AvenirNext-Medium", y: 11)
    let button = makeButton(text: "Empezar", width: 150)
    button.name = "start"
    button.position = CGPoint(x: size.width / 2, y: size.height / 2 - 55)
    overlayNode.addChild(button)
  }

  private func showGameOver() {
    mode = .gameOver
    overlayNode.removeAllChildren()
    let panel = makePanel(width: 430, height: 214)
    panel.position = CGPoint(x: size.width / 2, y: size.height / 2)
    overlayNode.addChild(panel)
    addOverlayLabel("Has caido", size: 34, weight: "AvenirNext-Heavy", y: 58)
    addOverlayLabel("Score \(score)    Combo x\(maxCombo)    Time \(formatTime(elapsed))", size: 15, weight: "AvenirNext-DemiBold", y: 16)
    let button = makeButton(text: "Otra partida", width: 170)
    button.name = "restart"
    button.position = CGPoint(x: size.width / 2, y: size.height / 2 - 66)
    overlayNode.addChild(button)
  }

  private func makePanel(width: CGFloat, height: CGFloat) -> SKShapeNode {
    let panel = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 8)
    panel.fillColor = UIColor(red: 0.97, green: 0.98, blue: 0.88, alpha: 0.96)
    panel.strokeColor = ink.withAlphaComponent(0.14)
    panel.lineWidth = 1
    return panel
  }

  private func addOverlayLabel(_ text: String, size: CGFloat, weight: String, y: CGFloat) {
    let label = SKLabelNode(fontNamed: weight)
    label.text = text
    label.fontColor = ink
    label.fontSize = size
    label.verticalAlignmentMode = .center
    label.horizontalAlignmentMode = .center
    label.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 + y)
    overlayNode.addChild(label)
  }

  private func makeButton(text: String, width: CGFloat) -> SKNode {
    let node = SKNode()
    let rect = SKShapeNode(rectOf: CGSize(width: width, height: 46), cornerRadius: 7)
    rect.fillColor = UIColor(red: 0.85, green: 0.95, blue: 0.42, alpha: 1)
    rect.strokeColor = .clear
    node.addChild(rect)
    let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    label.text = text
    label.fontColor = ink
    label.fontSize = 16
    label.verticalAlignmentMode = .center
    node.addChild(label)
    return node
  }

  private func makePlayer() -> SKShapeNode {
    let path = CGMutablePath()
    path.move(to: CGPoint(x: 26, y: 0))
    path.addLine(to: CGPoint(x: -14, y: -12))
    path.addLine(to: CGPoint(x: -6, y: 0))
    path.addLine(to: CGPoint(x: -14, y: 12))
    path.closeSubpath()
    let node = SKShapeNode(path: path)
    node.fillColor = .clear
    node.strokeColor = ink
    node.lineWidth = 3.1
    node.lineJoin = .round
    return node
  }

  private func makeEnemy(elite: Bool) -> SKNode {
    let root = SKNode()
    let radius: CGFloat = elite ? 15 : 11
    let body = SKShapeNode(circleOfRadius: radius)
    body.fillColor = enemyRed
    body.strokeColor = enemyStroke
    body.lineWidth = elite ? 3 : 2.4
    root.addChild(body)
    for x in [-radius * 0.32, radius * 0.32] {
      let eye = SKShapeNode(circleOfRadius: max(2.2, radius * 0.22))
      eye.position = CGPoint(x: x, y: radius * 0.18)
      eye.fillColor = cream
      eye.strokeColor = .clear
      root.addChild(eye)
      let pupil = SKShapeNode(circleOfRadius: 1.1)
      pupil.position = CGPoint(x: x + 1, y: radius * 0.18)
      pupil.fillColor = ink
      pupil.strokeColor = .clear
      root.addChild(pupil)
    }
    return root
  }

  private func makePickup(power: Power) -> SKNode {
    let root = SKNode()
    let badge = SKShapeNode(circleOfRadius: 21)
    badge.fillColor = cream
    badge.strokeColor = ink
    badge.lineWidth = 3
    root.addChild(badge)
    switch power {
    case .frost: drawSnowflake(in: root, color: power.color)
    case .missiles: drawMissile(in: root, color: power.color)
    case .vortex: drawVortex(in: root, color: power.color)
    case .shield: drawShield(in: root, color: power.color)
    case .spikes: drawSpikes(in: root, color: power.color)
    case .shock: drawBolt(in: root, color: power.color)
    }
    return root
  }

  private func drawSnowflake(in root: SKNode, color: UIColor) {
    for angle in stride(from: CGFloat(0), to: .pi, by: .pi / 3) {
      let path = CGMutablePath()
      path.move(to: CGPoint(x: -14 * cos(angle), y: -14 * sin(angle)))
      path.addLine(to: CGPoint(x: 14 * cos(angle), y: 14 * sin(angle)))
      let line = SKShapeNode(path: path)
      line.strokeColor = ink
      line.lineWidth = 3
      root.addChild(line)
    }
    let core = SKShapeNode(circleOfRadius: 4)
    core.fillColor = color
    core.strokeColor = ink
    core.lineWidth = 2
    root.addChild(core)
  }

  private func drawMissile(in root: SKNode, color: UIColor) {
    let path = CGMutablePath()
    path.move(to: CGPoint(x: 15, y: 0))
    path.addLine(to: CGPoint(x: -10, y: -9))
    path.addLine(to: CGPoint(x: -4, y: 0))
    path.addLine(to: CGPoint(x: -10, y: 9))
    path.closeSubpath()
    addIconShape(path, to: root, color: color)
  }

  private func drawVortex(in root: SKNode, color: UIColor) {
    let path = CGMutablePath()
    path.move(to: CGPoint(x: 13, y: 8))
    path.addCurve(to: CGPoint(x: -10, y: 6), control1: CGPoint(x: 2, y: 18), control2: CGPoint(x: -18, y: 16))
    path.addCurve(to: CGPoint(x: 7, y: -11), control1: CGPoint(x: -3, y: -4), control2: CGPoint(x: 14, y: -1))
    let node = SKShapeNode(path: path)
    node.strokeColor = ink
    node.lineWidth = 4
    node.lineCap = .round
    node.fillColor = .clear
    root.addChild(node)
    let dot = SKShapeNode(circleOfRadius: 4)
    dot.fillColor = color
    dot.strokeColor = ink
    dot.lineWidth = 2
    root.addChild(dot)
  }

  private func drawShield(in root: SKNode, color: UIColor) {
    let path = CGMutablePath()
    path.move(to: CGPoint(x: 0, y: 15))
    path.addLine(to: CGPoint(x: 13, y: 8))
    path.addLine(to: CGPoint(x: 11, y: -5))
    path.addLine(to: CGPoint(x: 0, y: -15))
    path.addLine(to: CGPoint(x: -11, y: -5))
    path.addLine(to: CGPoint(x: -13, y: 8))
    path.closeSubpath()
    addIconShape(path, to: root, color: color)
  }

  private func drawSpikes(in root: SKNode, color: UIColor) {
    let path = CGMutablePath()
    for index in 0..<12 {
      let angle = CGFloat(index) * .pi * 2 / 12
      let radius: CGFloat = index.isMultiple(of: 2) ? 15 : 8
      let point = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
      if index == 0 { path.move(to: point) } else { path.addLine(to: point) }
    }
    path.closeSubpath()
    addIconShape(path, to: root, color: color)
  }

  private func drawBolt(in root: SKNode, color: UIColor) {
    let path = CGMutablePath()
    path.move(to: CGPoint(x: 4, y: 17))
    path.addLine(to: CGPoint(x: -11, y: -1))
    path.addLine(to: CGPoint(x: 0, y: -1))
    path.addLine(to: CGPoint(x: -5, y: -17))
    path.addLine(to: CGPoint(x: 14, y: 4))
    path.addLine(to: CGPoint(x: 3, y: 4))
    path.closeSubpath()
    addIconShape(path, to: root, color: color)
  }

  private func addIconShape(_ path: CGPath, to root: SKNode, color: UIColor) {
    let shape = SKShapeNode(path: path)
    shape.fillColor = color
    shape.strokeColor = ink
    shape.lineWidth = 2.6
    shape.lineJoin = .round
    root.addChild(shape)
  }

  private func startMotion() {
    guard motionManager.isDeviceMotionAvailable else { return }
    motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
    motionManager.startDeviceMotionUpdates()
  }

  override func update(_ currentTime: TimeInterval) {
    guard mode == .running else {
      lastUpdate = currentTime
      return
    }
    let dt = min(max(currentTime - lastUpdate, 0), 1.0 / 30.0)
    lastUpdate = currentTime
    elapsed += dt
    if elapsed > comboExpiresAt { combo = 1 }

    updatePlayer(dt: dt)
    updateSpawns()
    updatePickups()
    updatePowers(dt: dt)
    updateEnemies(dt: dt)
    updateHUD()
  }

  private func updatePlayer(dt: TimeInterval) {
    var input = currentTiltInput()
    if hasTouchInput {
      input.dx += touchInput.dx
      input.dy += touchInput.dy
    }
    let len = hypot(input.dx, input.dy)
    if len > 1 {
      input.dx /= len
      input.dy /= len
    }

    let accel: CGFloat = 1060
    let drag = pow(0.88, CGFloat(dt) * 60)
    playerVelocity.dx = (playerVelocity.dx + input.dx * accel * CGFloat(dt)) * drag
    playerVelocity.dy = (playerVelocity.dy + input.dy * accel * CGFloat(dt)) * drag
    let speed = hypot(playerVelocity.dx, playerVelocity.dy)
    let maxSpeed: CGFloat = 360
    if speed > maxSpeed {
      playerVelocity.dx = playerVelocity.dx / speed * maxSpeed
      playerVelocity.dy = playerVelocity.dy / speed * maxSpeed
    }

    player.position.x = clamp(player.position.x + playerVelocity.dx * CGFloat(dt), arenaRect.minX + playerHitbox, arenaRect.maxX - playerHitbox)
    player.position.y = clamp(player.position.y + playerVelocity.dy * CGFloat(dt), arenaRect.minY + playerHitbox, arenaRect.maxY - playerHitbox)
    if speed > 8 {
      playerAngle = atan2(playerVelocity.dy, playerVelocity.dx)
      player.zRotation = playerAngle
    }
  }

  private func currentTiltInput() -> CGVector {
    guard let motion = motionManager.deviceMotion else { return .zero }
    let roll = CGFloat(motion.attitude.roll)
    let pitch = CGFloat(motion.attitude.pitch)
    return CGVector(dx: clamp(roll / 0.42, -1, 1), dy: clamp(-pitch / 0.42, -1, 1))
  }

  private func updateSpawns() {
    if elapsed >= spawnAt {
      let amount = min(20, Int(3 + elapsed / 14))
      for index in 0..<amount {
        let angle = CGFloat(index) * .pi * 2 / CGFloat(max(1, amount)) + CGFloat.random(in: -0.15...0.15)
        spawnEnemy(edgePoint(angle: angle), speedScale: CGFloat.random(in: 0.75...1.08))
      }
      spawnAt = elapsed + max(0.6, 1.8 - elapsed * 0.008)
    }
    if elapsed >= pickupAt {
      spawnPickup()
      pickupAt = elapsed + max(2.0, 4.8 - elapsed * 0.018)
    }
  }

  private func spawnEnemy(_ point: CGPoint, speedScale: CGFloat) {
    let elite = CGFloat.random(in: 0...1) < min(0.1, CGFloat(elapsed) / 900)
    let node = makeEnemy(elite: elite)
    node.position = point
    worldNode.addChild(node)
    enemies.append(Enemy(node: node, radius: elite ? 15 : 11, speed: (elite ? 44 : 58) * speedScale * (1 + CGFloat(elapsed) / 260), elite: elite, frozenUntil: 0))
  }

  private func spawnPickup() {
    let power = Power.allCases.randomElement() ?? .frost
    let node = makePickup(power: power)
    node.position = CGPoint(
      x: CGFloat.random(in: (arenaRect.minX + 52)...(arenaRect.maxX - 52)),
      y: CGFloat.random(in: (arenaRect.minY + 52)...(arenaRect.maxY - 52))
    )
    node.name = "pickup"
    worldNode.addChild(node)
    pickups.append(Pickup(node: node, power: power, radius: 18, expiresAt: elapsed + 10))
  }

  private func updatePickups() {
    pickups.removeAll { pickup in
      if elapsed >= pickup.expiresAt {
        pickup.node.removeFromParent()
        return true
      }
      if distance(player.position, pickup.node.position) < pickup.radius + 22 {
        activate(power: pickup.power)
        pickup.node.removeFromParent()
        return true
      }
      return false
    }
  }

  private func activate(power: Power) {
    switch power {
    case .frost:
      let radius = min(arenaRect.width, arenaRect.height) * 0.58
      for index in enemies.indices {
        enemies[index].frozenUntil = elapsed + 3
        if distance(player.position, enemies[index].node.position) < radius {
          killEnemy(at: index)
        }
      }
      addRing(at: player.position, radius: radius, color: power.color)
    case .missiles:
      let targets = nearestEnemies(limit: 8)
      for index in targets {
        addBeam(from: player.position, to: enemies[index].node.position, color: power.color)
        killEnemy(at: index)
      }
    case .vortex:
      vortexUntil = elapsed + power.duration
      vortexPoint = player.position
      addRing(at: vortexPoint, radius: min(arenaRect.width, arenaRect.height) * 0.45, color: power.color)
    case .shield:
      shieldUntil = elapsed + power.duration
      addRing(at: player.position, radius: 48, color: power.color)
    case .spikes:
      spikesUntil = elapsed + power.duration
      addRing(at: player.position, radius: 74, color: power.color)
    case .shock:
      let targets = nearestEnemies(limit: 14)
      var previous = player.position
      for index in targets {
        addBeam(from: previous, to: enemies[index].node.position, color: power.color)
        previous = enemies[index].node.position
        killEnemy(at: index)
      }
    }
  }

  private func updatePowers(dt: TimeInterval) {
    if elapsed < vortexUntil {
      let radius = min(arenaRect.width, arenaRect.height) * 0.45
      for index in enemies.indices {
        let position = enemies[index].node.position
        let dx = vortexPoint.x - position.x
        let dy = vortexPoint.y - position.y
        let len = max(1, hypot(dx, dy))
        if len < radius {
          enemies[index].node.position.x += dx / len * CGFloat(dt) * 130
          enemies[index].node.position.y += dy / len * CGFloat(dt) * 130
          if len < 26 { killEnemy(at: index) }
        }
      }
    }
    if elapsed < spikesUntil {
      for index in enemies.indices where distance(player.position, enemies[index].node.position) < 78 {
        killEnemy(at: index)
      }
      if Int(elapsed * 12).isMultiple(of: 3) {
        addRing(at: player.position, radius: 76, color: cream.withAlphaComponent(0.8))
      }
    }
  }

  private func updateEnemies(dt: TimeInterval) {
    for index in enemies.indices {
      guard enemies.indices.contains(index) else { continue }
      let node = enemies[index].node
      let dx = player.position.x - node.position.x
      let dy = player.position.y - node.position.y
      let len = max(1, hypot(dx, dy))
      let frozen = elapsed < enemies[index].frozenUntil
      let speed = enemies[index].speed * (frozen ? 0.28 : 1)
      node.position.x += dx / len * speed * CGFloat(dt)
      node.position.y += dy / len * speed * CGFloat(dt)

      if distance(node.position, player.position) < enemies[index].radius + playerHitbox {
        if elapsed < invulnerableUntil || elapsed < shieldUntil {
          killEnemy(at: index)
        } else {
          endRun()
          return
        }
      }
    }
    enemies.removeAll { $0.node.parent == nil }
  }

  private func killEnemy(at index: Int) {
    guard enemies.indices.contains(index), enemies[index].node.parent != nil else { return }
    let enemy = enemies[index]
    let points = Int((enemy.elite ? 80 : 15) * combo)
    score += points
    combo = min(99, combo + (enemy.elite ? 0.5 : 0.15))
    maxCombo = max(maxCombo, Int(combo))
    comboExpiresAt = elapsed + 1.6
    addBurst(at: enemy.node.position, color: enemyRed)
    enemy.node.removeFromParent()
  }

  private func endRun() {
    mode = .gameOver
    best = max(best, score)
    UserDefaults.standard.set(best, forKey: "native.tiltarena.best")
    showGameOver()
  }

  private func nearestEnemies(limit: Int) -> [Int] {
    enemies.indices
      .filter { enemies[$0].node.parent != nil }
      .sorted { distance(enemies[$0].node.position, player.position) < distance(enemies[$1].node.position, player.position) }
      .prefix(limit)
      .map { $0 }
  }

  private func updateHUD() {
    scoreLabel.text = "Score   \(score)"
    comboLabel.text = "Combo   x\(max(1, Int(combo)))"
    timeLabel.text = "Time   \(formatTime(elapsed))"
  }

  private func addRing(at point: CGPoint, radius: CGFloat, color: UIColor) {
    let ring = SKShapeNode(circleOfRadius: radius)
    ring.position = point
    ring.strokeColor = color
    ring.lineWidth = 3
    ring.fillColor = .clear
    worldNode.addChild(ring)
    ring.run(.sequence([.group([.fadeOut(withDuration: 0.45), .scale(to: 1.08, duration: 0.45)]), .removeFromParent()]))
  }

  private func addBeam(from: CGPoint, to: CGPoint, color: UIColor) {
    let path = CGMutablePath()
    path.move(to: from)
    path.addLine(to: to)
    let beam = SKShapeNode(path: path)
    beam.strokeColor = color
    beam.lineWidth = 3
    worldNode.addChild(beam)
    beam.run(.sequence([.fadeOut(withDuration: 0.18), .removeFromParent()]))
  }

  private func addBurst(at point: CGPoint, color: UIColor) {
    for _ in 0..<5 {
      let spark = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...4))
      spark.position = point
      spark.fillColor = color
      spark.strokeColor = .clear
      worldNode.addChild(spark)
      let angle = CGFloat.random(in: 0...(CGFloat.pi * 2))
      let distance = CGFloat.random(in: 12...30)
      spark.run(.sequence([
        .group([
          .moveBy(x: cos(angle) * distance, y: sin(angle) * distance, duration: 0.26),
          .fadeOut(withDuration: 0.26)
        ]),
        .removeFromParent()
      ]))
    }
  }

  private func edgePoint(angle: CGFloat) -> CGPoint {
    let center = CGPoint(x: arenaRect.midX, y: arenaRect.midY)
    let dx = cos(angle)
    let dy = sin(angle)
    let tx = dx > 0 ? (arenaRect.maxX - center.x) / dx : (arenaRect.minX - center.x) / dx
    let ty = dy > 0 ? (arenaRect.maxY - center.y) / dy : (arenaRect.minY - center.y) / dy
    let t = min(abs(tx), abs(ty))
    return CGPoint(x: clamp(center.x + dx * t, arenaRect.minX, arenaRect.maxX), y: clamp(center.y + dy * t, arenaRect.minY, arenaRect.maxY))
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let point = touches.first?.location(in: self) else { return }
    if mode == .menu {
      resetRun()
      return
    }
    if mode == .gameOver {
      resetRun()
      return
    }
    if distance(point, pauseNode.position) < 34 {
      togglePause()
      return
    }
    setTouchInput(point)
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let point = touches.first?.location(in: self), mode == .running else { return }
    setTouchInput(point)
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    hasTouchInput = false
    touchInput = .zero
  }

  private func setTouchInput(_ point: CGPoint) {
    let dx = point.x - player.position.x
    let dy = point.y - player.position.y
    let len = max(1, hypot(dx, dy))
    touchInput = CGVector(dx: dx / len, dy: dy / len)
    hasTouchInput = true
  }

  private func togglePause() {
    if mode == .running {
      mode = .paused
      let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
      label.name = "pauseOverlay"
      label.text = "Pausa"
      label.fontColor = ink
      label.fontSize = 38
      label.position = CGPoint(x: size.width / 2, y: size.height / 2)
      overlayNode.addChild(label)
    } else if mode == .paused {
      mode = .running
      overlayNode.childNode(withName: "pauseOverlay")?.removeFromParent()
      lastUpdate = 0
    }
  }

  private func formatTime(_ seconds: TimeInterval) -> String {
    let minutes = Int(seconds) / 60
    let rest = Int(seconds) % 60
    return String(format: "%02d:%02d", minutes, rest)
  }

  private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
    hypot(a.x - b.x, a.y - b.y)
  }

  private func clamp(_ value: CGFloat, _ minValue: CGFloat, _ maxValue: CGFloat) -> CGFloat {
    min(maxValue, max(minValue, value))
  }
}

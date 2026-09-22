import SwiftUI
import SpriteKit

struct ArenaView: UIViewRepresentable {
    let scene: ClassicScene
    let isRunning: Bool
    func makeUIView(context: Context) -> ArenaSKView {
        let view = ArenaSKView()
        view.preferredFramesPerSecond = 60
        view.ignoresSiblingOrder = true
        view.presentScene(scene)
        view.installPauseGesture()
        return view
    }
    func updateUIView(_ view: ArenaSKView, context: Context) {
        view.isAccessibilityElement = isRunning
        view.accessibilityIdentifier = isRunning ? "arena-running" : "arena"
        view.accessibilityLabel = GameText.arenaAccessibility
        view.accessibilityHint = GameText.pauseHint
        view.setNeedsLayout()
    }
}

final class ArenaSKView: SKView, UIGestureRecognizerDelegate {
    func installPauseGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(pauseFromTap))
        tap.delegate = self
        // Simulator drags still steer; only a tap opens the menu.
        tap.cancelsTouchesInView = false
        addGestureRecognizer(tap)
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        (scene as? ClassicScene)?.session?.phase == .running
    }
    @objc private func pauseFromTap() { (scene as? ClassicScene)?.pauseRun() }
    override func accessibilityActivate() -> Bool {
        guard let scene = scene as? ClassicScene, scene.session?.phase == .running else { return false }
        scene.pauseRun()
        return true
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        (scene as? ClassicScene)?.configureViewport(viewSize: bounds.size, insets: window?.safeAreaInsets ?? .zero)
    }
}

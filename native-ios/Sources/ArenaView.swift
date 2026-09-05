import SwiftUI
import SpriteKit

struct ArenaView: UIViewRepresentable {
    let scene: ClassicScene
    func makeUIView(context: Context) -> ArenaSKView {
        let view = ArenaSKView()
        view.preferredFramesPerSecond = 60
        view.ignoresSiblingOrder = true
        view.presentScene(scene)
        return view
    }
    func updateUIView(_ view: ArenaSKView, context: Context) { view.setNeedsLayout() }
}

final class ArenaSKView: SKView {
    override func layoutSubviews() {
        super.layoutSubviews()
        (scene as? ClassicScene)?.configureViewport(viewSize: bounds.size, insets: window?.safeAreaInsets ?? .zero)
    }
}

import SwiftUI
import SpriteKit

@main
struct TiltArenaNativeApp: App {
    var body: some Scene {
        WindowGroup { GameView().statusBarHidden(true).preferredColorScheme(.dark) }
    }
}

final class GameSession: ObservableObject {
    enum Phase { case menu, calibrating, running, paused, gameOver, failed }
    @Published var phase: Phase = .menu
    @Published var message = ""
    @Published var resultScore = 0
    @Published var resultCombo = 0
    @Published var resultTime = 0
    @Published var best = UserDefaults.standard.integer(forKey: "classic.v02.best")
    @Published var sensitivity = UserDefaults.standard.object(forKey: "classic.sensitivity") as? Double ?? 1
    @Published var muted = UserDefaults.standard.bool(forKey: "classic.muted")
    let scene = ClassicScene()
    init() { scene.session = self }
    func fail(_ error: Error) {
        scene.halt()
        message = "No se ha podido iniciar el juego. Vuelve al menú para intentarlo de nuevo."
        phase = .failed
        #if DEBUG
        print("Classic: \(error)")
        #endif
    }
    func finish(_ frame: ClassicFrame) {
        resultScore = frame.score; resultCombo = frame.bestCombo; resultTime = Int(frame.time)
        best = max(best, frame.score)
        UserDefaults.standard.set(best, forKey: "classic.v02.best")
        phase = .gameOver
    }
}

struct GameView: View {
    @StateObject private var game = GameSession()
    @Environment(\.scenePhase) private var appPhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private let accent = Color(red: 0.82, green: 0.96, blue: 0.38)
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(red: 0.08, green: 0.13, blue: 0.06).ignoresSafeArea()
                SpriteView(scene: game.scene, preferredFramesPerSecond: 60)
                    .aspectRatio(1.5, contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .accessibilityLabel("Arena clásica. Inclina el iPhone para esquivar puntos y recoger armas.")
                if game.phase == .running {
                    VStack {
                        HStack {
                            Spacer()
                            Button { game.scene.pauseRun() } label: {
                                Image(systemName: "pause.fill").frame(width: 44, height: 44)
                            }.accessibilityLabel("Pausar partida")
                        }
                        Spacer()
                    }.padding(.horizontal, 4)
                } else {
                    Color.black.opacity(0.36)
                    panel.frame(maxWidth: min(geometry.size.width - 40, 430))
                        .frame(maxHeight: geometry.size.height - 16)
                }
            }
        }
        .onAppear { game.scene.reduceEffects = reduceMotion; game.scene.sound.setMuted(game.muted) }
        .onChange(of: appPhase) { phase in
            if phase != .active { game.scene.suspend() }
            else { game.scene.startMotion() }
        }
        .onChange(of: reduceMotion) { game.scene.reduceEffects = $0 }
        .onChange(of: game.sensitivity) { UserDefaults.standard.set($0, forKey: "classic.sensitivity") }
        .onChange(of: game.muted) {
            UserDefaults.standard.set($0, forKey: "classic.muted"); game.scene.sound.setMuted($0)
        }
    }
    @ViewBuilder private var panel: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("KRAZEL GAMES").font(.system(size: 11, weight: .bold, design: .rounded)).tracking(4).foregroundColor(accent)
                switch game.phase {
                case .menu:
                    Text("CLÁSICO").font(.system(size: 42, weight: .black, design: .rounded))
                    Text("Esquiva los puntos. Alcanza las armas.\nEncadena una partida más.")
                        .multilineTextAlignment(.center).foregroundColor(.white.opacity(0.8))
                    Text("RÉCORD  \(game.best.formatted())").font(.system(.callout, design: .monospaced))
                    primary("Calibrar y jugar") { game.scene.calibrate(restart: true) }
                    settings
                case .calibrating:
                    Text("Busca tu postura").font(.title2.bold())
                    Text(game.message).multilineTextAlignment(.center)
                    ProgressView().tint(accent)
                    Button("Volver") { game.scene.menu() }
                case .paused:
                    Text("PAUSA").font(.largeTitle.bold())
                    Text(game.message.isEmpty ? "La arena te espera." : game.message).multilineTextAlignment(.center)
                    primary("Calibrar y continuar") { game.scene.calibrate(restart: false) }
                    settings
                    Button("Terminar partida") { game.scene.finishPausedRun() }
                case .gameOver:
                    Text("Por un punto…").font(.largeTitle.bold())
                    Text(game.resultScore.formatted()).font(.system(size: 42, weight: .black, design: .rounded)).foregroundColor(accent)
                    Text("COMBO ×\(game.resultCombo)   ·   \(game.resultTime) s")
                        .font(.system(.callout, design: .monospaced))
                    Text("Récord: \(game.best.formatted())").foregroundColor(.white.opacity(0.7))
                    primary("Otra partida") { game.scene.calibrate(restart: true) }
                    Button("Menú") { game.scene.menu() }
                case .failed:
                    Text("No se puede jugar todavía").font(.title2.bold())
                    Text(game.message).multilineTextAlignment(.center)
                    primary("Menú") { game.scene.menu() }
                case .running: EmptyView()
                }
            }.padding(22).frame(maxWidth: .infinity)
        }
        .fixedSize(horizontal: false, vertical: true)
        .background(Color(red: 0.09, green: 0.15, blue: 0.075).opacity(0.97))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(accent.opacity(0.25), lineWidth: 1))
    }
    private var settings: some View {
        HStack(spacing: 16) {
            Picker("Sensibilidad", selection: $game.sensitivity) {
                Text("Suave").tag(0.7); Text("Normal").tag(1.0); Text("Rápida").tag(1.4)
            }.pickerStyle(.menu).accessibilityLabel("Sensibilidad de inclinación")
            Button { game.muted.toggle() } label: {
                Image(systemName: game.muted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    .frame(width: 44, height: 44)
            }.accessibilityLabel(game.muted ? "Activar sonido" : "Silenciar sonido")
        }
    }
    private func primary(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title).font(.headline).foregroundColor(.black)
                .frame(maxWidth: .infinity, minHeight: 44).background(accent)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

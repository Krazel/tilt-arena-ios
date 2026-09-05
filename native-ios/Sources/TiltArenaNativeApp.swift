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
    @Published var posture = TiltPosture(rawValue: UserDefaults.standard.string(forKey: "classic.posture") ?? "normal") ?? .normal
    @Published var hasCustom = UserDefaults.standard.object(forKey: "classic.neutralY") != nil
    private var custom = TiltProfile(screenX: UserDefaults.standard.double(forKey: "classic.neutralX"),
                                     screenY: UserDefaults.standard.double(forKey: "classic.neutralY"))
    var activeProfile: TiltProfile { posture == .custom ? custom : .preset(posture) }
    let scene = ClassicScene()
    init() { scene.session = self }
    func saveCustom(_ profile: TiltProfile) {
        custom = profile; hasCustom = true; posture = .custom
        UserDefaults.standard.set(profile.screenX, forKey: "classic.neutralX")
        UserDefaults.standard.set(profile.screenY, forKey: "classic.neutralY")
        UserDefaults.standard.set(posture.rawValue, forKey: "classic.posture")
    }
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
    private var showSettings: Bool { game.phase == .menu || game.phase == .paused || game.phase == .gameOver }
    var body: some View {
        ZStack {
            ArenaView(scene: game.scene).ignoresSafeArea()
                .accessibilityLabel("Arena clásica. Inclina el iPhone para esquivar puntos y recoger armas.")
            GeometryReader { geometry in
                if game.phase == .running {
                    VStack {
                        HStack {
                            Spacer()
                            Button { game.scene.pauseRun() } label: {
                                Image(systemName: "pause.fill").font(.headline)
                                    .frame(width: 44, height: 44).background(.black.opacity(0.35), in: Circle())
                            }.accessibilityLabel("Pausar partida").accessibilityIdentifier("pause")
                        }
                        Spacer()
                    }.padding(.horizontal, 12)
                } else {
                    ZStack {
                        Color.black.opacity(0.26).ignoresSafeArea()
                        ScrollView {
                            HStack(alignment: .center, spacing: 26) {
                                mainContent.frame(maxWidth: .infinity)
                                if showSettings {
                                    Rectangle().fill(accent.opacity(0.18)).frame(width: 1)
                                    settings.frame(width: min(300, geometry.size.width * 0.44))
                                }
                            }.padding(22)
                        }
                        .frame(maxWidth: 780, maxHeight: min(360, geometry.size.height - 12))
                        .background(Color(red: 0.075, green: 0.12, blue: 0.055).opacity(0.96))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(RoundedRectangle(cornerRadius: 24).stroke(accent.opacity(0.3), lineWidth: 1))
                        .padding(.horizontal, 12)
                    }.frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
        }.tint(accent)
        .onAppear { game.scene.reduceEffects = reduceMotion; game.scene.sound.setMuted(game.muted) }
        .onChange(of: appPhase) { phase in
            if phase != .active { game.scene.suspend() } else { game.scene.startMotion() }
        }
        .onChange(of: reduceMotion) { game.scene.reduceEffects = $0 }
        .onChange(of: game.posture) { UserDefaults.standard.set($0.rawValue, forKey: "classic.posture") }
        .onChange(of: game.sensitivity) { UserDefaults.standard.set($0, forKey: "classic.sensitivity") }
        .onChange(of: game.muted) {
            UserDefaults.standard.set($0, forKey: "classic.muted"); game.scene.sound.setMuted($0)
        }
    }
    private var mainContent: some View {
        VStack(spacing: 12) {
            Text("KRAZEL GAMES").font(.system(size: 10, weight: .bold, design: .rounded)).tracking(4).foregroundColor(accent)
            switch game.phase {
            case .menu:
                Text("CLÁSICO").font(.system(size: 38, weight: .black, design: .rounded))
                Text("Esquiva. Recoge. Encadena.").font(.subheadline).foregroundColor(.white.opacity(0.7))
                Text("RÉCORD  \(game.best.formatted())").font(.system(.callout, design: .monospaced))
                primary("Jugar", id: "play") { game.scene.play(restart: true) }
                secondary("Calibrar postura") { game.scene.calibrate(restart: true) }
            case .calibrating:
                Image(systemName: "scope").font(.system(size: 38)).foregroundColor(accent)
                Text("Tu postura").font(.title.bold())
                Text(game.message).multilineTextAlignment(.center)
                ProgressView().tint(accent)
                secondary("Cancelar") { game.scene.cancelCalibration() }
            case .paused:
                Text("PAUSA").font(.system(size: 38, weight: .black, design: .rounded))
                Text(game.message.isEmpty ? "La arena te espera." : game.message)
                    .font(.subheadline).multilineTextAlignment(.center).foregroundColor(.white.opacity(0.7))
                primary("Reanudar", id: "resume") { game.scene.play(restart: false) }
                secondary("Recalibrar") { game.scene.calibrate(restart: false) }
                Button("Terminar partida") { game.scene.finishPausedRun() }.font(.footnote).foregroundColor(.white.opacity(0.65))
            case .gameOver:
                Text("Por un punto…").font(.title.bold())
                Text(game.resultScore.formatted()).font(.system(size: 38, weight: .black, design: .rounded)).foregroundColor(accent)
                Text("COMBO ×\(game.resultCombo)   ·   \(game.resultTime) s").font(.system(.callout, design: .monospaced))
                primary("Otra partida", id: "replay") { game.scene.play(restart: true) }
                secondary("Menú") { game.scene.menu() }
            case .failed:
                Text("Un momento…").font(.title2.bold())
                Text(game.message).multilineTextAlignment(.center)
                primary("Menú", id: "menu") { game.scene.menu() }
            case .running: EmptyView()
            }
        }.frame(maxWidth: .infinity)
    }
    private var settings: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("POSTURA DE CONTROL").font(.system(size: 10, weight: .bold)).tracking(2).foregroundColor(accent)
            HStack(spacing: 7) {
                ForEach(TiltPosture.allCases) { posture in
                    Button { game.posture = posture } label: {
                        VStack(spacing: 6) {
                            Image(systemName: posture.symbol).font(.system(size: 23))
                                .rotationEffect(.degrees(posture == .inclined ? 32 : 0))
                            Text(posture.title).font(.system(size: 10, weight: .semibold)).minimumScaleFactor(0.8).lineLimit(1)
                        }.frame(maxWidth: .infinity, minHeight: 67)
                        .foregroundColor(game.posture == posture ? .black : .white.opacity(0.75))
                        .background(game.posture == posture ? accent : .white.opacity(0.07), in: RoundedRectangle(cornerRadius: 12))
                    }.buttonStyle(.plain).accessibilityIdentifier("posture-\(posture.rawValue)")
                    .accessibilityAddTraits(game.posture == posture ? .isSelected : [])
                }
            }
            Text(game.posture.description).font(.system(size: 12)).foregroundColor(.white.opacity(0.7)).frame(minHeight: 34, alignment: .top)
            if game.posture == .custom {
                Text(game.hasCustom ? "Postura guardada · lista para jugar" : "Pulsa Calibrar para guardar tu postura")
                    .font(.system(size: 11, weight: .semibold)).foregroundColor(accent)
            }
            HStack {
                Text("Sensibilidad").font(.system(size: 12)).foregroundColor(.white.opacity(0.65))
                Spacer()
                Picker("Sensibilidad", selection: $game.sensitivity) {
                    Text("Suave").tag(0.7); Text("Normal").tag(1.0); Text("Rápida").tag(1.4)
                }.pickerStyle(.menu).accessibilityLabel("Sensibilidad de inclinación")
            }
            HStack {
                Text("Sonido").font(.system(size: 12)).foregroundColor(.white.opacity(0.65))
                Spacer()
                Button { game.muted.toggle() } label: {
                    Label(game.muted ? "Desactivado" : "Activado", systemImage: game.muted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .font(.system(size: 12)).frame(minHeight: 36)
                }.accessibilityLabel(game.muted ? "Activar sonido" : "Silenciar sonido")
            }
        }
    }
    private func primary(_ title: String, id: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title).font(.headline).foregroundColor(.black)
                .frame(maxWidth: .infinity, minHeight: 44).background(accent, in: RoundedRectangle(cornerRadius: 12))
        }.accessibilityIdentifier(id)
    }
    private func secondary(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title).font(.subheadline.weight(.semibold)).frame(maxWidth: .infinity, minHeight: 38)
                .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 10))
        }
    }
}

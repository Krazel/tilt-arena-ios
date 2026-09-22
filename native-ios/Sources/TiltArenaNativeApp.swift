import SwiftUI
import SpriteKit

@main
struct TiltArenaNativeApp: App {
    var body: some Scene {
        WindowGroup { GameView().statusBarHidden(true).preferredColorScheme(.dark) }
    }
}

enum GameMode: String, CaseIterable, Identifiable {
    case classic, hard
    var id: String { rawValue }
    var title: String { self == .hard ? GameText.hardMode : GameText.classicMode }
    var description: String { self == .hard ? GameText.hardDescription : GameText.classicDescription }
    static func read(defaults: UserDefaults = .standard) -> GameMode {
        GameMode(rawValue: defaults.string(forKey: "classic.mode") ?? "classic") ?? .classic
    }
}

enum ClassicScoreRecord {
    // Preserve the old fire-inflated record under its original key.
    static let key = "classic.scoring.v2.best"
    static func read(defaults: UserDefaults = .standard, mode: GameMode = .classic) -> Int { defaults.integer(forKey: mode == .hard ? "hard.scoring.v2.best" : key) }
    static func save(_ score: Int, defaults: UserDefaults = .standard, mode: GameMode = .classic) -> Int {
        let best = max(read(defaults: defaults, mode: mode), score)
        defaults.set(best, forKey: mode == .hard ? "hard.scoring.v2.best" : key)
        return best
    }
}

final class GameSession: ObservableObject {
    enum Phase { case menu, calibrating, running, paused, gameOver, failed }
    @Published var phase: Phase = .menu
    @Published var message = ""
    @Published var resultScore = 0
    @Published var resultCombo = 0
    @Published var resultTime = 0
    @Published var mode = GameMode.read()
    @Published var best = ClassicScoreRecord.read(mode: GameMode.read())
    @Published var muted = UserDefaults.standard.bool(forKey: "classic.muted")
    @Published var theme = VisualTheme.read()
    @Published var posture = TiltProfile.initialPosture(defaults: .standard)
    @Published var hasCustom = UserDefaults.standard.object(forKey: "classic.neutralY") != nil
    private var custom = TiltProfile(screenX: UserDefaults.standard.double(forKey: "classic.neutralX"),
                                     screenY: UserDefaults.standard.double(forKey: "classic.neutralY"))
    var activeProfile: TiltProfile { posture == .custom ? custom : .preset(posture) }
    let scene = ClassicScene()
    init() {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--theme-classic-qa") { theme = .classic }
        if ProcessInfo.processInfo.arguments.contains("--theme-ink-qa") { theme = .inkTide }
        if ProcessInfo.processInfo.arguments.contains("--fresh-controls-qa") {
            for key in ["classic.posture", "classic.postureRevision", "classic.neutralX", "classic.neutralY"] {
                UserDefaults.standard.removeObject(forKey: key)
            }
            posture = .custom; hasCustom = false
        }
        #endif
        scene.session = self
        scene.setTheme(theme)
        UserDefaults.standard.set(posture.rawValue, forKey: "classic.posture")
        UserDefaults.standard.set(2, forKey: "classic.postureRevision")
    }
    func selectMode(_ value: GameMode) {
        guard phase == .menu else { return }
        mode = value; best = ClassicScoreRecord.read(mode: value)
        UserDefaults.standard.set(value.rawValue, forKey: "classic.mode")
    }
    func saveCustom(_ profile: TiltProfile) {
        custom = profile; hasCustom = true; posture = .custom
        UserDefaults.standard.set(profile.screenX, forKey: "classic.neutralX")
        UserDefaults.standard.set(profile.screenY, forKey: "classic.neutralY")
        UserDefaults.standard.set(posture.rawValue, forKey: "classic.posture")
    }
    func fail(_ error: Error) {
        scene.halt()
        message = GameText.startFailure
        phase = .failed
        #if DEBUG
        print("Classic: \(error)")
        #endif
    }
    func finish(_ frame: ClassicFrame) {
        resultScore = frame.score; resultCombo = frame.bestCombo; resultTime = Int(frame.time)
        best = ClassicScoreRecord.save(frame.score, mode: GameMode(rawValue: frame.mode) ?? .classic)
        phase = .gameOver
    }
}

struct GameView: View {
    @StateObject private var game = GameSession()
    @Environment(\.scenePhase) private var appPhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var ink: Bool { game.theme == .inkTide }
    private var accent: Color { ink ? Color(InkArt.gold) : Color(red: 0.82, green: 0.96, blue: 0.38) }
    private var paper: Color { ink ? Color(InkArt.paper) : .white }
    private var panel: Color { ink ? Color(UIColor(hex: "201f1c")) : Color(red: 0.075, green: 0.12, blue: 0.055) }
    private var showSettings: Bool { game.phase == .menu || game.phase == .paused || game.phase == .gameOver }
    var body: some View {
        ZStack {
            ArenaView(scene: game.scene, isRunning: game.phase == .running).ignoresSafeArea()
            if game.phase != .running {
                GeometryReader { geometry in
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
                        .background(panel.opacity(ink ? 0.97 : 0.96))
                        .clipShape(RoundedRectangle(cornerRadius: ink ? 6 : 24))
                        .overlay(RoundedRectangle(cornerRadius: ink ? 6 : 24).stroke(accent.opacity(ink ? 0.45 : 0.3), lineWidth: 1))
                        .padding(.horizontal, 12)
                    }.frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
        }.overlay(alignment: .bottomTrailing) {
            if showSettings {
                temporaryThemeControl.padding(.trailing, 8).padding(.bottom, 2)
            }
        }.tint(accent).foregroundColor(paper)
        .onAppear { game.scene.reduceEffects = reduceMotion; game.scene.sound.setMuted(game.muted) }
        .onChange(of: appPhase) { phase in
            if phase != .active { game.scene.suspend() } else { game.scene.startMotion() }
        }
        .onChange(of: reduceMotion) { game.scene.reduceEffects = $0 }
        .onChange(of: game.posture) { UserDefaults.standard.set($0.rawValue, forKey: "classic.posture") }
        .onChange(of: game.theme) { theme in theme.save(); game.scene.setTheme(theme) }
        .onChange(of: game.muted) {
            UserDefaults.standard.set($0, forKey: "classic.muted"); game.scene.sound.setMuted($0)
        }
    }
    private var mainContent: some View {
        VStack(spacing: 12) {
            Text("KRAZEL GAMES").font(.system(size: 10, weight: .bold, design: .rounded)).tracking(4).foregroundColor(accent)
            switch game.phase {
            case .menu:
                Text(ink ? "TILT ARENA" : GameText.menuTitle).font(.system(size: 38, weight: .black, design: ink ? .serif : .rounded))
                Text(GameText.tagline).font(.subheadline).foregroundColor(.white.opacity(0.7))
                Text("\(GameText.best)  \(game.best.formatted())").font(.system(.callout, design: .monospaced))
                primary(game.posture == .custom && !game.hasCustom ? GameText.calibrateAndPlay : GameText.play, id: "play") { game.scene.play(restart: true) }
                if game.hasCustom || game.posture != .custom {
                    secondary(GameText.calibratePosture) { game.scene.calibrate(restart: true) }
                }
            case .calibrating:
                Image(systemName: "scope").font(.system(size: 38)).foregroundColor(accent)
                Text(GameText.postureHeading).font(.title.bold())
                Text(game.message).multilineTextAlignment(.center)
                ProgressView().tint(accent)
                secondary(GameText.cancel) { game.scene.cancelCalibration() }
            case .paused:
                Text(GameText.pause).font(.system(size: 38, weight: .black, design: ink ? .serif : .rounded))
                Text(game.message.isEmpty ? GameText.arenaWaits : game.message)
                    .font(.subheadline).multilineTextAlignment(.center).foregroundColor(.white.opacity(0.7))
                primary(GameText.resume, id: "resume") { game.scene.play(restart: false) }
                secondary(GameText.recalibrate) { game.scene.calibrate(restart: false) }
                Button(GameText.finishRun) { game.scene.finishPausedRun() }.font(.footnote).foregroundColor(.white.opacity(0.65))
            case .gameOver:
                Text(GameText.resultTitle).font(.title.bold())
                Text(game.resultScore.formatted()).font(.system(size: 38, weight: .black, design: ink ? .serif : .rounded)).foregroundColor(accent)
                Text("COMBO ×\(game.resultCombo)   ·   \(game.resultTime) s").font(.system(.callout, design: .monospaced))
                primary(GameText.replay, id: "replay") { game.scene.play(restart: true) }
                secondary(GameText.menu) { game.scene.menu() }
            case .failed:
                Text(GameText.moment).font(.title2.bold())
                Text(game.message).multilineTextAlignment(.center)
                primary(GameText.menu, id: "menu") { game.scene.menu() }
            case .running: EmptyView()
            }
        }.frame(maxWidth: .infinity)
    }
    // Temporary comparison control, independent of the player-facing settings.
    // Remove this overlay when the visual direction is final.
    private var temporaryThemeControl: some View {
        HStack(spacing: 2) {
            ForEach(VisualTheme.allCases) { theme in
                Button { game.theme = theme } label: {
                    Text(theme.title).font(.system(size: 9, weight: .medium))
                        .foregroundColor(game.theme == theme ? paper : paper.opacity(0.5))
                        .padding(.horizontal, 6).frame(height: 24)
                        .contentShape(Rectangle())
                }.buttonStyle(.plain).accessibilityIdentifier("theme-\(theme.rawValue)")
                .accessibilityAddTraits(game.theme == theme ? .isSelected : [])
            }
        }.padding(.horizontal, 3).background(.black.opacity(0.35), in: RoundedRectangle(cornerRadius: 4))
        .accessibilityElement(children: .contain).accessibilityIdentifier("temporary-theme-control")
    }
    private var settings: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(GameText.controlPosture).font(.system(size: 10, weight: .bold)).tracking(2).foregroundColor(accent)
            HStack(spacing: 7) {
                ForEach(TiltPosture.allCases) { posture in
                    Button { game.posture = posture } label: {
                        VStack(spacing: 6) {
                            Image(systemName: posture.symbol).font(.system(size: 23))
                                .rotation3DEffect(.degrees(posture == .inclined ? 65 : 0), axis: (x: 1, y: 0, z: 0))
                            Text(posture.title).font(.system(size: 10, weight: .semibold)).minimumScaleFactor(0.8).lineLimit(1)
                        }.frame(maxWidth: .infinity, minHeight: 67)
                        .foregroundColor(game.posture == posture ? .black : .white.opacity(0.75))
                        .background(game.posture == posture ? accent : paper.opacity(0.07), in: RoundedRectangle(cornerRadius: ink ? 4 : 12))
                    }.buttonStyle(.plain).accessibilityIdentifier("posture-\(posture.rawValue)")
                    .accessibilityAddTraits(game.posture == posture ? .isSelected : [])
                }
            }
            Text(game.posture.description).font(.system(size: 12)).foregroundColor(.white.opacity(0.7)).frame(minHeight: 34, alignment: .top)
            if game.posture == .custom {
                Text(game.hasCustom ? GameText.savedPosture : GameText.customHint)
                    .font(.system(size: 11, weight: .semibold)).foregroundColor(accent)
            }
            HStack {
                Text(GameText.sound).font(.system(size: 12)).foregroundColor(.white.opacity(0.65))
                Spacer()
                Button { game.muted.toggle() } label: {
                    Label(game.muted ? GameText.disabled : GameText.enabled, systemImage: game.muted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .font(.system(size: 12)).frame(minHeight: 36)
                }.accessibilityLabel(game.muted ? GameText.enableSound : GameText.muteSound)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(GameText.gameMode).font(.system(size: 10, weight: .bold)).tracking(2).foregroundColor(accent)
                if game.phase == .menu {
                    HStack(spacing: 7) {
                        ForEach(GameMode.allCases) { mode in
                            Button { game.selectMode(mode) } label: {
                                Text(mode.title).font(.system(size: 12, weight: .semibold))
                                    .frame(maxWidth: .infinity, minHeight: 32)
                                    .foregroundColor(game.mode == mode ? .black : paper)
                                    .background(game.mode == mode ? accent : paper.opacity(0.07), in: RoundedRectangle(cornerRadius: 4))
                            }.buttonStyle(.plain).accessibilityIdentifier("mode-\(mode.rawValue)")
                            .accessibilityAddTraits(game.mode == mode ? .isSelected : [])
                        }
                    }
                }
                Text(game.mode.description).font(.system(size: 10)).foregroundColor(.white.opacity(0.7))
            }
        }
    }
    private func primary(_ title: String, id: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title).font(.headline).foregroundColor(.black)
                .frame(maxWidth: .infinity, minHeight: 44).background(accent, in: RoundedRectangle(cornerRadius: ink ? 4 : 12))
        }.accessibilityIdentifier(id)
    }
    private func secondary(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title).font(.subheadline.weight(.semibold)).frame(maxWidth: .infinity, minHeight: 38)
                .background(paper.opacity(0.06), in: RoundedRectangle(cornerRadius: ink ? 4 : 10))
        }
    }
}

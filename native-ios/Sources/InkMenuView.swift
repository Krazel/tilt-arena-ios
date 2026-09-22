import SwiftUI
import UIKit

/// The same separate alpha assets and 874×402 layout used by the approved web menu.
enum InkMenuArt {
    // These are loose bundle resources, so load with UIKit rather than SwiftUI's asset-catalog lookup.
    static let panel = UIImage(named: "ink-menu-panel") ?? UIImage()
    enum Piece: CaseIterable, Hashable { case titleEn, titleEs, playEn, playEs, gold, charcoal
        var rect: CGRect {
            switch self {
            case .titleEn: return CGRect(x: 47, y: 311, width: 557, height: 122)
            case .titleEs: return CGRect(x: 654, y: 300, width: 568, height: 133)
            case .playEn: return CGRect(x: 198, y: 596, width: 276, height: 138)
            case .playEs: return CGRect(x: 765, y: 597, width: 355, height: 132)
            case .gold: return CGRect(x: 42, y: 871, width: 562, height: 124)
            case .charcoal: return CGRect(x: 652, y: 870, width: 559, height: 125)
            }
        }
    }
    static let pieces: [Piece: UIImage] = {
        guard let atlas = UIImage(named: "ink-menu-components")?.cgImage else { return [:] }
        return Dictionary(uniqueKeysWithValues: Piece.allCases.compactMap { piece in
            guard let image = atlas.cropping(to: piece.rect) else { return nil }
            return (piece, UIImage(cgImage: image))
        })
    }()
    static func image(_ piece: Piece) -> Image { Image(uiImage: pieces[piece] ?? UIImage()) }
}

/// Positions of independent blocks, deliberately separate from their artwork.
enum InkMenuLayout {
    static let size = CGSize(width: 874, height: 402)
    static let panel = CGRect(x: 70, y: 13, width: 734, height: 364)
    static let main = CGRect(x: 113, y: 63, width: 317, height: 290)
    static let settings = CGRect(x: 478, y: 64, width: 284, height: 290)
    static let divider = CGRect(x: 451, y: 49, width: 1, height: 282)
}

struct InkMenuView: View {
    @ObservedObject var game: GameSession
    let requestAction: (RunAction) -> Void
    private let paper = Color(UIColor(hex: "e8deca"))
    private let muted = Color(UIColor(hex: "d6cfbf"))
    private let dark = Color(UIColor(hex: "161713"))
    private var spanish: Bool { GameLanguage.current == .spanish }
    private var paused: Bool { game.phase == .paused }
    private var ended: Bool { game.phase == .gameOver }

    var body: some View {
        GeometryReader { geometry in
            let scale = min(geometry.size.width / 874, geometry.size.height / 402)
            ZStack(alignment: .topLeading) {
                Image(uiImage: InkMenuArt.panel).resizable().at(InkMenuLayout.panel).accessibilityHidden(true)
                Rectangle().fill(paper.opacity(0.5)).at(InkMenuLayout.divider).accessibilityHidden(true)
                main.at(InkMenuLayout.main)
                settings.at(InkMenuLayout.settings)
            }.frame(width: 874, height: 402)
                .foregroundColor(paper).buttonStyle(.plain)
                .scaleEffect(scale).position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("ink-illustrated-menu")
        }
    }

    private var main: some View {
        ZStack(alignment: .topLeading) {
            Text("KRAZEL GAMES").font(.system(size: 10.5, weight: .bold)).tracking(4.7)
                .foregroundColor(Color(InkArt.gold))
                .at(CGRect(x: 0, y: 0, width: 317, height: 13))
            title.at(CGRect(x: 0, y: 20, width: 317, height: 51))
            Text(ended ? "COMBO ×\(game.resultCombo)  ·  \(game.resultTime) s" : paused ? (game.message.isEmpty ? GameText.arenaWaits : game.message) : GameText.tagline)
                .font(.system(size: paused ? 12 : 15)).foregroundColor(muted)
                .multilineTextAlignment(.center).lineLimit(2).minimumScaleFactor(0.85)
                .at(CGRect(x: 0, y: 79, width: 317, height: 30))
            Text(ended ? game.resultScore.formatted() : "\(GameText.best)  \(game.best.formatted())")
                .font(ended ? .custom("Knewave-Regular", size: 26) : .system(size: 16, design: .monospaced))
                .tracking(ended ? 0 : 3).at(CGRect(x: 0, y: 112, width: 317, height: 22))
            primary.at(CGRect(x: 0, y: 139, width: 317, height: 47))
            actions.at(CGRect(x: 0, y: 197, width: 317, height: 43))
        }.frame(width: 317, height: 290, alignment: .topLeading)
    }

    @ViewBuilder private var title: some View {
        if game.phase == .menu && game.mode == .classic {
            InkMenuArt.image(spanish ? .titleEs : .titleEn).resizable().frame(width: 226, height: 51)
                .accessibilityLabel(GameText.menuTitle).accessibilityAddTraits(.isHeader)
        } else {
            Text(ended ? GameText.resultTitle : paused ? GameText.pause : game.mode.title.uppercased())
                .font(.custom("Knewave-Regular", size: ended ? 26 : 46)).lineLimit(1).minimumScaleFactor(0.7)
                .accessibilityAddTraits(.isHeader)
        }
    }

    private var primary: some View {
        Button {
            game.uiClick()
            if paused { game.scene.play(restart: false) }
            else if ended { requestAction(.restart) }
            else { game.scene.play(restart: true) }
        } label: {
            ZStack {
                InkMenuArt.image(.gold).resizable()
                if game.phase == .menu {
                    InkMenuArt.image(spanish ? .playEs : .playEn).resizable()
                        .frame(width: spanish ? 64 : 49, height: 24)
                } else {
                    Text(paused ? GameText.resume : GameText.restartRun)
                        .font(.custom("Knewave-Regular", size: 23)).foregroundColor(dark)
                }
            }.contentShape(Rectangle())
        }.accessibilityLabel(paused ? GameText.resume : ended ? GameText.restartRun : GameText.play)
            .accessibilityIdentifier(paused ? "resume" : ended ? "replay" : "play")
    }

    @ViewBuilder private var actions: some View {
        if paused {
            HStack(spacing: 9) {
                paintedButton(GameText.restartRun, id: "restart", size: 13) { requestAction(.restart) }
                paintedButton(GameText.mainMenu, id: "main-menu", size: 13) { requestAction(.mainMenu) }
            }
        } else if ended {
            paintedButton(GameText.mainMenu, id: "main-menu") { requestAction(.mainMenu) }
        } else {
            paintedButton(GameText.calibratePosture, id: "calibrate") { game.scene.calibrate(restart: true) }
        }
    }

    private var settings: some View {
        VStack(alignment: .leading, spacing: 14) {
            posture
            HStack {
                Text(GameText.sound).foregroundColor(muted)
                Spacer()
                Button { game.toggleSound() } label: {
                    Label(game.muted ? GameText.disabled : GameText.enabled, systemImage: game.muted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                }.accessibilityLabel(game.muted ? GameText.enableSound : GameText.muteSound)
            }.font(.system(size: 11.5)).frame(height: 27)
            modes
            if paused {
                paintedButton(GameText.recalibrate, id: "recalibrate", size: 14) { game.scene.calibrate(restart: false) }.frame(height: 38)
            }
        }.frame(width: 284, height: 290, alignment: .topLeading)
    }

    private var posture: some View {
        VStack(alignment: .leading, spacing: 5) {
            label(GameText.controlPosture)
            HStack(spacing: 7) {
                ForEach(TiltPosture.allCases) { posture in
                    Button { game.uiClick(); game.posture = posture } label: {
                        ZStack {
                            InkMenuArt.image(game.posture == posture ? .gold : .charcoal).resizable()
                            VStack(spacing: 8) {
                                Image(systemName: posture.symbol).font(.system(size: 25))
                                    .rotation3DEffect(.degrees(posture == .inclined ? 65 : 0), axis: (x: 1, y: 0, z: 0))
                                Text(posture.title).font(.system(size: 10.5, weight: .semibold))
                            }.foregroundColor(game.posture == posture ? dark : paper)
                        }.frame(height: 65).contentShape(Rectangle())
                    }.accessibilityIdentifier("posture-\(posture.rawValue)")
                        .accessibilityAddTraits(game.posture == posture ? .isSelected : [])
                }
            }
            Text(game.posture.description).font(.system(size: 11.5)).foregroundColor(muted)
                .frame(height: 30, alignment: .topLeading).fixedSize(horizontal: false, vertical: true)
            Text(game.posture == .custom ? (game.hasCustom ? GameText.savedPosture : GameText.customHint) : "")
                .font(.system(size: 10)).foregroundColor(Color(InkArt.gold)).frame(height: 13)
        }
    }

    private var modes: some View {
        VStack(alignment: .leading, spacing: 4) {
            label(GameText.gameMode)
            if game.phase == .menu {
                HStack(spacing: 7) {
                    ForEach(GameMode.allCases) { mode in
                        Button { game.uiClick(); game.selectMode(mode) } label: {
                            ZStack {
                                InkMenuArt.image(game.mode == mode ? .gold : .charcoal).resizable()
                                Text(mode.title).font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(game.mode == mode ? dark : paper)
                            }.frame(height: 30).contentShape(Rectangle())
                        }.accessibilityIdentifier("mode-\(mode.rawValue)")
                            .accessibilityAddTraits(game.mode == mode ? .isSelected : [])
                    }
                }
            }
            Text(game.mode.description).font(.system(size: 10)).foregroundColor(muted)
        }
    }

    private func label(_ value: String) -> some View {
        Text(value).font(.system(size: 11, design: .monospaced)).tracking(2).frame(height: 15)
    }
    private func paintedButton(_ title: String, id: String, size: CGFloat = 16, action: @escaping () -> Void) -> some View {
        Button { game.uiClick(); action() } label: {
            ZStack {
                InkMenuArt.image(.charcoal).resizable()
                Text(title).font(.system(size: size, weight: .semibold)).lineLimit(1).minimumScaleFactor(0.8)
            }.contentShape(Rectangle())
        }.accessibilityIdentifier(id)
    }
}

private extension View {
    func at(_ rect: CGRect) -> some View {
        frame(width: rect.width, height: rect.height).position(x: rect.midX, y: rect.midY)
    }
}

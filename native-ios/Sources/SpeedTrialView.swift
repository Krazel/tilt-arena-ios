import SwiftUI

// 07/10: the user chose 600 as final. Retain the isolated comparison code,
// but hide it and ignore every saved trial preference in the game.
enum SpeedTrial {
    static let enabled = false
    static let values = [600, 660, 720, 780, 840]
    static let key = "classic.speedTrial.v1"
    static func read(_ defaults: UserDefaults) -> Int {
        let value = defaults.integer(forKey: key)
        return enabled && values.contains(value) ? value : 600
    }
}

struct SpeedTrialView: View {
    @ObservedObject var game: GameSession
    let close: () -> Void
    private var spanish: Bool { GameLanguage.current == .spanish }
    var body: some View {
        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()
            VStack(spacing: 18) {
                Text(spanish ? "Pruebas de velocidad" : "Speed trials").font(.title2.bold())
                Text(spanish ? "Velocidad máxima · 600 es la actual" : "Maximum speed · 600 is the current speed").font(.subheadline)
                HStack(spacing: 10) {
                    ForEach(SpeedTrial.values, id: \.self) { value in
                        Button { game.uiClick(); game.selectTrialSpeed(value) } label: {
                            Text("\(value)").font(.system(size: 18, weight: .bold, design: .monospaced))
                                .frame(width: 62, height: 46)
                                .background(game.trialSpeed == value ? Color(InkArt.gold) : Color.white.opacity(0.12))
                                .foregroundColor(game.trialSpeed == value ? .black : Color(InkArt.paper))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }.buttonStyle(.plain).accessibilityIdentifier("trial-speed-\(value)")
                            .accessibilityAddTraits(game.trialSpeed == value ? .isSelected : [])
                    }
                }
                Text(spanish ? "Se aplica al jugar o reanudar. Se guarda para la siguiente prueba." : "Applied when you play or resume. Saved for your next trial.")
                    .font(.footnote).multilineTextAlignment(.center)
                Text(spanish ? "Tras morir, la música del menú sube suavemente durante 2,5 s." : "After death, menu music fades in gently over 2.5 s.")
                    .font(.footnote).foregroundColor(Color(InkArt.paper).opacity(0.7)).multilineTextAlignment(.center)
                Button(spanish ? "Listo" : "Done", action: close)
                    .font(.headline).padding(.horizontal, 28).padding(.vertical, 10)
                    .background(Color.white.opacity(0.12)).clipShape(RoundedRectangle(cornerRadius: 6))
                    .accessibilityIdentifier("speed-trials-close")
            }.padding(24).frame(maxWidth: 480)
                .background(Color(UIColor(hex: "201f1c")))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(InkArt.gold).opacity(0.5)))
                .foregroundColor(Color(InkArt.paper)).padding(12)
        }
    }
}

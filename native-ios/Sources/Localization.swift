import Foundation

/// The game ships with English as its fallback and Castilian Spanish when the
/// device's preferred language is any Spanish variant.
enum GameLanguage: Equatable {
    case english
    case spanish

    static func resolve(preferredLanguages: [String]) -> GameLanguage {
        let preferred = preferredLanguages.first?.lowercased() ?? ""
        return preferred.hasPrefix("es") ? .spanish : .english
    }

    static var current: GameLanguage { resolve(preferredLanguages: Locale.preferredLanguages) }
}

enum GameText {
    private static var spanish: Bool { GameLanguage.current == .spanish }
    private static func text(_ english: String, _ castellano: String) -> String {
        spanish ? castellano : english
    }

    static var menuTitle: String { text("CLASSIC", "CLÁSICO") }
    static var tagline: String { text("Dodge. Collect. Chain.", "Esquiva. Recoge. Encadena.") }
    static var play: String { text("Play", "Jugar") }
    static var calibrateAndPlay: String { text("Calibrate & play", "Calibrar y jugar") }
    static var calibratePosture: String { text("Calibrate posture", "Calibrar postura") }
    static var postureHeading: String { text("Your posture", "Tu postura") }
    static var cancel: String { text("Cancel", "Cancelar") }
    static var pause: String { text("PAUSE", "PAUSA") }
    static var arenaWaits: String { text("The arena is waiting.", "La arena te espera.") }
    static var resume: String { text("Resume", "Reanudar") }
    static var recalibrate: String { text("Recalibrate", "Recalibrar") }
    static var finishRun: String { text("End run", "Terminar partida") }
    static var resultTitle: String { text("By one point…", "Por un punto…") }
    static var replay: String { text("Play again", "Otra partida") }
    static var menu: String { text("Menu", "Menú") }
    static var moment: String { text("One moment…", "Un momento…") }
    static var controlPosture: String { text("CONTROL POSTURE", "POSTURA DE CONTROL") }
    static var visualStyle: String { text("VISUAL STYLE", "ESTILO VISUAL") }
    static var originalStyle: String { text("Original", "Original") }
    static var savedPosture: String { text("Posture saved · ready to play", "Postura guardada · lista para jugar") }
    static var customHint: String { text("Tap Calibrate to save your posture", "Pulsa Calibrar para guardar tu postura") }
    static var sound: String { text("Sound", "Sonido") }
    static var enabled: String { text("On", "Activado") }
    static var disabled: String { text("Off", "Desactivado") }
    static var enableSound: String { text("Turn sound on", "Activar sonido") }
    static var muteSound: String { text("Mute sound", "Silenciar sonido") }
    static var arenaAccessibility: String { text("Classic arena. Tilt the iPhone to dodge dots and collect powers.", "Arena clásica. Inclina el iPhone para esquivar puntos y recoger poderes.") }
    static var pauseAccessibility: String { text("Pause run", "Pausar partida") }
    static var best: String { text("BEST", "RÉCORD") }
    static var chainPowers: String { text("CHAIN THE POWERS", "ENLAZA LAS ARMAS") }

    static var calibrationHold: String { text("Hold the iPhone still and comfortably for a moment.", "Mantén el iPhone quieto y cómodo un instante.") }
    static var simulatorDrag: String { text("Simulator: drag from anywhere to move the arrow.", "Simulador: arrastra desde cualquier punto para mover la flecha.") }
    static var noMotionSensor: String { text("This device does not provide the required motion sensor.", "Este dispositivo no ofrece el sensor de movimiento necesario.") }
    static var sensorPermission: String { text("No sensor data is arriving. Check Motion permissions in Settings and try again.", "No llega información del sensor. Revisa los permisos de movimiento en Ajustes y vuelve a intentarlo.") }
    static var unstablePosture: String { text("A stable posture could not be found. Rest your arms and try again.", "No se ha podido fijar una postura estable. Apoya los brazos y vuelve a intentarlo.") }
    static var rotatedPhone: String { text("You rotated the iPhone. Tap Resume when you are comfortable.", "Has girado el iPhone. Pulsa Reanudar cuando estés cómodo.") }
    static var waitingForSensor: String { text("Waiting for the sensor. Tap Resume to try again.", "Esperando al sensor. Pulsa Reanudar para volver a intentarlo.") }
    static var startFailure: String { text("The game could not start. Return to the menu and try again.", "No se ha podido iniciar el juego. Vuelve al menú para intentarlo de nuevo.") }

    static func powerName(_ id: String) -> String {
        switch id {
        case "nuke": return text("Bomb", "Bomba")
        case "wave": return text("Wave", "Onda")
        case "missiles": return text("Missiles", "Misiles")
        case "frost": return text("Ice", "Hielo")
        case "bubble": return text("Shield", "Protección")
        case "spikes": return text("Spikes", "Pinchos")
        case "vortex": return text("Gravity", "Gravedad")
        case "lightning": return text("Lightning", "Rayos")
        case "burn": return text("Fire", "Fuego")
        case "boomerang": return text("Boomerang", "Bumerán")
        default: return id.capitalized
        }
    }
}

import XCTest
import AVFoundation
@testable import TiltArena

final class ApprovedAudioTests: XCTestCase {
    private func event(_ kind: String, power: String? = nil, frozen: Bool = false) -> ClassicFrame.Event {
        var event = ClassicFrame.Event(kind: kind, x: nil, y: nil, radius: nil, angle: nil, toX: nil, toY: nil, color: nil, power: power, value: nil, bonus: nil)
        event.frozen = frozen
        return event
    }
    func testAllApprovedResourcesDecodeOnIOSAndChargesMatchSimulation() throws {
        let catalog = try ApprovedAudio.load()
        XCTAssertEqual(catalog.assets.count, 16)
        XCTAssertEqual(catalog.playlist, ["music-a", "music-b", "music-c"])
        XCTAssertEqual(catalog.menu, "music-menu")
        for (name, asset) in catalog.assets {
            let file = asset.file as NSString
            let url = try XCTUnwrap(Bundle.main.url(forResource: file.deletingPathExtension, withExtension: file.pathExtension))
            let player = try AVAudioPlayer(contentsOf: url)
            XCTAssertGreaterThan(player.duration, 0)
            if name.hasSuffix("-charge") { XCTAssertEqual(player.duration, 0.5, accuracy: 0.001) }
            if name.hasPrefix("music") { XCTAssertGreaterThan(player.duration, 60) }
        }
        XCTAssertNotNil(Bundle.main.url(forResource: "Audio-Credits", withExtension: "txt"))
        for name in ["classic-loop", "death", "hit", "pickup"] { XCTAssertNil(Bundle.main.url(forResource: name, withExtension: "wav")) }
    }
    func testRejectedAndUnreviewedEventsStaySilent() {
        let silent = ["death", "combo", "warning", "freeze", "wave", "blast", "lightning"]
        XCTAssertEqual(AudioCuePolicy.cues(events: silent.map { event($0) }, boomerangCharging: false), [])
        for power in ["nuke", "wave", "missiles", "frost", "bubble", "spikes"] {
            XCTAssertEqual(AudioCuePolicy.cues(events: [event("pickup", power: power)], boomerangCharging: false), ["pickup"])
        }
    }
    func testChargeLaunchCatchAndFrozenKillRouting() {
        XCTAssertEqual(AudioCuePolicy.cues(events: [event("pickup", power: "burn"), event("kill")], boomerangCharging: false), ["pickup", "burn-charge", "hit"])
        XCTAssertEqual(AudioCuePolicy.cues(events: [event("burnLaunch"), event("boomerangLaunch")], boomerangCharging: false), ["burn-launch", "boomerang-launch"])
        XCTAssertEqual(AudioCuePolicy.cues(events: [event("kill", frozen: true)], boomerangCharging: false), ["shatter"])
        XCTAssertEqual(AudioCuePolicy.cues(events: [event("boomerangCatch")], boomerangCharging: true), ["pickup", "boomerang-charge"])
        XCTAssertEqual(AudioCuePolicy.cues(events: [event("boomerangCatch")], boomerangCharging: false), ["pickup"])
        XCTAssertEqual(AudioCuePolicy.cues(events: [event("electricPulse"), event("electricPulse")], boomerangCharging: false), ["lightning"])
    }
}

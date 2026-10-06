import Foundation

/// Native audio calls may wait on the audio service; serialize them off the
/// SpriteKit frame thread, including session notifications and delegates.
final class ClassicAudioDriver {
    typealias Callback = (@escaping () -> Void) -> Void
    private final class PendingFrame {
        var value: ClassicFrame
        init(_ value: ClassicFrame) { self.value = value }
    }
    private let queue: DispatchQueue
    private let lock = NSLock()
    private var pending: PendingFrame?
    private let factory: (@escaping Callback) -> ClassicSound
    private lazy var sound: ClassicSound = factory { [weak self] action in self?.queue.async(execute: action) }
    init(queue: DispatchQueue = DispatchQueue(label: "com.dmkr.tiltarena.audio", qos: .userInteractive),
         factory: @escaping (@escaping Callback) -> ClassicSound = { ClassicSound(dispatchCallback: $0) }) {
        self.queue = queue; self.factory = factory
        queue.async { [weak self] in _ = self?.sound }
    }
    private func command(_ body: @escaping (ClassicSound) -> Void) {
        lock.lock()
        // Controls are ordering barriers: a later frame cannot replace one
        // queued before pause, restart, mute or background suspension.
        pending = nil
        queue.async { [weak self] in guard let self else { return }; body(self.sound) }
        lock.unlock()
    }
    func consume(_ frame: ClassicFrame) {
        lock.lock()
        if let pending {
            var seen = Set<String>()
            let events = (pending.value.events + frame.events).filter {
                seen.insert("\($0.kind)|\($0.power ?? "")|\($0.frozen == true)|\($0.color ?? "")").inserted
            }
            pending.value = frame.audioSnapshot(events: Array(events.prefix(64)))
        } else {
            let slot = PendingFrame(frame.audioSnapshot(events: frame.events))
            pending = slot
            queue.async { [weak self] in
                guard let self else { return }
                self.lock.lock()
                let value = slot.value
                if self.pending === slot { self.pending = nil }
                self.lock.unlock()
                self.sound.consume(value)
            }
        }
        lock.unlock()
    }
    func startRun() { command { $0.startRun() } }
    func pause() { command { $0.pause() } }
    func playMusic() { command { $0.playMusic() } }
    func setMode(_ mode: ClassicSound.Mode) { command { $0.setMode(mode) } }
    func setMuted(_ value: Bool) { command { $0.setMuted(value) } }
    func setSuspended(_ value: Bool) { command { $0.setSuspended(value) } }
    func uiClick() { command { $0.uiClick() } }
    /// Asynchronous test fence; never block the render thread.
    func afterPending(_ completion: @escaping () -> Void) { command { _ in completion() } }
}

private extension ClassicFrame {
    func audioSnapshot(events: [Event]) -> ClassicFrame {
        ClassicFrame(state: state, mode: mode, time: time, score: score, combo: combo,
            comboBase: comboBase, pendingBonus: pendingBonus, bestCombo: bestCombo,
            kills: kills, comboRemaining: comboRemaining, player: player, beam: nil,
            enemies: [], pickups: [], projectiles: [], fields: fields, events: events)
    }
}

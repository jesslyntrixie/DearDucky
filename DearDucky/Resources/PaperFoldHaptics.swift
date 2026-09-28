// DearDucky/Resources
import CoreHaptics
import UIKit

final class PaperFoldHaptics {
    private var engine: CHHapticEngine?
    private let selection = UISelectionFeedbackGenerator()

    init() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        engine = try? CHHapticEngine()
        engine?.resetHandler = { [weak self] in try? self?.engine?.start() }
        engine?.stoppedHandler = { _ in }
        try? engine?.start()
        selection.prepare()
    }

    // Soft rustle as your finger first touches the paper
    func paperTouch() {
        playPattern([
            .continuous(intensity: 0.28, sharpness: 0.08, at: 0, duration: 0.14),
            .transient(intensity: 0.40, sharpness: 0.55, at: 0.10)
        ])
    }

    // The crease snap at the end of each fold — double-punch, gets heavier each step
    func creaseSnap(step: Int) {
        let base = Float(step + 1) / 5.0          // 0.2 → 1.0
        let sharp: Float = 0.55 + base * 0.45     // 0.55 → 1.0
        playPattern([
            .transient(intensity: base * 0.65, sharpness: sharp * 0.7, at: 0),
            .transient(intensity: base,         sharpness: sharp,       at: 0.08),
            .transient(intensity: base * 0.35, sharpness: 0.3,          at: 0.20)  // echo
        ])
    }

    // Mid-drag resistance tick (fire at 50 % and 85 % of drag progress)
    func resistanceTick() { selection.selectionChanged() }

    // Final success: three rising pulses
    func finalFold() {
        playPattern([
            .transient(intensity: 0.50, sharpness: 0.7, at: 0),
            .transient(intensity: 0.75, sharpness: 0.85, at: 0.14),
            .transient(intensity: 1.00, sharpness: 1.0,  at: 0.30),
            .continuous(intensity: 0.20, sharpness: 0.1, at: 0.32, duration: 0.25)
        ])
    }

    // MARK: - Private

    private enum Event {
        case transient(intensity: Float, sharpness: Float, at: TimeInterval)
        case continuous(intensity: Float, sharpness: Float, at: TimeInterval, duration: TimeInterval)

        var chEvent: CHHapticEvent {
            switch self {
            case let .transient(i, s, t):
                return CHHapticEvent(eventType: .hapticTransient,
                                     parameters: params(i, s), relativeTime: t)
            case let .continuous(i, s, t, d):
                return CHHapticEvent(eventType: .hapticContinuous,
                                     parameters: params(i, s), relativeTime: t, duration: d)
            }
        }
        private func params(_ i: Float, _ s: Float) -> [CHHapticEventParameter] {
            [.init(parameterID: .hapticIntensity, value: i),
             .init(parameterID: .hapticSharpness, value: s)]
        }
    }

    private func playPattern(_ events: [Event]) {
        guard let engine, CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred(); return
        }
        guard let pattern = try? CHHapticPattern(events: events.map(\.chEvent), parameters: []),
              let player  = try? engine.makePlayer(with: pattern) else { return }
        try? player.start(atTime: 0)
    }
}

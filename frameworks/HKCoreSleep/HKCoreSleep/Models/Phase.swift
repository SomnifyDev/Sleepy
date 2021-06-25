import Foundation

public class Phase {

    enum PhaseType { case light, medium, deep }

    let interval: DateInterval
    let phaseType: PhaseType
    let coefficient: Double

    init(interval: DateInterval, phaseType: PhaseType, probabillity: Double) {
        self.interval = interval
        self.phaseType = phaseType
        self.coefficient = probabillity
    }
}

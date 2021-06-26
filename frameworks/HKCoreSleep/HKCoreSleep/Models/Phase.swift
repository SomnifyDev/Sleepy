import Foundation

public enum Conditions { case light, medium, deep }

public struct Phase {

    public let interval: DateInterval
    public let condition: Conditions
    public let verdictCoefficient: Double

    public init(interval: DateInterval, condition: Conditions, verdictCoefficient: Double) {
        self.interval = interval
        self.condition = condition
        self.verdictCoefficient = verdictCoefficient
    }
}

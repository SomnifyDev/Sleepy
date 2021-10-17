import Foundation

public enum Condition {
    case awake
    case light
    case deep
}

public struct Phase {
    public let interval: DateInterval
    public let condition: Condition
    public let verdictCoefficient: Double
    public let meanHeartRate: Double?
    public let chartPoint: Double
}

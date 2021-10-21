import Foundation

public enum Condition {
    case awake
    case light
    case deep
}

public struct SampleData {
    public let date: Date
    public let value: Double
}

public struct Phase {
    public let interval: DateInterval
    public let condition: Condition
    public let heartData: [SampleData]
    public let energyData: [SampleData]
    public let breathData: [SampleData]

    public let verdictCoefficient: Double
    public let meanHeartRate: Double?
    public let chartPoint: Double
}

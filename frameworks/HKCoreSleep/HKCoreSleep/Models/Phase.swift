// Copyright (c) 2021 Sleepy.

import Foundation

public enum Condition
{
    case awake
    case light
    case deep
}

public struct SampleData
{
    public let date: Date
    public let value: Double

    public init(date: Date, value: Double)
    {
        self.date = date
        self.value = value
    }
}

public struct Phase
{
    public let interval: DateInterval
    public let condition: Condition
    public let heartData: [SampleData]
    public let energyData: [SampleData]
    public let breathData: [SampleData]

    // remove or refactor
    public let verdictCoefficient: Double
    public let meanHeartRate: Double?
    public let chartPoint: Double
}

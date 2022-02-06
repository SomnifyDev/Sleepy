// Copyright (c) 2022 Sleepy.

import Foundation

public struct StatsIndicatorModel {
    public let name: String
    public let description: String
    public let value: Double
    public let valueNormInterval: ClosedRange<Double>
    public let unit: String
    public let feedback: String
    public let dateInterval: DateInterval

    public init(
        name: String,
        description: String,
        value: Double,
        valueNormInterval: ClosedRange<Double>,
        unit: String,
        feedback: String,
        dateInterval: DateInterval
    ) {
        self.name = name
        self.description = description
        self.value = value
        self.valueNormInterval = valueNormInterval
        self.unit = unit
        self.feedback = feedback
        self.dateInterval = dateInterval
    }
}

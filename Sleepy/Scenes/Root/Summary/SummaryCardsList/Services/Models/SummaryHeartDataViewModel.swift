// Copyright (c) 2022 Sleepy.

import Foundation
import HKStatistics
import UIComponents

struct SummaryHeartDataViewModel {
    let heartRateData: [StandardChartView.DisplayItem]
    let maxHeartRate: String
    let minHeartRate: String
    let averageHeartRate: String
    let indicators: [StatsIndicatorViewModel]

    internal init(heartRateData: [StandardChartView.DisplayItem], maxHeartRate: String, minHeartRate: String, averageHeartRate: String, indicators: [StatsIndicatorModel])
    {
        self.heartRateData = heartRateData
        self.maxHeartRate = maxHeartRate
        self.minHeartRate = minHeartRate
        self.averageHeartRate = averageHeartRate
        self.indicators = indicators.map {
            StatsIndicatorViewModel(
                name: $0.name,
                description: $0.description,
                value: $0.value,
                valueNormInterval: $0.valueNormInterval,
                unit: $0.unit,
                feedback: $0.feedback
            )
        }
    }
}

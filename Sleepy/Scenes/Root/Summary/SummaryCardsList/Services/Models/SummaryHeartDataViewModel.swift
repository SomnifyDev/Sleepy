// Copyright (c) 2021 Sleepy.

import Foundation
import HKStatistics
import UIComponents

struct SummaryHeartDataViewModel {
	let heartRateData: [Double]
	let maxHeartRate: String
	let minHeartRate: String
	let averageHeartRate: String
	let indicators: [StatsIndicatorViewModel]

	internal init(heartRateData: [Double], maxHeartRate: String, minHeartRate: String, averageHeartRate: String, indicators: [HKStatisticsProvider.StatsIndicatorModel]) {
		self.heartRateData = heartRateData
		self.maxHeartRate = maxHeartRate
		self.minHeartRate = minHeartRate
		self.averageHeartRate = averageHeartRate
		var indicatorArr: [StatsIndicatorViewModel] = []
		indicators.forEach {
			indicatorArr.append(StatsIndicatorViewModel(name: $0.name,
			                                            description: $0.description,
			                                            value: $0.value,
			                                            valueNormInterval: $0.valueNormInterval,
			                                            unit: $0.unit,
			                                            feedback: $0.feedback))
		}
		self.indicators = indicatorArr
	}
}

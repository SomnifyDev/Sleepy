// Copyright (c) 2021 Sleepy.

import Foundation
import HKStatistics
import UIComponents

struct SummaryHeartDataViewModel {
	let heartRateData: [Double]
	let maxHeartRate: String
	let minHeartRate: String
	let averageHeartRate: String
	let indicators: [StatsIndicatorView.StatsIndicatorModel]

	internal init(heartRateData: [Double], maxHeartRate: String, minHeartRate: String, averageHeartRate: String, indicators: [HKStatisticsProvider.StatsIndicatorModel]) {
		self.heartRateData = heartRateData
		self.maxHeartRate = maxHeartRate
		self.minHeartRate = minHeartRate
		self.averageHeartRate = averageHeartRate
		var indicatorArr: [StatsIndicatorView.StatsIndicatorModel] = []
		indicators.forEach {
			indicatorArr.append(StatsIndicatorView.StatsIndicatorModel(name: $0.name,
			                                                           description: $0.description,
			                                                           value: $0.value,
			                                                           valueNormInterval: $0.valueNormInterval,
			                                                           unit: $0.unit,
			                                                           feedback: $0.feedback))
		}
		self.indicators = indicatorArr
	}
}

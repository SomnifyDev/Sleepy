// Copyright (c) 2021 Sleepy.

import Foundation
import HealthKit
import HKCoreSleep

typealias HealthType = HKService.HealthType

final class HKGeneralStatisticsProvider {
	// MARK: - Methods

	func data(healthType _: HealthType, data: [SampleData]) -> [Double] {
		return data.map { $0.value }
	}

	func data(healthType: HealthType, indicator: Indicator, data: [HKSample]) -> Double? {
		switch healthType {
		case .energy:
			return self.handleForQuantitySample(indicator: indicator, data: data, unit: HKUnit.kilocalorie())

		case .heart, .respiratory:
			return self.handleForQuantitySample(indicator: indicator, data: data, unit: HKUnit(from: "count/min"))

		case .asleep, .inbed:
			return self.handleForCategorySample(indicator: indicator, data: data)
		}
	}

	// MARK: - Private methods

	private func handleForCategorySample(indicator: Indicator,
	                                     data: [HKSample]) -> Double?
	{
		guard
			let categData = data as? [HKCategorySample],
			!categData.isEmpty else
		{
			return nil
		}
		return self.dataByIndicator(indicator: indicator, data: categData.map { Double($0.endDate.minutes(from: $0.startDate)) })
	}

	private func handleForQuantitySample(indicator: Indicator,
	                                     data: [HKSample],
	                                     unit: HKUnit) -> Double?
	{
		guard
			let quantityData = data as? [HKQuantitySample],
			!quantityData.isEmpty else
		{
			return nil
		}
		return self.dataByIndicator(indicator: indicator, data: quantityData.map { $0.quantity.doubleValue(for: unit) })
	}

	private func dataByIndicator(indicator: Indicator,
	                             data: [Double]) -> Double?
	{
		switch indicator {
		case .min:
			return data.min() ?? nil
		case .max:
			return data.max() ?? nil
		case .mean:
			return (data.reduce(0.0) { $0 + $1 }) / Double(data.count)
		case .sum:
			return data.reduce(0.0) { $0 + $1 }
		}
	}
}

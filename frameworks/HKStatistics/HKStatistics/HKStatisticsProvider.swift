// Copyright (c) 2021 Sleepy.

import Foundation
import HealthKit
import HKCoreSleep

public final class HKStatisticsProvider {
	// MARK: - Properties

	private let healthService: HKService
	private let sleep: Sleep?
	private let numericTypesStatisticsProvider = HKNumericTypesStatisticsProvider()
	private let phasesStatisticsProvider = HKPhasesStatisticsProvider()
	private let sleepStatisticsProvider = HKSleepStatisticsProvider()
	private let generalStatisticsProvider = HKGeneralStatisticsProvider()
	private let dailyStatisticsProvider = HKDailyStatisticsProvider()

	// MARK: - Init

	public init(sleep: Sleep?, healthService: HKService) {
		self.sleep = sleep
		self.healthService = healthService
	}

	// MARK: - Public methods

	/// Returns numeric data (heart, energy etc) by data type with indicator (min, max etc)
	public func getData(dataType: NumericData,
	                    indicator: Indicator,
	                    roundPlaces: Int = 2) -> Double?
	{
		guard let sleep = sleep else {
			return nil
		}
		return self.numericTypesStatisticsProvider.numericData(dataType: dataType, indicator: indicator, sleep: sleep)?.rounded(toPlaces: roundPlaces)
	}

	/// Returns phases data by data type
	public func getData(dataType: PhasesData) -> Any? {
		guard let sleep = sleep else {
			return nil
		}
		let flattenArrayPhases = sleep.samples.compactMap { (element: MicroSleep) -> [Phase]? in
			element.phases
		}
		let phases = flattenArrayPhases.flatMap { $0 }

		return self.phasesStatisticsProvider.phasesData(dataType: dataType, data: phases)
	}

	/// Returns sleep data by data type
	public func getData(dataType: SleepData) -> Int? {
		guard let sleep = sleep else {
			return nil
		}
		return self.sleepStatisticsProvider.sleepData(dataType: dataType, sleep: sleep)
	}

	/// Returns today sleep hata of special health type (energy, heart, asleep, inbed, respiratory)
	public func getTodaySleepData(healthtype: HKService.HealthType) -> [Double] {
		guard let sleep = sleep else {
			return []
		}
		return self.dailyStatisticsProvider.data(healthtype: healthtype, sleep: sleep)
	}

	/// Returns today sleep interval with interval type (inbed, asleep)
	public func getTodaySleepInterval(intervalType: SleepInterval) -> DateInterval? {
		guard let sleep = sleep else {
			return nil
		}
		return self.dailyStatisticsProvider.intervalBoundary(intervalType: intervalType, sleep: sleep)
	}

	/// Returns data by interval with health type and indicator from CoreSleep
	public func getData(healthType: HKService.HealthType,
	                    indicator: Indicator,
	                    interval: DateInterval,
	                    bundlePrefixes: [String] = ["com.apple"],
	                    completion: @escaping (Double?) -> Void)
	{
		self.healthService.readData(type: healthType,
		                            interval: interval,
		                            ascending: true,
		                            bundlePrefixes: bundlePrefixes) { [weak self] _, sleepData, _ in
			completion(self?.generalStatisticsProvider.data(healthType: healthType, indicator: indicator, data: sleepData ?? []))
		}
	}

	/// Returns meta data by interval with health type from CoreSleep
	public func getData(healthType: HKService.HealthType,
	                    interval: DateInterval,
	                    bundlePrefixes: [String] = ["com.apple"],
	                    completion: @escaping ([Double]) -> Void)
	{
		self.healthService.readData(type: healthType,
		                            interval: interval,
		                            ascending: true,
		                            bundlePrefixes: bundlePrefixes) { [weak self] _, samples, _ in
			switch healthType {
			case .energy:
				if let samples = samples as? [HKQuantitySample] {
					let data = samples.map { SampleData(date: $0.startDate, value: $0.quantity.doubleValue(for: HKUnit.kilocalorie())) }
					completion(self?.generalStatisticsProvider.data(healthType: healthType, data: data) ?? [])
				}
			case .heart, .respiratory:
				if let samples = samples as? [HKQuantitySample] {
					let data = samples.map { SampleData(date: $0.startDate, value: $0.quantity.doubleValue(for: HKUnit(from: "count/min"))) }
					completion(self?.generalStatisticsProvider.data(healthType: healthType, data: data) ?? [])
				}
			case .asleep, .inbed:
				if let samples = samples {
					let data = samples.map { abs(Double($0.startDate.minutes(from: $0.endDate))) }
					completion(data)
				}
			}
		}
	}

	/// Returns meta data by interval with health type and indicator
	public func getMetaData(healthType: HKService.HealthType,
	                        indicator _: Indicator,
	                        interval: DateInterval,
	                        bundlePrefixes _: [String] = ["com.apple"],
	                        completion: @escaping (Double?) -> Void)
	{
		self.healthService.readMetaData(key: healthType.metaDataKey,
		                                interval: interval,
		                                ascending: true) { _, data, _ in
			completion(data)
		}
	}
}

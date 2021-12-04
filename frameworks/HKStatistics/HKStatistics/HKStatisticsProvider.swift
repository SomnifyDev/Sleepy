// Copyright (c) 2021 Sleepy.

import Foundation
import HealthKit
import HKCoreSleep
import SwiftUI
import UIComponents

public final class HKStatisticsProvider {
	public struct StatsIndicatorModel {
		public let name: String
		public let description: String
		public let value: Double
		public let valueNormInterval: ClosedRange<Double>
		public let unit: String
		public let feedback: String

		public init(name: String, description: String, value: Double, valueNormInterval: ClosedRange<Double>, unit: String, feedback: String) {
			self.name = name
			self.description = description
			self.value = value
			self.valueNormInterval = valueNormInterval
			self.unit = unit
			self.feedback = feedback
		}
	}

	// MARK: - Properties

	private let healthService: HKService
	private let sleep: Sleep?
	private let numericTypesStatisticsProvider: HKNumericTypesStatisticsProvider
	private let phasesStatisticsProvider = HKPhasesStatisticsProvider()
	private let sleepStatisticsProvider = HKSleepStatisticsProvider()
	private let generalStatisticsProvider = HKGeneralStatisticsProvider()
	private let dailyStatisticsProvider = HKDailyStatisticsProvider()

	// MARK: - Init

	public init(sleep: Sleep?, healthService: HKService) {
		self.sleep = sleep
		self.healthService = healthService
		self.numericTypesStatisticsProvider = HKNumericTypesStatisticsProvider(healthService: healthService)
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
		return self.phasesStatisticsProvider.phasesData(dataType: dataType, data: sleep.phases)
	}

	/// Returns sleep data by data type
	public func getData(dataType: SleepData) -> Int? {
		guard let sleep = sleep else {
			return nil
		}
		return self.sleepStatisticsProvider.sleepData(dataType: dataType, sleep: sleep)
	}

	/// Returns metrics data like ssdn of heart rythems by metric type
	public func getData(dataType: MetricsData, completion: @escaping (HKStatisticsProvider.StatsIndicatorModel?) -> Void) {
		switch dataType {
		case .rmssd:
			self.numericTypesStatisticsProvider.calculateRMSSD(completion: completion)
		case .ssdn:
			self.numericTypesStatisticsProvider.calculateSSDN(completion: completion)
		}
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

// Copyright (c) 2021 Sleepy.

import Foundation
import HealthKit
import HKCoreSleep

public final class HKNumericTypesStatisticsProvider {
	let healthService: HKService

	init(healthService: HKService) {
		self.healthService = healthService
	}

	// MARK: - Methods

	func numericData(dataType: NumericData,
	                 indicator: Indicator,
	                 sleep: Sleep) -> Double?
	{
		switch dataType {
		case .heart:
			return self.data(indicator, sleep.phases?.flatMap { $0.heartData } ?? [])
		case .energy:
			return self.data(indicator, sleep.phases?.flatMap { $0.energyData } ?? [])
		case .respiratory:
			return self.data(indicator, sleep.phases?.flatMap { $0.breathData } ?? [])
		}
	}

	// MARK: - Private methods

	private func data(_ indicator: Indicator,
	                  _ data: [SampleData]) -> Double?
	{
		guard !data.isEmpty else {
			return nil
		}
		return self.dataByIndicator(indicator: indicator, data: data.map { $0.value })
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

	/// It is calculated by first dividing the 24 h record into 288 5 min segments and then calculating the standard deviation of all NN intervals contained within each segment
	/// https://www.sciencedirect.com/science/article/pii/S0735109797005548 for numbers
	public func calculateSSDN(completion: @escaping (HKStatisticsProvider.StatsIndicatorModel?) -> Void) {
		enum Constants {
			static let name = "SDNN Index (SDNNI)"
			static let unit = "ms"
			static let description = "The SDNNI primarily reflects autonomic influence on HRV"
			static let normalValuesBy10YearsAge: [ClosedRange<Double>] = [
				48.0 ... 113.0,
				48.0 ... 113.0,
				42.0 ... 107.0,
				36.0 ... 100,
				30.0 ... 94.0,
				24.0 ... 88.0,
				18.0 ... 82.0,
				11.0 ... 77.0,
				5.0 ... 70.0,
				0 ... 58,
			]
			static let positiveFeedback = "Looks like you’re in good shape and there are no signs of fatigue"
			static let negativeFeedback = "Looks like you have some signs of fatigue"
		}

		HKService.requestPermissions { [weak self] result, error in
			guard result, error == nil,
			      let birthday = HKService.readBirthday()?.date, birthday.years(from: Date()) <= 90 else { return }
			let currentAge = birthday.years(from: Date())

			self?.healthService.readData(type: .heart,
			                             interval: .init(start: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, end: Date())) { _, samples, error in
				guard error == nil, let samples = samples as? [HKQuantitySample] else {
					completion(nil)
					return
                }

				var standardDeviations: [Double] = []
				var tmpDate: Date?
				var tmpValues: [Double] = []

				// dividing heart rate samples in chronological order by 5 minutes interval each
				// then calculating Deviation for each one of intervals
				samples.forEach { sample in
					if let startIntervalDate = tmpDate,
					   abs(sample.startDate.minutes(from: startIntervalDate)) > 5 {
						if !tmpValues.isEmpty {
							// we need at least 2 values for standard deviasion, so we do this trick
							// when there is only 1 sample in 5 minute interval
							if tmpValues.count == 1 { tmpValues.append(tmpValues.first!) }

							// standard Deviation calculation
							let sum = tmpValues.reduce(0, +)
							let mean = Double(sum) / Double(tmpValues.count)

							for index in 0 ..< tmpValues.count {
								tmpValues[index] -= mean
								tmpValues[index] *= tmpValues[index]
							}

							let result = sqrt(tmpValues.reduce(0, +) / Double(tmpValues.count - 1))
							standardDeviations.append(result)
						}

						tmpValues = []
						tmpDate = sample.startDate
					} else if tmpDate == nil {
							tmpDate = sample.startDate
					}

					tmpValues.append(60000 / sample.quantity.doubleValue(for: HKUnit(from: "count/min")))
				}

				let sum = standardDeviations.reduce(0, +)
				if sum > 0 {
					let result = Double(sum) / Double(standardDeviations.count)
					let normalRange = Constants.normalValuesBy10YearsAge[currentAge / 10]
					let feedback = normalRange.contains(result) ? Constants.positiveFeedback : Constants.negativeFeedback

					completion(HKStatisticsProvider.StatsIndicatorModel(name: Constants.name,
					                                                    description: Constants.description,
					                                                    value: result,
					                                                    valueNormInterval: normalRange,
					                                                    unit: Constants.unit,
					                                                    feedback: feedback))
				} else {
					completion(nil)
				}
			}
		}
	}

	/// The root mean square of successive differences between normal heartbeats (RMSSD) is obtained by first calculating each successive time difference between heartbeats in ms.
	/// Then, each of the values is squared and the result is averaged before the square root of the total is obtained
	public func calculateRMSSD(completion: @escaping (HKStatisticsProvider.StatsIndicatorModel?) -> Void) {
		enum Constants {
			static let name = "RMSSD"
			static let unit = "ms"
			static let description = "The RMSSD reflects the beat-to-beat variance in HR and is the primary time-domain measure used to estimate the vagally mediated changes reflected in HRV."
			// normal values by distribution of 10 years https://www.sciencedirect.com/science/article/pii/S0735109797005548
			static let normalValuesBy10YearsAge: [ClosedRange<Double>] = [
				30.0 ... 120.0,
				25.0 ... 103.0,
				21.0 ... 87.0,
				18.0 ... 74.0,
				15.0 ... 63.0,
				13.0 ... 53.0,
				11.0 ... 45.0,
				9.0 ... 38.0,
				8.0 ... 32.0,
				7.0 ... 28.0,
			]
			static let positiveFeedback = "Your body is recovering and coping with pressure fine"
			static let negativeFeedback = "Your body is not recovering and coping with pressure as much as needed"
		}

		HKService.requestPermissions { [weak self] _, error in
			guard let birthday = HKService.readBirthday()?.date,
			      birthday.years(from: Date()) <= 90 else { return }
			let currentAge = birthday.years(from: Date())

			self?.healthService.readData(type: .heart,
			                             interval: .init(start: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!, end: Date())) { _, samples, error in
				guard error == nil, let samples = samples as? [HKQuantitySample], samples.count >= 12 else {
					completion(nil)
					return
				}

				var differences: [Double] = []

				for index in 1 ..< samples.count {
					let first = 60000 / samples[index].quantity.doubleValue(for: HKUnit(from: "count/min"))
					let second = 60000 / samples[index - 1].quantity.doubleValue(for: HKUnit(from: "count/min"))
					let result = abs(first - second)
					differences.append(result * result)
				}

				let sum = differences.reduce(0, +)
				if sum > 0 {
					let result = sqrt(differences.reduce(0, +) / Double(differences.count))
					let normalRange = Constants.normalValuesBy10YearsAge[currentAge / 10]
					let feedback = normalRange.contains(result) ? Constants.positiveFeedback : Constants.negativeFeedback

					completion(HKStatisticsProvider.StatsIndicatorModel(name: Constants.name,
					                                                    description: Constants.description,
					                                                    value: result,
					                                                    valueNormInterval: normalRange,
					                                                    unit: Constants.unit,
					                                                    feedback: feedback))
				} else {
					completion(nil)
				}
			}
		}
	}
}

// Copyright (c) 2021 Sleepy.

import Foundation
import HKStatistics
import SettingsKit
import SwiftUI
import UIComponents

enum SummaryViewCardType: String {
	case heart
	case general
	case phases
	case breath
}

extension SummaryViewCardType: Identifiable {
	var id: Self { self }
}

class CardService: ObservableObject {
	// MARK: Properties

	@Published var bankOfSleepViewModel: BankOfSleepDataViewModel?
	@Published var phasesViewModel: SummaryPhasesDataViewModel?
	@Published var generalViewModel: SummaryGeneralDataViewModel?
	@Published var heartViewModel: SummaryHeartDataViewModel?
	@Published var respiratoryViewModel: SummaryRespiratoryDataViewModel?

	var statisticsProvider: HKStatisticsProvider

	private let mainCard: SummaryViewCardType = .general
	private let phasesCard: SummaryViewCardType = .phases
	private let heartCard: SummaryViewCardType = .heart

	// MARK: Initialization

	init(statisticsProvider: HKStatisticsProvider) {
		self.statisticsProvider = statisticsProvider
		self.getBankOfSleepInfo()
		self.getSleepData()
		self.getPhasesData()
		self.getHeartData()
		self.getRespiratoryData()
	}

	// MARK: Internal methods

	func fetchCard(id _: String, _ completion: @escaping (SummaryViewCardType?) -> Void) {
		self.fetchCards { cards in
			completion(cards.first)
		}
	}

	func fetchCards(_ completion: @escaping ([SummaryViewCardType]) -> Void) {
		completion(
			Mirror(reflecting: self)
				.children
				.compactMap { $0.value as? SummaryViewCardType }
		)
	}

	// MARK: Private methods

	private func getSleepGoal() -> Int {
		return UserDefaults.standard.integer(forKey: SleepySettingsKeys.sleepGoal.rawValue)
	}

	// MARK: Bank of sleep

	private func getBankOfSleepInfo() {
		self.getbankOfSleepData { data in
			let sleepGoal = self.getSleepGoal()
			let filteredData = data.filter { $0 != 0 }
			guard !filteredData.isEmpty else { return }

			let bankOfSleepData = data.map { $0 / Double(sleepGoal) }

			let backlogValue = Int(filteredData.reduce(0.0) { $1 < Double(sleepGoal) ? $0 + (Double(sleepGoal) - $1) : $0 + 0 })
			let backlogString = Date.minutesToClearString(minutes: backlogValue)

			let timeToCloseDebtValue = (backlogValue / filteredData.count) + sleepGoal
			let timeToCloseDebtString = Date.minutesToClearString(minutes: timeToCloseDebtValue)

			self.bankOfSleepViewModel = BankOfSleepDataViewModel(bankOfSleepData: bankOfSleepData,
			                                                     backlog: backlogString,
			                                                     timeToCloseDebt: timeToCloseDebtString)
		}
	}

	private func getbankOfSleepData(completion: @escaping ([Double]) -> Void) {
		var resultData: [Double] = Array(repeating: 0, count: 14)
		var samplesLeft = 14
		let queue = DispatchQueue(label: "bankOfSleepQueue", qos: .userInitiated)
		for dateIndex in 0 ..< 14 {
			guard
				let date = Calendar.current.date(byAdding: .day, value: -dateIndex, to: Date()) else
			{
				return
			}

			self.statisticsProvider.getData(healthType: .asleep,
			                                indicator: .sum, interval: DateInterval(start: date.startOfDay, end: date.endOfDay)) { data in
				let isComplete = queue.sync { () -> Bool in
					resultData[dateIndex] = data ?? 0
					samplesLeft -= 1
					return samplesLeft == 0
				}
				if isComplete {
					print(resultData)
					completion(resultData.reversed())
				}
			}
		}
	}

	// MARK: Sleep data

	private func getSleepData() {
		guard
			let sleepInterval = statisticsProvider.getTodaySleepInterval(intervalType: .asleep),
			let inBedInterval = statisticsProvider.getTodaySleepInterval(intervalType: .inbed) else
		{
			return
		}

		self.generalViewModel = SummaryGeneralDataViewModel(sleepInterval: sleepInterval,
		                                                    inbedInterval: inBedInterval,
		                                                    sleepGoal: UserDefaults.standard.integer(forKey: SleepySettingsKeys.sleepGoal.rawValue))
	}

	// MARK: Phases data

	private func getPhasesData() {
		guard
			let deepSleepMinutes = statisticsProvider.getData(dataType: .deepPhaseDuration) as? Int,
			let lightSleepMinutes = statisticsProvider.getData(dataType: .lightPhaseDuration) as? Int,
			let phasesData = statisticsProvider.getData(dataType: .chart) as? [Double] else
		{
			return
		}

		if !phasesData.isEmpty {
			self.phasesViewModel = SummaryPhasesDataViewModel(phasesData: phasesData,
			                                                  timeInLightPhase: "\(lightSleepMinutes / 60)h \(lightSleepMinutes - (lightSleepMinutes / 60) * 60)min",
			                                                  timeInDeepPhase: "\(deepSleepMinutes / 60)h \(deepSleepMinutes - (deepSleepMinutes / 60) * 60)min",
			                                                  mostIntervalInLightPhase: "-",
			                                                  mostIntervalInDeepPhase: "-")
		}
	}

	// MARK: Heart data

	private func getHeartData() {
		var minHeartRate = "-", maxHeartRate = "-", averageHeartRate = "-"
		let heartRateData = self.getShortHeartRateData(heartRateData: self.statisticsProvider.getTodaySleepData(healthtype: .heart))

		if !heartRateData.isEmpty,
		   let maxHR = statisticsProvider.getData(dataType: .heart, indicator: .max),
		   let minHR = statisticsProvider.getData(dataType: .heart, indicator: .min),
		   let averageHR = statisticsProvider.getData(dataType: .heart, indicator: .mean)
		{
			maxHeartRate = String(format: "%u bpm", Int(maxHR))
			minHeartRate = String(format: "%u bpm", Int(minHR))
			averageHeartRate = String(format: "%u bpm", Int(averageHR))

			self.statisticsProvider.getData(dataType: .rmssd) { [weak self] rmssd in
				self?.statisticsProvider.getData(dataType: .ssdn) { ssdn in
					var indicators: [HKStatisticsProvider.StatsIndicatorModel] = []

					[ssdn, rmssd].forEach {
						if let value = $0 {
							indicators.append(value)
						}
					}

					DispatchQueue.main.async {
						self?.heartViewModel = SummaryHeartDataViewModel(heartRateData: heartRateData,
						                                                 maxHeartRate: maxHeartRate,
						                                                 minHeartRate: minHeartRate,
						                                                 averageHeartRate: averageHeartRate,
						                                                 indicators: indicators)
					}
				}
			}
		}
	}

	private func getShortHeartRateData(heartRateData: [Double]) -> [Double] {
		guard
			heartRateData.count > 25 else
		{
			return heartRateData
		}

		let stackCapacity = heartRateData.count / 25
		var shortData: [Double] = []

		for index in stride(from: 0, to: heartRateData.count, by: stackCapacity) {
			var mean: Double = 0.0
			for stackIndex in index ..< index + stackCapacity {
				guard stackIndex < heartRateData.count else { return shortData }
				mean += heartRateData[stackIndex]
			}
			shortData.append(mean / Double(stackCapacity))
		}

		return shortData
	}

	// MARK: Breath

	private func getRespiratoryData() {
		var minRespiratoryRate = "-", maxRespiratoryRate = "-", averageRespiratoryRate = "-"
		let breathRateData = self.statisticsProvider.getTodaySleepData(healthtype: .respiratory)

		if !breathRateData.isEmpty,
		   let maxRespiratory = statisticsProvider.getData(dataType: .respiratory, indicator: .max),
		   let minRespiratory = statisticsProvider.getData(dataType: .respiratory, indicator: .min),
		   let averageRespiratory = statisticsProvider.getData(dataType: .respiratory, indicator: .mean)
		{
			maxRespiratoryRate = String(format: "%u count/min", Int(maxRespiratory))
			minRespiratoryRate = String(format: "%u count/min", Int(minRespiratory))
			averageRespiratoryRate = String(format: "%u count/min", Int(averageRespiratory))
			self.respiratoryViewModel = SummaryRespiratoryDataViewModel(respiratoryRateData: breathRateData,
			                                                            maxRespiratoryRate: maxRespiratoryRate,
			                                                            minRespiratoryRate: minRespiratoryRate,
			                                                            averageRespiratoryRate: averageRespiratoryRate)
		}
	}
}

// Copyright (c) 2021 Sleepy.

import FirebaseAnalytics
import Foundation
import HKCoreSleep
import HKStatistics
import UIComponents
import XUI

class HistoryCoordinator: ObservableObject, ViewModel {
	@Published var openedURL: URL?
	@Published var calendarType: HealthData

	@Published var asleepHistoryStatsViewModel: SleepHistoryStatsViewModel?
	@Published var inbedHistoryStatsViewModel: SleepHistoryStatsViewModel?
	@Published var heartHistoryStatsViewModel: HeartHistoryStatsViewModel?
	@Published var energyHistoryStatsViewModel: EnergyHistoryStatsViewModel?
	@Published var respiratoryHistoryStatsViewModel: RespiratoryHistoryStatsViewModel?

	// велечина, являющаяся маркером текущего месяца для календаря (изменяется когда свайпаем месяц)
	@Published var monthDate = Date()

	private unowned let parent: RootCoordinator
	let colorSchemeProvider: ColorSchemeProvider
	let statisticsProvider: HKStatisticsProvider

	private let monthBeforeDateInterval = DateInterval(start: Calendar.current.date(byAdding: .day, value: -30, to: Date().endOfDay)!.startOfDay, end: Date().endOfDay)

	init(colorSchemeProvider: ColorSchemeProvider,
	     statisticsProvider: HKStatisticsProvider,
	     parent: RootCoordinator)
	{
		self.parent = parent

		self.colorSchemeProvider = colorSchemeProvider
		self.statisticsProvider = statisticsProvider
		self.calendarType = .asleep
	}

	func open(_ url: URL) {
		self.openedURL = url
	}
}

extension HistoryCoordinator {
	/// Вызывается для подгрузки всей статистики выбранной вкладки календаря
	func extractContextStatistics() {
		FirebaseAnalytics.Analytics.logEvent("History_model_load", parameters: ["type": self.calendarType.rawValue])

		switch self.calendarType {
		case .heart:
			self.extractBasicNumericDataIfNeeded(type: .heart)
		case .energy:
			self.extractBasicNumericDataIfNeeded(type: .energy)
		case .respiratory:
			self.extractBasicNumericDataIfNeeded(type: .respiratory)
		case .asleep:
			self.extractSleepDataIfNeeded(type: .asleep)
		case .inbed:
			self.extractSleepDataIfNeeded(type: .inbed)
		}
	}

	/// Получение более сложной статистики вкладок alseep/inbed календаря (для графиков разных типов)
	func extractSleepDataIfNeeded(type: HKService.HealthType) {
		if type != .asleep, type != .inbed { fatalError("Not category type being used") }
		if type == .inbed, self.inbedHistoryStatsViewModel != nil { return }
		if type == .asleep, self.asleepHistoryStatsViewModel != nil { return }

		var last30daysCellData: [StatisticsCellData] = []

		let currDate = Date().endOfDay
		let currDate2weeksbefore = Calendar.current.date(byAdding: .day, value: -13, to: currDate)!.startOfDay

		let twoweeksbeforeDate = Calendar.current.date(byAdding: .day, value: -1, to: currDate2weeksbefore)!
		let monthbeforedate = Calendar.current.date(byAdding: .day, value: -13, to: twoweeksbeforeDate)!.startOfDay
		var meanCurrent2WeeksDuration: Double?
		var meanLast2WeeksDuration: Double?
		var monthSleepPoints: [Double]?

		let current2weeksInterval = DateInterval(start: currDate2weeksbefore, end: currDate)
		let last2weeksInterval = DateInterval(start: monthbeforedate, end: twoweeksbeforeDate)

		let group = DispatchGroup()

		group.enter()
		DispatchQueue.global(qos: .userInitiated).async { [weak self] in
			guard let self = self else { return }
			self.statisticsProvider.getData(healthType: type,
			                                indicator: .mean,
			                                interval: current2weeksInterval,
			                                bundlePrefixes: ["com.sinapsis", "com.benmustafa"]) { result in
				meanCurrent2WeeksDuration = result
				group.leave()
			}
		}

		group.enter()
		DispatchQueue.global(qos: .userInitiated).async { [weak self] in
			guard let self = self else { return }
			self.statisticsProvider.getData(healthType: type,
			                                indicator: .mean,
			                                interval: last2weeksInterval,
			                                bundlePrefixes: ["com.sinapsis", "com.benmustafa"]) { result in
				meanLast2WeeksDuration = result
				group.leave()
			}
		}

		let indicators: [Indicator] = [.min, .max, .mean]
		indicators.forEach { indicator in
			group.enter()
			DispatchQueue.global(qos: .userInitiated).async { [weak self] in
				guard let self = self else { return }
				self.statisticsProvider.getData(healthType: type,
				                                indicator: indicator,
				                                interval: self.monthBeforeDateInterval,
				                                bundlePrefixes: ["com.sinapsis", "com.benmustafa"]) { result in
					if let result = result {
						last30daysCellData.append(
							StatisticsCellData(title: self.getStatisticsCellDataLabel(for: type, indicator: indicator),
							                   value: Date.minutesToDateDescription(minutes: Int(result))))
					}
					group.leave()
				}
			}
		}

		if type == .asleep {
			group.enter()
			DispatchQueue.global(qos: .userInitiated).async { [weak self] in
				guard let self = self else { return }
				// TODO: сюда может вернуться сразу несколько снов за сутки, тогда нарушится логика вывода в график (где каждый столбик = день). FIX IT
				self.statisticsProvider.getData(healthType: type,
				                                interval: self.monthBeforeDateInterval,
				                                bundlePrefixes: ["com.sinapsis", "com.benmustafa"]) { result in
					monthSleepPoints = result
					group.leave()
				}
			}
		}

		group.notify(queue: .global(qos: .default)) { [weak self] in
			guard let self = self else { return }
			if let mean1 = meanCurrent2WeeksDuration, let mean2 = meanLast2WeeksDuration {
				DispatchQueue.main.async {
					let tmp = SleepHistoryStatsViewModel(cellData: last30daysCellData,
					                                     monthSleepPoints: monthSleepPoints,
					                                     monthBeforeDateInterval: self.monthBeforeDateInterval,
					                                     currentWeeksProgress: ProgressItem(title: String(format: "Mean duration:", Date.minutesToDateDescription(minutes: Int(mean1))),
					                                                                        text: current2weeksInterval.stringFromDateInterval(type: .days),
					                                                                        value: Int(mean1)),
					                                     beforeWeeksProgress: ProgressItem(title: String(format: "Mean duration:", Date.minutesToDateDescription(minutes: Int(mean2))),
					                                                                       text: last2weeksInterval.stringFromDateInterval(type: .days),
					                                                                       value: Int(mean2)),
					                                     analysisString: Int(mean1) == Int(mean2)
					                                     	? String(format: "Your %@ time is equal compared to 2 weeks before", type == .inbed ? "in bed" : "asleep")
					                                     	: String(format: "Compared to 2 weeks before, you %@ %@ by %@ in time", type == .inbed ? "were in bed" : "slept", mean1 > mean2 ? "more" : "less", Date.minutesToDateDescription(minutes: abs(Int(mean1) - Int(mean2)))))

					if type == .inbed {
						self.inbedHistoryStatsViewModel = tmp
					} else {
						self.asleepHistoryStatsViewModel = tmp
					}
				}
			}
		}
	}

	/// Получение массива из статистик для ячеек под графиком (простая статистика мин-макс-средняя величина)
	func extractBasicNumericDataIfNeeded(type: HKService.HealthType) {
		if type == .asleep || type == .inbed { fatalError("Not numeric type being used") }
		if type == .heart, self.heartHistoryStatsViewModel != nil { return }
		if type == .energy, self.energyHistoryStatsViewModel != nil { return }
		if type == .respiratory, self.respiratoryHistoryStatsViewModel != nil { return }

		var last30daysCellData: [StatisticsCellData] = []
		let indicators: [Indicator] = [.min, .max, .mean]

		let group = DispatchGroup()
		indicators.forEach { indicator in
			group.enter()
			DispatchQueue.global(qos: .userInitiated).async { [weak self] in
				guard let self = self else { return }
				self.statisticsProvider.getData(healthType: type,
				                                indicator: indicator,
				                                interval: self.monthBeforeDateInterval) { result in
					if let result = result {
						last30daysCellData.append(StatisticsCellData(title: self.getStatisticsCellDataLabel(for: type, indicator: indicator), value: "\(Double(result))"))
					}
					group.leave()
				}
			}
		}

		group.notify(queue: .global(qos: .default)) { [weak self] in
			guard let self = self else { return }
			if !last30daysCellData.isEmpty {
				DispatchQueue.main.async {
					switch type {
					case .energy:
						self.energyHistoryStatsViewModel = EnergyHistoryStatsViewModel(cellData: last30daysCellData)
					case .heart:
						self.heartHistoryStatsViewModel = HeartHistoryStatsViewModel(cellData: last30daysCellData)
					case .respiratory:
						self.respiratoryHistoryStatsViewModel = RespiratoryHistoryStatsViewModel(cellData: last30daysCellData)
					case .asleep, .inbed:
						return
					}
				}
			}
		}
	}

	/// Получение строки-индикатора для ячейки базовой статистики под календарем
	func getStatisticsCellDataLabel(for type: HKService.HealthType, indicator: Indicator) -> String {
		switch type {
		case .energy:
			return "\(indicator) Kcal"
		case .heart:
			return "\(indicator) BPM"
		case .respiratory:
			return "\(indicator) BrPM"
		case .asleep, .inbed:
			return "\(indicator) duration"
		}
	}
}

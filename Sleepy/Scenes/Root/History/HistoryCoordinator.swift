// Copyright (c) 2021 Sleepy.

import FirebaseAnalytics
import Foundation
import HKCoreSleep
import HKStatistics
import UIComponents
import XUI

class HistoryCoordinator: ObservableObject, ViewModel {
	@Published var openedURL: URL?
	@Published var calendarType: HealthType

	@Published var asleepHistoryStatsViewModel: SleepHistoryStatsViewModel?
	@Published var inbedHistoryStatsViewModel: SleepHistoryStatsViewModel?
	@Published var heartHistoryStatisticsViewModel: HeartHistoryStatisticsViewModel?
	@Published var energyHistoryStatsViewModel: EnergyHistoryStatsViewModel?
	@Published var respiratoryHistoryStatsViewModel: RespiratoryHistoryStatsViewModel?

	// велечина, являющаяся маркером текущего месяца для календаря (изменяется когда свайпаем месяц)
	@Published var monthDate = Date()

	private unowned let parent: RootCoordinator
	let statisticsProvider: HKStatisticsProvider

	private let monthBeforeDateInterval = DateInterval(start: Calendar.current.date(byAdding: .day, value: -30, to: Date().endOfDay)!.startOfDay, end: Date().endOfDay)

	init(statisticsProvider: HKStatisticsProvider,
	     parent: RootCoordinator)
	{
		self.parent = parent

		self.statisticsProvider = statisticsProvider
		self.calendarType = .asleep
	}

	func open(_ url: URL) {
		self.openedURL = url
	}
}

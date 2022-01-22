// Copyright (c) 2021 Sleepy.

import FirebaseAnalytics
import Foundation
import HKCoreSleep
import HKStatistics
import UIComponents
import XUI
import SettingsKit

class HistoryCoordinator: ObservableObject, ViewModel {
    private unowned let parent: RootCoordinator
    
	@Published var openedURL: URL?

    @Published var calendarType: HKService.HealthType
    @Published var calendarData: [CalendarDayView.DisplayItem]
    @Published var monthDate: Date // маркер текущего месяца для календаря (изменяется когда свайпаем месяц)

    @Published var sleepGoal = UserDefaults.standard.integer(forKey: SleepySettingsKeys.sleepGoal.rawValue)

	@Published var asleepHistoryStatsViewModel: SleepHistoryStatsViewModel?
	@Published var inbedHistoryStatsViewModel: SleepHistoryStatsViewModel?
	@Published var heartHistoryStatisticsViewModel: StatisticsCellCollectionViewModel?
	@Published var energyHistoryStatsViewModel: StatisticsCellCollectionViewModel?
	@Published var respiratoryHistoryStatsViewModel: StatisticsCellCollectionViewModel?

	let statisticsProvider: HKStatisticsProvider

    let monthBeforeDateInterval = DateInterval(start: Calendar.current.date(byAdding: .day, value: -30, to: Date().endOfDay)!.startOfDay, end: Date().endOfDay)

	init(statisticsProvider: HKStatisticsProvider,
	     parent: RootCoordinator)
	{
		self.parent = parent

		self.statisticsProvider = statisticsProvider
		self.calendarType = .asleep

        let monthDate = Date().startOfMonth
        self.monthDate = monthDate
        self.calendarData = [CalendarDayView.DisplayItem](repeating: .init(value: nil, description: "-", color: ColorsRepository.Calendar.emptyDay, isToday: false),
                                                          count: monthDate.endOfMonth.getDayInt())
	}

	func open(_ url: URL) {
		self.openedURL = url
	}
}

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
	@Published var heartHistoryStatisticsViewModel: HeartHistoryStatsViewModel?
	@Published var energyHistoryStatsViewModel: StatisticsCellCollectionViewModel?
	@Published var respiratoryHistoryStatsViewModel: StatisticsCellCollectionViewModel?

    let factory: HistoryFactory = HistoryFactory()
    let ssdnCardTitleViewModel: CardTitleViewModel

	let statisticsProvider: HKStatisticsProvider

    let monthBeforeDateInterval = DateInterval(start: Date().monthBefore.startOfDay, end: Date().endOfDay)

	init(statisticsProvider: HKStatisticsProvider,
	     parent: RootCoordinator)
	{
		self.parent = parent

        self.ssdnCardTitleViewModel = factory.makeSsdnCardTitleViewModel()

		self.statisticsProvider = statisticsProvider
		self.calendarType = .asleep

        let monthDate = Date().startOfMonth
        self.monthDate = monthDate

        var array: [CalendarDayView.DisplayItem] = []
        for i in 0 ..< monthDate.endOfMonth.getDayInt() {
            array.append(.init(dayNumber: i + 1, value: nil, description: "-", color: ColorsRepository.Calendar.emptyDay, isToday: false))
        }
        self.calendarData = array
	}

	func open(_ url: URL) {
		self.openedURL = url
	}
}

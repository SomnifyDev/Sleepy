// Copyright (c) 2022 Sleepy.

import FirebaseAnalytics
import Foundation
import HKCoreSleep
import HKStatistics
import SettingsKit
import UIComponents
import XUI

class HistoryCoordinator: ObservableObject, ViewModel {
    private unowned let parent: RootCoordinator

    @Published var openedURL: URL?

    @Published var calendarType: HKService.HealthType
    @Published var calendarData: [CalendarDayView.DisplayItem]
    @Published var monthDate: Date // маркер текущего месяца для календаря (изменяется когда свайпаем месяц)

    @Published var sleepGoal = UserDefaults.standard.integer(forKey: SleepySettingsKeys.sleepGoal.rawValue)

    @Published var asleepHistoryStatsDisplayItem: SleepHistoryStatsDisplayItem?
    @Published var inbedHistoryStatsDisplayItem: SleepHistoryStatsDisplayItem?
    @Published var heartHistoryStatisticsDisplayItem: HeartHistoryStatsDisplayItem?
    @Published var energyHistoryStatsDisplayItem: StatisticsCellCollectionViewModel?
    @Published var respiratoryHistoryStatsDisplayItem: StatisticsCellCollectionViewModel?

    let factory = HistoryFactory()
    let ssdnCardTitleViewModel: CardTitleViewModel

    let statisticsProvider: HKStatisticsProvider

    let monthBeforeDateInterval = DateInterval(start: Date().monthBefore.startOfDay, end: Date().endOfDay)

    init(
        statisticsProvider: HKStatisticsProvider,
        parent: RootCoordinator
    ) {
        self.parent = parent

        self.ssdnCardTitleViewModel = self.factory.makeSsdnCardTitleViewModel()

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

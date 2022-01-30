//
//  HistoryInteractor.swift
//  Sleepy
//
//  Created by Никита Казанцев on 26.12.2021.
//

import FirebaseAnalytics
import Foundation
import HKCoreSleep
import HKStatistics
import UIComponents
import XUI

class HistoryInteractor {
    @Store var viewModel: HistoryCoordinator

    init(viewModel: Store<HistoryCoordinator>) {
        _viewModel = viewModel
    }

    /// Вызывается для подгрузки кругов месяца самого календаря
    func extractCalendarData() {
        // обнуляем кружки календаря до незаполненных пока идет загрузка данных
        var array: [CalendarDayView.DisplayItem] = []
        for i in 0 ..< self.viewModel.monthDate.endOfMonth.getDayInt() {
            array.append(.init(dayNumber: i + 1, value: nil, description: "-", color: ColorsRepository.Calendar.emptyDay, isToday: false))
        }
        self.viewModel.calendarData = array

        self.viewModel.statisticsProvider.getIntervalDataByDays(healthType: self.viewModel.calendarType,
                                                                indicator: .sum,
                                                                interval: .init(start: self.viewModel.monthDate.startOfMonth,
                                                                                end: self.viewModel.monthDate.endOfMonth), bundlePrefixes: ["com.sinapsis", "com.benmustafa"]) { result in
            var displayItems: [CalendarDayView.DisplayItem] = []

            for index in 0 ..< result.count {
                if let dayDate = Calendar.current.date(byAdding: .day, value: index, to: self.viewModel.monthDate.startOfMonth) {
                    displayItems.append(self.getDaySleepData(value: result[index], date: dayDate))
                }
            }

            DispatchQueue.main.async {
                self.viewModel.calendarData = displayItems
            }
        }
    }

    /// Вызывается для подгрузки всей нижней статистики выбранной под календарем
    func extractContextStatistics() {
        FirebaseAnalytics.Analytics.logEvent("History_model_load", parameters: ["type": self.viewModel.calendarType.rawValue])

        switch self.viewModel.calendarType {
        case .heart, .energy, .respiratory:
            self.extractBasicNumericDataIfNeeded(type: self.viewModel.calendarType)
        case .asleep, .inbed:
            self.extractBasicCategoryDataIfNeeded(type: self.viewModel.calendarType)
        }
    }

    /// Получение более сложной статистики вкладок alseep/inbed календаря (для графиков разных типов под календарем)
    private func extractBasicCategoryDataIfNeeded(type: HKService.HealthType) {
        if type != .asleep, type != .inbed { fatalError("Not category type being used") }
        if type == .inbed, self.viewModel.inbedHistoryStatsViewModel != nil { return }
        if type == .asleep, self.viewModel.asleepHistoryStatsViewModel != nil { return }

        var last30daysCellData: [StatisticsCellViewModel] = []
        var meanCurrent2WeeksDuration: Double?
        var meanLast2WeeksDuration: Double?
        var monthSleepPoints: [Double]?

        let current2weeksInterval = DateInterval(start: Date().startOfDay.twoWeeksBefore, end: Date().endOfDay)
        let last2weeksInterval = DateInterval(start: Date().startOfDay.monthBefore, end: Date().startOfDay.twoWeeksBefore)

        self.getSleepDurationData(type: type) { durations in
            if durations.count >= 14 {
                monthSleepPoints = durations

                let suffixValues = durations.suffix(durations.count / 2)
                meanCurrent2WeeksDuration = suffixValues.reduce(0, +) / Double(suffixValues.count)

                let preffixValues = durations.prefix(durations.count / 2)
                meanLast2WeeksDuration = preffixValues.reduce(0, +) / Double(preffixValues.count)

                let indicators: [Indicator] = [.min, .max, .mean]

                indicators.forEach { indicator in
                    switch indicator {
                    case .min:
                        guard let min = durations.min() else { return }
                        last30daysCellData.append(.init(title: self.getStatCellTitle(for: type, indicator: indicator),
                                                        value: self.getStatCellDescription(for: type, value: Date.minutesToDateDescription(minutes: Int(min)))))
                    case .max:
                        guard let max = durations.max() else { return }
                        last30daysCellData.append(.init(title: self.getStatCellTitle(for: type, indicator: indicator),
                                                        value: self.getStatCellDescription(for: type, value: Date.minutesToDateDescription(minutes: Int(max)))))
                    case .mean:
                        guard let meanCurrent2WeeksDuration = meanCurrent2WeeksDuration,
                              let meanLast2WeeksDuration = meanLast2WeeksDuration else { return }
                        let mean = Int(meanCurrent2WeeksDuration + meanLast2WeeksDuration) / 2
                        last30daysCellData.append(.init(title: self.getStatCellTitle(for: type, indicator: indicator),
                                                        value: self.getStatCellDescription(for: type, value: Date.minutesToDateDescription(minutes: Int(mean)))))
                    case .sum:
                        break
                    }
                }
            }

            if monthSleepPoints != nil,
               let mean1 = meanCurrent2WeeksDuration, let mean2 = meanLast2WeeksDuration {
                DispatchQueue.main.async {
                    let tmp = SleepHistoryStatsViewModel(cellData: .init(with: last30daysCellData),
                                                         monthSleepPoints: monthSleepPoints,
                                                         monthBeforeDateInterval: self.viewModel.monthBeforeDateInterval,
                                                         currentWeeksProgress:
                                                            ProgressElementViewModel(title: "Current mean duration: " + String( Date.minutesToDateDescription(minutes: Int(mean1))),
                                                                                     payloadText: current2weeksInterval.stringFromDateInterval(type: .days),
                                                                                     value: Int(mean1)),
                                                         beforeWeeksProgress:
                                                            ProgressElementViewModel(title: "2 weeks before mean duration: " + String( Date.minutesToDateDescription(minutes: Int(mean2))),
                                                                                     payloadText: last2weeksInterval.stringFromDateInterval(type: .days),
                                                                                     value: Int(mean2)),
                                                         analysisString: Int(mean1) == Int(mean2)
                                                         ? String(format: "Your %@ time is equal compared to 2 weeks before", type == .inbed ? "in bed" : "asleep")
                                                         : String(format: "Compared to 2 weeks before, you %@ %@ by %@ in time", type == .inbed ? "were in bed" : "slept", mean1 > mean2 ? "more" : "less", Date.minutesToDateDescription(minutes: abs(Int(mean1) - Int(mean2)))))

                    if type == .inbed {
                        self.viewModel.inbedHistoryStatsViewModel = tmp
                    } else {
                        self.viewModel.asleepHistoryStatsViewModel = tmp
                    }
                }
            }
        }
    }

    /// Получение массива из статистик для ячеек под графиком (простая статистика мин-макс-средняя величина)
    private func extractBasicNumericDataIfNeeded(type: HKService.HealthType) {
        if type == .asleep || type == .inbed { fatalError("Not numeric type being used") }
        if type == .heart, self.viewModel.heartHistoryStatisticsViewModel != nil { return }
        if type == .energy, self.viewModel.energyHistoryStatsViewModel != nil { return }
        if type == .respiratory, self.viewModel.respiratoryHistoryStatsViewModel != nil { return }

        var last30daysCellData: [StatisticsCellViewModel] = []
        let indicators: [Indicator] = [.min, .max, .mean]

        let group = DispatchGroup()
        indicators.forEach { indicator in
            group.enter()
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                self.viewModel.statisticsProvider.getData(healthType: type,
                                                          indicator: indicator,
                                                          interval: self.viewModel.monthBeforeDateInterval) { result in
                    if let result = result {
                        last30daysCellData.append(StatisticsCellViewModel(title: self.getStatCellTitle(for: type, indicator: indicator),
                                                                          value: self.getStatCellDescription(for: type, value: String(format: self.getStatCellValueFormat(for: type), Double(result)))))
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
                        self.viewModel.energyHistoryStatsViewModel = StatisticsCellCollectionViewModel(with: last30daysCellData)
                    case .heart:
                        self.viewModel.heartHistoryStatisticsViewModel = StatisticsCellCollectionViewModel(with: last30daysCellData)
                    case .respiratory:
                        self.viewModel.respiratoryHistoryStatsViewModel = StatisticsCellCollectionViewModel(with: last30daysCellData)
                    case .asleep, .inbed:
                        return
                    }
                }
            }
        }
    }
}

extension HistoryInteractor {
    private func getSleepDurationData(type: HKService.HealthType,
                                      completion: @escaping ([Double]) -> Void) {
        let datesToFetch = Date().endOfMonth.getDayInt()
        var resultData: [Double] = Array(repeating: 0, count: datesToFetch)

        var samplesLeft = datesToFetch
        let queue = DispatchQueue(label: "sleepDurationQueue", qos: .userInitiated)
        for dateIndex in 0 ..< datesToFetch {
            guard
                let date = Calendar.current.date(byAdding: .day, value: -dateIndex, to: Date()) else {
                    return
                }

            self.viewModel.statisticsProvider.getData(healthType: type,
                                                      indicator: .sum,
                                                      interval: DateInterval(start: date.startOfDay, end: date.endOfDay),
                                                      bundlePrefixes: ["com.sinapsis", "com.benmustafa"]) { data in
                let isComplete = queue.sync { () -> Bool in
                    guard let data = data, data > 0 else { return false }
                    resultData[datesToFetch - samplesLeft] = data
                    samplesLeft -= 1
                    return samplesLeft == 0
                }
                if isComplete || dateIndex == datesToFetch - 1 {
                    completion(resultData.prefix(while: { item in item > 0 }).reversed())
                    return
                }
            }
        }
    }

    /// Получение строки-индикатора для ячейки базовой статистики под календарем
    private func getStatCellTitle(for type: HKService.HealthType, indicator: Indicator) -> String {
        switch type {
        case .energy:
            return "\(indicator.rawValue) consumption".capitalized
        case .heart:
            return "\(indicator.rawValue) pulse".capitalized
        case .respiratory:
            return "\(indicator.rawValue) breath rate".capitalized
        case .asleep, .inbed:
            return "\(indicator.rawValue) duration".capitalized
        }
    }

    /// Получение строки-индикатора для ячейки базовой статистики под календарем
    private func getStatCellDescription(for type: HKService.HealthType, value: String) -> String {
        switch type {
        case .energy:
            return "\(value) kcal"
        case .heart:
            return "\(value) bpm"
        case .respiratory:
            return "\(value) brpm"
        case .asleep, .inbed:
            return "\(value)"
        }
    }

    /// Получение форматирования значения по типу здоровья для ячейки статистики
    private func getStatCellValueFormat(for type: HKService.HealthType) -> String {
        switch type {
        case .respiratory, .heart:
            return "%.0f"
        default:
            return "%.3f"
        }
    }
}

extension HistoryInteractor {
    /// Получение модели для дня месяца для вью календаря
    /// - Parameters:
    ///   - date: Дата для которой нужно получить значения
    ///   - calendarType: тип здоровья, по которому  в данный момент отображает статистику календарь
    ///   - completion: -
    private func getDaySleepData(value: Double?, date: Date) -> CalendarDayView.DisplayItem {
        var description = "-"
        var color = self.getCircleColor(value: value)
        let value = value

        switch self.viewModel.calendarType {
        case .heart, .respiratory, .energy:


            if let value = value, value > 0 {
                description = !value.isNaN
                ? self.viewModel.calendarType == .energy
                ? String(format: "%.2f", value)
                : String(Int(value))
                : "-"
            } else {
                description = "-"
            }

            return (.init(dayNumber: date.getDayInt(), value: value, description: description, color: color, isToday: date.isToday()))

        case .asleep, .inbed:
            if let value = value, value > 0 {
                description = !value.isNaN ? Date.minutesToDateDescription(minutes: Int(value)) : "-"
            } else {
                description = "-"
            }

            return (.init(dayNumber: date.getDayInt(), value: value, description: description, color: color, isToday: date.isToday()))
        }
    }

    /// получение цвета, характеризующего негативизм значения статистики в календаре если такая оценка возможна
    /// - Parameter value: значение
    /// - Returns: цвет
    private func getCircleColor(value: Double?) -> Color {
        if let value = value, !value.isNaN, value > 0 {
            switch self.viewModel.calendarType {
            case .heart:
                return ColorsRepository.Heart.heart

            case .asleep, .inbed:
                return Int(value) > viewModel.sleepGoal
                ? ColorsRepository.Calendar.positiveDay
                : (value > Double(viewModel.sleepGoal) * 0.9
                   ? ColorsRepository.Calendar.neutralDay
                   : ColorsRepository.Calendar.negativeDay)

            case .energy:
                return ColorsRepository.Energy.energy

            case .respiratory:
                return Color(.systemBlue)
            }
        } else {
            return ColorsRepository.Calendar.emptyDay
        }
    }
}

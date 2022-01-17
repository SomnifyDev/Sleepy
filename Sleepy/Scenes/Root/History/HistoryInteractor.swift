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

    /// Вызывается для подгрузки всей нижней статистики выбранной под календарем
    func extractContextStatistics() {
        FirebaseAnalytics.Analytics.logEvent("History_model_load", parameters: ["type": self.viewModel.calendarType.rawValue])

        switch self.viewModel.calendarType {
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
        if type == .inbed, self.viewModel.inbedHistoryStatsViewModel != nil { return }
        if type == .asleep, self.viewModel.asleepHistoryStatsViewModel != nil { return }

        var last30daysCellData: [StatisticsCellViewModel] = []

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

        if type == .asleep {
            group.enter()
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                // TODO: сюда может вернуться сразу несколько снов за сутки, тогда нарушится логика вывода в график (где каждый столбик = день). FIX IT
                self.viewModel.statisticsProvider.getData(healthType: type,
                                                          interval: self.viewModel.monthBeforeDateInterval,
                                                          bundlePrefixes: ["com.sinapsis", "com.benmustafa"]) { result in
                    if !result.isEmpty {
                        monthSleepPoints = result

                        let suffixValues = result.suffix(14)
                        meanCurrent2WeeksDuration = suffixValues.reduce(0, +) / Double(suffixValues.count)

                        let preffixValues = result.prefix(14)
                        meanLast2WeeksDuration = preffixValues.reduce(0, +) / Double(preffixValues.count)

                        let indicators: [Indicator] = [.min, .max, .mean]
                        indicators.forEach { indicator in
                            switch indicator {
                            case .min:
                                guard let min = result.min() else { return }
                                last30daysCellData.append(
                                    StatisticsCellViewModel(title: self.getLabel(for: type, indicator: indicator),
                                                            value: Date.minutesToDateDescription(minutes: Int(min))))
                            case .max:
                                guard let max = result.max() else { return }
                                last30daysCellData.append(
                                    StatisticsCellViewModel(title: self.getLabel(for: type, indicator: indicator),
                                                            value: Date.minutesToDateDescription(minutes: Int(max))))
                            case .mean:
                                guard let meanCurrent2WeeksDuration = meanCurrent2WeeksDuration, let meanLast2WeeksDuration = meanLast2WeeksDuration else { return }
                                let mean = Int(meanCurrent2WeeksDuration + meanLast2WeeksDuration) / 2
                                last30daysCellData.append(
                                    StatisticsCellViewModel(title: self.getLabel(for: type, indicator: indicator),
                                                            value: Date.minutesToDateDescription(minutes: mean)))
                            case .sum:
                                break
                            }
                        }
                    }
                    group.leave()
                }
            }
        }

        group.notify(queue: .global(qos: .default)) { [weak self] in
            guard let self = self else { return }
            if monthSleepPoints != nil,
               let mean1 = meanCurrent2WeeksDuration, let mean2 = meanLast2WeeksDuration {
                DispatchQueue.main.async {
                    let tmp = SleepHistoryStatsViewModel(calendarData: [],
                                                         monthDate: self.viewModel.monthDate,
                                                         cellData: .init(with: last30daysCellData),
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

    func setupCalendarDataByTypeIfNeeded() {
        guard let calendarType = HKService.HealthType(rawValue: self.viewModel.calendarType.rawValue) else { return }

        var calendarData: [CalendarDayView.DisplayItem]?

        switch calendarType {
        case .energy:
            // todo
            calendarData = []
        case .heart:
            // todo
            calendarData = []
        case .asleep:
            calendarData = self.viewModel.asleepHistoryStatsViewModel?.calendarData
        case .inbed:
            calendarData = self.viewModel.inbedHistoryStatsViewModel?.calendarData
        case .respiratory:
            // todo
            calendarData = []
        }

        if let calendarData = calendarData, !calendarData.isEmpty {
            // модель уже была посчитана ранее для этого месяца и хранится в памяти, пересчитывать не надо
            self.viewModel.calendarData = calendarData
        } else {
            // обнуляем кружки календаря до незаполненных пока идет загрузка данных
            self.viewModel.calendarData = [CalendarDayView.DisplayItem](repeating: .init(value: nil, description: "-", color: ColorsRepository.Calendar.emptyDay, isToday: true),
                                                                        count: self.viewModel.monthDate.getDayInt())

            var newCalendarData = [CalendarDayView.DisplayItem](repeating: .init(value: nil, description: "-", color: ColorsRepository.Calendar.emptyDay, isToday: true),
                                                                count: self.viewModel.monthDate.getDayInt())

            let group = DispatchGroup()

            for dayNumber in 1...self.viewModel.monthDate.getDayInt() {
                group.enter()
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    guard let self = self, let date = Calendar.current.date(byAdding: .day, value: dayNumber - 1, to: self.viewModel.monthDate) else {
                        group.leave()
                        return
                    }

                    self.getDaySleepData(date: date,
                                          calendarType: self.viewModel.calendarType,
                                          completion: { displayItem in

                        newCalendarData[dayNumber - 1] = displayItem
                        group.leave()
                    })
                }
            }
        }

    }


    /// Получение модели для дня месяца для вью календаря
    /// - Parameters:
    ///   - date: Дата для которой нужно получить значения
    ///   - calendarType: тип здоровья, по которому  в данный момент отображает статистику календарь
    ///   - completion: -
    private func getDaySleepData(date: Date, calendarType: HKService.HealthType, completion: @escaping (CalendarDayView.DisplayItem) -> Void) {
        var value: Double?
        var description = "-"
        var color = ColorsRepository.Calendar.emptyDay

        switch calendarType {
        case .heart, .respiratory, .energy:
            self.viewModel.statisticsProvider.getMetaData(healthType: calendarType,
                                                          indicator: .mean,
                                                          interval: DateInterval(start: date.startOfDay, end: date.endOfDay)) { [weak self] val in
                guard let self = self else { return }
                value = val
                color = self.getCircleColor(value: value)

                if let value = value {
                    description = !value.isNaN
                    ? calendarType == .energy
                    ? String(format: "%.2f", value)
                    : String(Int(value))
                    : "-"
                } else {
                    description = "-"
                }

                return completion(.init(value: value, description: description, color: color, isToday: date.isToday()))
            }

        case .asleep, .inbed:
            self.viewModel.statisticsProvider.getData(healthType: calendarType,
                                                      indicator: .sum,
                                                      interval: DateInterval(start: date.startOfDay, end: date.endOfDay),
                                                      bundlePrefixes: ["com.sinapsis", "com.benmustafa"]) { [weak self]  val in
                guard let self = self else { return }
                value = val
                color = self.getCircleColor(value: value)

                if let value = value {
                    description = !value.isNaN ? Date.minutesToDateDescription(minutes: Int(value)) : "-"
                } else {
                    description = "-"
                }

                return completion(.init(value: value, description: description, color: color, isToday: date.isToday()))
            }
        }
    }


    /// получение цвета, характеризующего негативизм значения статистики в календаре если такая оценка возможна
    /// - Parameter value: значение
    /// - Returns: цвет
    private func getCircleColor(value: Double?) -> Color {
        if let value = value {
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

    /// Получение массива из статистик для ячеек под графиком (простая статистика мин-макс-средняя величина)
    func extractBasicNumericDataIfNeeded(type: HKService.HealthType) {
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
                        last30daysCellData.append(StatisticsCellViewModel(title: self.getLabel(for: type, indicator: indicator), value: "\(String(format: self.getValueFormat(for: type), Double(result)))"))
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

    /// Получение строки-индикатора для ячейки базовой статистики под календарем
    func getLabel(for type: HKService.HealthType, indicator: Indicator) -> String {
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

    func getValueFormat(for type: HKService.HealthType) -> String {
        switch type {
        case .respiratory, .heart:
            return "%.0f"
        default:
            return "%.3f"
        }
    }
}

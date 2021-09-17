//
//  HistoryListView.swift
//  Sleepy
//
//  Created by Никита Казанцев on 16.07.2021.
//

import SwiftUI
import XUI
import HKVisualKit
import HKCoreSleep

struct HistoryListView: View {

    @Store var viewModel: HistoryCoordinator
    @Binding var calendarType: HealthData

    @State private var asleepHistoryStatsViewModel: SleepHistoryStatsViewModel?
    @State private var inbedHistoryStatsViewModel: SleepHistoryStatsViewModel?
    @State private var heartHistoryStatsViewModel: HeartHistoryStatsViewModel?
    @State private var energyHistoryStatsViewModel: EnergyHistoryStatsViewModel?

    private let monthBeforeDateInterval = DateInterval(start: Calendar.current.date(byAdding: .day, value: -30, to: Date().endOfDay)!.startOfDay, end: Date().endOfDay)

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                viewModel.colorSchemeProvider.sleepyColorScheme.getColor(of: .general(.appBackgroundColor))
                    .edgesIgnoringSafeArea(.all)

                ScrollView(.vertical, showsIndicators: false) {

                    CalendarView(calendarType: $calendarType,
                                 colorSchemeProvider: viewModel.colorSchemeProvider,
                                 statsProvider: viewModel.statisticsProvider)
                        .roundedCardBackground(color: viewModel.colorSchemeProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))

                    if calendarType == .sleep {
                        if let asleepHistoryStatsViewModel = asleepHistoryStatsViewModel {
                            SleepHistoryStatsView(viewModel: asleepHistoryStatsViewModel,
                                                  colorProvider: viewModel.colorSchemeProvider)
                        } else {
                            MotivationCellView(type: .sleep, colorProvider: self.viewModel.colorSchemeProvider)

                            ErrorView(errorType: .brokenData(type: .sleep),
                                      colorProvider: viewModel.colorSchemeProvider)
                                .roundedCardBackground(color: viewModel.colorSchemeProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))

                            SleepHistoryStatsView(colorProvider: self.viewModel.colorSchemeProvider)
                                .blur(radius: 4)
                        }
                    } else if calendarType == .inbed {
                        if let inbedHistoryStatsViewModel = inbedHistoryStatsViewModel {
                            SleepHistoryStatsView(viewModel: inbedHistoryStatsViewModel,
                                                  colorProvider: viewModel.colorSchemeProvider)
                        } else {
                            MotivationCellView(type: .sleep, colorProvider: self.viewModel.colorSchemeProvider)

                            ErrorView(errorType: .brokenData(type: .inbed),
                                      colorProvider: viewModel.colorSchemeProvider)
                                .roundedCardBackground(color: viewModel.colorSchemeProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))

                            SleepHistoryStatsView(colorProvider: self.viewModel.colorSchemeProvider)
                                .blur(radius: 4)
                        }
                    } else if calendarType == .heart {
                        if let heartHistoryStatsViewModel = heartHistoryStatsViewModel {
                            HeartHistoryStatsView(viewModel: heartHistoryStatsViewModel,
                                                  colorProvider: viewModel.colorSchemeProvider)
                        } else {
                            MotivationCellView(type: .heart, colorProvider: self.viewModel.colorSchemeProvider)

                            ErrorView(errorType: .brokenData(type: .heart),
                                      colorProvider: viewModel.colorSchemeProvider)
                                .roundedCardBackground(color: viewModel.colorSchemeProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))

                            HeartHistoryStatsView(colorProvider: self.viewModel.colorSchemeProvider)
                                .blur(radius: 4)
                        }
                    } else if calendarType == .energy {
                        if let energyHistoryStatsViewModel = energyHistoryStatsViewModel {
                            EnergyHistoryStatsView(viewModel: energyHistoryStatsViewModel,
                                                   colorProvider: viewModel.colorSchemeProvider)
                        } else {
                            MotivationCellView(type: .energy, colorProvider: self.viewModel.colorSchemeProvider)

                            ErrorView(errorType: .brokenData(type: .energy),
                                      colorProvider: viewModel.colorSchemeProvider)
                                .roundedCardBackground(color: viewModel.colorSchemeProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))

                            EnergyHistoryStatsView(colorProvider: self.viewModel.colorSchemeProvider)
                                .blur(radius: 4)
                        }
                    } else {
                        Text("Loading".localized)
                    }

                }
            }
            .onAppear(perform: extractContextStatistics)
            .onChange(of: calendarType) { _ in
                extractContextStatistics()
            }
        }.navigationTitle("Sleep history".localized)
    }

    /// Loads data for each type of calendar phase to fill statistics view below it
    func extractContextStatistics() {
        switch calendarType {
        case .heart:
            extractHeartDataIfNeeded()
        case .energy:
            extractEnergyDataIfNeeded()
        case .sleep:
            extractSleepDataIfNeeded(type: .asleep)
        case .inbed:
            extractSleepDataIfNeeded(type: .inbed)
        }
    }

    func extractSleepDataIfNeeded(type: HKService.HealthType) {
        if (type == .inbed ? inbedHistoryStatsViewModel != nil : asleepHistoryStatsViewModel != nil) ||
            (type != .inbed && type != .asleep) {
            return
        }

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

        // TODO: change bundle prefix to ours when there will be enough data
        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            viewModel.statisticsProvider.getDataByIntervalWithIndicator(healthType: type,
                                                                        indicatorType: .mean,
                                                                        for: current2weeksInterval,
                                                                        bundlePrefixes: ["com.sinapsis", "com.benmustafa"]) { result in
                meanCurrent2WeeksDuration = result
                group.leave()
            }
        }

        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            viewModel.statisticsProvider.getDataByIntervalWithIndicator(healthType: type,
                                                                        indicatorType: .mean,
                                                                        for: last2weeksInterval,
                                                                        bundlePrefixes: ["com.sinapsis", "com.benmustafa"]) { result in
                meanLast2WeeksDuration = result
                group.leave()
            }
        }

        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            viewModel.statisticsProvider.getDataByIntervalWithIndicator(healthType: type,
                                                                        indicatorType: .min,
                                                                        for: monthBeforeDateInterval,
                                                                        bundlePrefixes: ["com.sinapsis", "com.benmustafa"]) { result in
                if let result = result {
                    last30daysCellData.append(StatisticsCellData(title: "Min. duration".localized, value: Date.minutesToDateDescription(minutes: Int(result))))
                }
                group.leave()
            }
        }

        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            viewModel.statisticsProvider.getDataByIntervalWithIndicator(healthType: type,
                                                                        indicatorType: .mean,
                                                                        for: monthBeforeDateInterval,
                                                                        bundlePrefixes: ["com.sinapsis", "com.benmustafa"]) { result in
                if let result = result {
                    last30daysCellData.append(StatisticsCellData(title: "Avg. duration".localized, value: Date.minutesToDateDescription(minutes: Int(result))))
                }
                group.leave()
            }
        }

        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            viewModel.statisticsProvider.getDataByIntervalWithIndicator(healthType: type,
                                                                        indicatorType: .max,
                                                                        for: monthBeforeDateInterval,
                                                                        bundlePrefixes: ["com.sinapsis", "com.benmustafa"]) { result in
                if let result = result {
                    last30daysCellData.append(StatisticsCellData(title: "Max. duration".localized, value: Date.minutesToDateDescription(minutes: Int(result))))
                }
                group.leave()
            }
        }

        if type == .asleep {
            group.enter()
            DispatchQueue.global(qos: .userInitiated).async {
                // TODO: сюда может вернуться сразу несколько снов за сутки, тогда нарушится логика вывода в график (где каждый столбик = день). FIX IT
                viewModel.statisticsProvider.getDataByInterval(healthType: type,
                                                               for: monthBeforeDateInterval,
                                                               bundlePrefixes: ["com.sinapsis", "com.benmustafa"]) { result in
                    monthSleepPoints = result
                    group.leave()
                }
            }
        }

        group.notify(queue: .global(qos: .default)) {

            if let mean1 = meanCurrent2WeeksDuration, let mean2 = meanLast2WeeksDuration {
                let tmp = SleepHistoryStatsViewModel(
                    cellData: last30daysCellData,
                    monthSleepPoints: monthSleepPoints,
                    monthBeforeDateInterval: monthBeforeDateInterval,
                    currentWeeksProgress: ProgressItem(title: String(format: "Mean duration:".localized, Date.minutesToDateDescription(minutes: Int(mean1))),
                                                       text: current2weeksInterval.stringFromDateInterval(type: .days),
                                                       value: Int(mean1))
                    , beforeWeeksProgress: ProgressItem(title: String(format: "Mean duration:".localized, Date.minutesToDateDescription(minutes: Int(mean2))),
                                                        text: last2weeksInterval.stringFromDateInterval(type: .days),
                                                        value: Int(mean2)),
                    analysisString: mean1 == mean2
                    ? String(format: "Your %@ time is equal compared to 2 weeks before".localized, type == .inbed ? "in bed" : "asleep")
                    : String(format: "Compared to 2 weeks before, you %@ %@ by %@ in time".localized, type == .inbed ? "were in bed" : "slept",mean1 > mean2 ? "more" : "less", Date.minutesToDateDescription(minutes: abs(Int(mean1) - Int(mean2)))))

                if type == .inbed {
                    inbedHistoryStatsViewModel = tmp
                } else {
                    asleepHistoryStatsViewModel = tmp
                }
            }
        }
    }

    func extractHeartDataIfNeeded() {
        if heartHistoryStatsViewModel != nil {
            return
        }

        var last30daysCellData: [StatisticsCellData] = []

        let group = DispatchGroup()

        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            viewModel.statisticsProvider.getDataByIntervalWithIndicator(healthType: .heart,
                                                                        indicatorType: .min,
                                                                        for: monthBeforeDateInterval) { result in
                if let result = result {
                    last30daysCellData.append(StatisticsCellData(title: "Min. BPM", value: "\(Int(result))"))
                }
                group.leave()
            }
        }

        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            viewModel.statisticsProvider.getDataByIntervalWithIndicator(healthType: .heart,
                                                                        indicatorType: .mean,
                                                                        for: monthBeforeDateInterval) { result in
                if let result = result {
                    last30daysCellData.append(StatisticsCellData(title: "Avg. BPM", value: "\(Int(result))"))
                }
                group.leave()
            }
        }

        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            viewModel.statisticsProvider.getDataByIntervalWithIndicator(healthType: .heart,
                                                                        indicatorType: .max,
                                                                        for: monthBeforeDateInterval) { result in
                if let result = result {
                    last30daysCellData.append(StatisticsCellData(title: "Max. BPM", value: "\(Int(result))"))
                }
                group.leave()
            }
        }

        group.notify(queue: .global(qos: .default)) {
            if !last30daysCellData.isEmpty {
                heartHistoryStatsViewModel = HeartHistoryStatsViewModel(cellData: last30daysCellData)
            }
        }

    }

    func extractEnergyDataIfNeeded() {
        if energyHistoryStatsViewModel != nil {
            return
        }

        var last30daysCellData: [StatisticsCellData] = []

        let group = DispatchGroup()

        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            viewModel.statisticsProvider.getDataByIntervalWithIndicator(healthType: .energy,
                                                                        indicatorType: .min,
                                                                        for: monthBeforeDateInterval) { result in
                if let result = result {
                    last30daysCellData.append(StatisticsCellData(title: "Min. Kcal", value: "\(result)"))
                }
                group.leave()
            }
        }

        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            viewModel.statisticsProvider.getDataByIntervalWithIndicator(healthType: .energy,
                                                                        indicatorType: .mean,
                                                                        for: monthBeforeDateInterval) { result in
                if let result = result {
                    last30daysCellData.append(StatisticsCellData(title: "Avg. Kcal", value: "\(result)"))
                }
                group.leave()
            }
        }

        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            viewModel.statisticsProvider.getDataByIntervalWithIndicator(healthType: .energy,
                                                                        indicatorType: .max,
                                                                        for: monthBeforeDateInterval) { result in
                if let result = result {
                    last30daysCellData.append(StatisticsCellData(title: "Max. Kcal", value: "\(result)"))
                }
                group.leave()
            }
        }

        group.notify(queue: .global(qos: .default)) {
            if !last30daysCellData.isEmpty {
                energyHistoryStatsViewModel = EnergyHistoryStatsViewModel(cellData: last30daysCellData)
            }
        }

    }
}

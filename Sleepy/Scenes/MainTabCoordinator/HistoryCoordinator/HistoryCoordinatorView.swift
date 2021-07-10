//
//  HistoryCoordinatorView.swift
//  Sleepy
//
//  Created by Анас Бен Мустафа on 6/14/21.
//

import Foundation
import SwiftUI
import XUI
import HKVisualKit

struct HistoryCoordinatorView: View {
    
    // MARK: Stored Properties
    
    @Store var coordinator: HistoryCoordinator

    @State var calendarType: HealthData = .sleep

    @State var shouldShowSleepStatistics = false

    @State var sleepHistoryStatsViewModel: SleepHistoryStatsViewModel?
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView(.vertical, showsIndicators: false) {

                    CalendarView(calendarType: $calendarType,
                                 colorSchemeProvider: coordinator.colorSchemeProvider,
                                 statsProvider: coordinator.statisticsProvider)
                        .roundedCardBackground(color: coordinator.colorSchemeProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))

                    if shouldShowSleepStatistics {
                        if let sleepHistoryStatsViewModel = sleepHistoryStatsViewModel {
                            SleepHistoryStatsView(model: sleepHistoryStatsViewModel,
                                                  colorProvider: coordinator.colorSchemeProvider)
                        }
                    }

                }
                .background(coordinator.colorSchemeProvider.sleepyColorScheme.getColor(of: .general(.appBackgroundColor)))
                .onAppear(perform: extractContextStatistics)
                .onChange(of: calendarType) { _ in
                    extractContextStatistics()
                }
            }
        }.navigationTitle("History")
    }

    func extractContextStatistics() {
        switch calendarType {
        case .heart:
            return
        case .energy:
            return
        case .sleep:
            extractSleepDataIfNeeded()
        case .inbed:
            extractSleepDataIfNeeded()
        }
    }

    func extractSleepDataIfNeeded() {
        if sleepHistoryStatsViewModel != nil {
            shouldShowSleepStatistics = true
            return
        }

        let currDate = Date().endOfDay
        let currDate2weeksbefore = Calendar.current.date(byAdding: .day, value: -13, to: currDate)!.startOfDay

        let twoweeksbeforeDate = Calendar.current.date(byAdding: .day, value: -1, to: currDate2weeksbefore)!
        let monthbeforedate = Calendar.current.date(byAdding: .day, value: -13, to: twoweeksbeforeDate)!.startOfDay
        var mean1: Double?

        let current2weeks = DateInterval(start: currDate2weeksbefore, end: currDate)
        let last2weeks = DateInterval(start: monthbeforedate, end: twoweeksbeforeDate)
        var mean2: Double?

        let group = DispatchGroup()

        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            coordinator.statisticsProvider.getDataByIntervalWithIndicator(healthType: .asleep, indicatorType: .mean, for: current2weeks, bundlePrefix: "com.apple") { result in
                mean1 = result
                group.leave()
            }
        }

        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {

            coordinator.statisticsProvider.getDataByIntervalWithIndicator(healthType: .asleep, indicatorType: .mean, for: last2weeks, bundlePrefix: "com.apple") { result in
                mean2 = result
                group.leave()
            }
        }
        group.notify(queue: .global(qos: .default)) {

            if let mean1 = mean1, let mean2 = mean2 {

                sleepHistoryStatsViewModel = SleepHistoryStatsViewModel(
                    currentWeeksProgress: ProgressItem(title: "Mean sleep duration ...",
                                                       text: "\(Date.minutesToDateDescription(minutes: Int(mean1)))",
                                                       value: Int(mean1))
                    , beforeWeeksProgress: ProgressItem(title: "Mean sleep duration ...",
                                                        text: "\(Date.minutesToDateDescription(minutes: Int(mean2)))",
                                                        value: Int(mean2)))

                shouldShowSleepStatistics = true

            }
        }
    }
    
}

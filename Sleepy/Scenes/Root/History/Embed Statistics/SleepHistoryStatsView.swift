//
//  SleepStatsView.swift
//  Sleepy
//
//  Created by Никита Казанцев on 04.07.2021.
//

import HKVisualKit
import SwiftUI

struct SleepHistoryStatsView: View {
    private let viewModel: SleepHistoryStatsViewModel
    private let colorProvider: ColorSchemeProvider
    private var shouldShowAdvice = true

    init(viewModel: SleepHistoryStatsViewModel, colorProvider: ColorSchemeProvider) {
        self.viewModel = viewModel
        self.colorProvider = colorProvider
    }

    /// Use for shimmers only
    init(colorProvider: ColorSchemeProvider) {
        viewModel = SleepHistoryStatsViewModel(cellData: [StatisticsCellData(title: "some data", value: "14.243")],
                                               monthSleepPoints: [350, 320, 450, 300, 0, 302, 350, 320, 450, 300, 0, 302],
                                               monthBeforeDateInterval: DateInterval(start: Calendar.current.date(byAdding: .day, value: -30, to: Date())!, end: Date()),
                                               currentWeeksProgress: ProgressItem(title: "some title", text: "some subtitle", value: 480),
                                               beforeWeeksProgress: ProgressItem(title: "some title", text: "some subtitle", value: 480),
                                               analysisString: "your sleep is idewkd weoo weoow woo qo oqwoe qoe wewe eweefrv")

        self.colorProvider = colorProvider
        shouldShowAdvice = false
    }

    var body: some View {
        VStack {
            if let monthSleepPoints = viewModel.monthSleepPoints,
               let monthBeforeDateInterval = viewModel.monthBeforeDateInterval
            {
                CardWithChartView(colorProvider: colorProvider,
                                  systemImageName: "sleep",
                                  titleText: "Month sleep duration".localized,
                                  mainTitleText: "Here is some info about your month sleep sessions".localized,
                                  titleColor: colorProvider.sleepyColorScheme.getColor(of: .phases(.deepSleepColor)),
                                  showChevron: false,
                                  chartView: StandardChartView(colorProvider: colorProvider,
                                                               chartType: .defaultChart(barType: .rectangle(color: colorProvider.sleepyColorScheme.getColor(of: .phases(.deepSleepColor)))),
                                                               chartHeight: 75,
                                                               points: monthSleepPoints,
                                                               dateInterval: monthBeforeDateInterval,
                                                               needTimeLine: false,
                                                               dragGestureEnabled: false),
                                  bottomView: EmptyView())
                    .roundedCardBackground(color: colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
            }

            if shouldShowAdvice {
                MotivationCellView(type: .sleep, colorProvider: colorProvider)
            }

            if !viewModel.cellData.isEmpty {
                CardNameTextView(text: "Last 30 days",
                                 color: colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))

                HorizontalStatisticCellView(data: viewModel.cellData,
                                            colorScheme: colorProvider.sleepyColorScheme)
            }

            ProgressChartView(titleText: "Progress",
                              mainText: "Thats some progress you've made in several weeks",
                              systemImage: "timer",
                              colorProvider: colorProvider,
                              currentProgress:
                                ProgressItem(title: viewModel.currentWeeksProgress.title,
                                             text: viewModel.currentWeeksProgress.text,
                                             value: viewModel.currentWeeksProgress.value),
                              beforeProgress:
                                ProgressItem(title: viewModel.beforeWeeksProgress.title,
                                             text: viewModel.beforeWeeksProgress.text,
                                             value: viewModel.beforeWeeksProgress.value),
                              analysisString: viewModel.analysisString,
                              mainColor: colorProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor)),
                              mainTextColor: colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))
                .roundedCardBackground(color: colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
        }
    }
}

struct SleepHistoryStatsViewModel {
    let cellData: [StatisticsCellData]
    let monthSleepPoints: [Double]?
    let monthBeforeDateInterval: DateInterval?
    let currentWeeksProgress: ProgressItem
    let beforeWeeksProgress: ProgressItem
    let analysisString: String
}

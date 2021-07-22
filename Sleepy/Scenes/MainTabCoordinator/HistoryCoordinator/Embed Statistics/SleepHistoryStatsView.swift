//
//  SleepStatsView.swift
//  Sleepy
//
//  Created by Никита Казанцев on 04.07.2021.
//

import SwiftUI
import HKVisualKit

struct SleepHistoryStatsView: View {

    private let viewModel: SleepHistoryStatsViewModel
    private let colorProvider: ColorSchemeProvider

    init(viewModel: SleepHistoryStatsViewModel, colorProvider: ColorSchemeProvider) {
        self.viewModel = viewModel
        self.colorProvider = colorProvider
    }

    var body: some View {

        VStack {
            if let monthSleepPoints = viewModel.monthSleepPoints {
                CardWithChartView(colorProvider: colorProvider,
                                  systemImageName: "sleep",
                                  titleText: "Month sleep duration",
                                  mainTitleText: "Here is the info about your month sleep sessions",
                                  titleColor: colorProvider.sleepyColorScheme.getColor(of: .phases(.deepSleepColor)),
                                  showChevron: false,
                                  chartView: StandardChartView(colorProvider: colorProvider,
                                                               chartType: .defaultChart,
                                                               chartHeight: 75,
                                                               points: monthSleepPoints,
                                                               dragGestureData: "",
                                                               chartColor: colorProvider.sleepyColorScheme.getColor(of: .phases(.deepSleepColor)),
                                                               needOXLine: true,
                                                               needTimeLine: true,
                                                               startTime: "23:00",
                                                               endTime: "6:54",
                                                               needDragGesture: false),
                                  bottomView: EmptyView())
                    .roundedCardBackground(color: colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
            }

            MotivationCellView(type: .sleep, colorProvider: colorProvider)

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
                              currentWeeksProgress:
                                ProgressItem(title: viewModel.currentWeeksProgress.title,
                                             text: viewModel.currentWeeksProgress.text,
                                             value: viewModel.currentWeeksProgress.value),
                              beforeWeeksProgress:
                                ProgressItem(title: viewModel.beforeWeeksProgress.title,
                                             text: viewModel.beforeWeeksProgress.text,
                                             value: viewModel.beforeWeeksProgress.value),
                              analysisString: viewModel.analysisString,
                              mainColor: colorProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor)))
                .roundedCardBackground(color: colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
        }
    }
}

struct SleepHistoryStatsViewModel {
    let cellData: [StatisticsCellData]
    let monthSleepPoints: [Double]?
    let currentWeeksProgress: ProgressItem
    let beforeWeeksProgress: ProgressItem
    let analysisString: String
}

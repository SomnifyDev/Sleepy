// Copyright (c) 2021 Sleepy.

import SwiftUI
import UIComponents

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
		self.viewModel = SleepHistoryStatsViewModel(cellData: [StatisticsCellData(title: "some data", value: "14.243")],
		                                            monthSleepPoints: [350, 320, 450, 300, 0, 302, 350, 320, 450, 300, 0, 302],
		                                            monthBeforeDateInterval: DateInterval(start: Calendar.current.date(byAdding: .day, value: -30, to: Date())!, end: Date()),
		                                            currentWeeksProgress: ProgressItem(title: "some title", text: "some subtitle", value: 480),
		                                            beforeWeeksProgress: ProgressItem(title: "some title", text: "some subtitle", value: 480),
		                                            analysisString: "your sleep is idewkd weoo weoow woo qo oqwoe qoe wewe eweefrv")

		self.colorProvider = colorProvider
		self.shouldShowAdvice = false
	}

	var body: some View {
		VStack {
			if let monthSleepPoints = viewModel.monthSleepPoints,
			   let monthBeforeDateInterval = viewModel.monthBeforeDateInterval
			{
				CardWithChartView(colorProvider: colorProvider,
				                  systemImageName: "sleep",
				                  titleText: "Month sleep duration",
				                  mainTitleText: "Here is some info about your month sleep sessions",
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
				MotivationCellView(type: .asleep, colorProvider: colorProvider)
			}

			if !viewModel.cellData.isEmpty {
				SectionNameTextView(text: "Last 30 days",
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

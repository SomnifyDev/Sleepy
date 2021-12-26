// Copyright (c) 2021 Sleepy.

import SwiftUI
import UIComponents

struct SleepHistoryStatsView: View {
	private let viewModel: SleepHistoryStatsViewModel

	private var shouldShowAdvice = true

	init(viewModel: SleepHistoryStatsViewModel) {
		self.viewModel = viewModel
	}

	/// Use for shimmers only
	init() {
		self.viewModel = SleepHistoryStatsViewModel(cellData: [StatisticsCellViewModel(title: "some data", value: "14.243")],
		                                            monthSleepPoints: [350, 320, 450, 300, 0, 302, 350, 320, 450, 300, 0, 302],
		                                            monthBeforeDateInterval: DateInterval(start: Calendar.current.date(byAdding: .day, value: -30, to: Date())!, end: Date()),
                                                    currentWeeksProgress: ProgressElementViewModel(title: "some title", payloadText: "some subtitle", value: 480),
                                                    beforeWeeksProgress: ProgressElementViewModel(title: "some title", payloadText: "some subtitle", value: 480),
		                                            analysisString: "your sleep is idewkd weoo weoow woo qo oqwoe qoe wewe eweefrv")
		self.shouldShowAdvice = false
	}

	var body: some View {
		VStack {
			if let monthSleepPoints = viewModel.monthSleepPoints,
			   let monthBeforeDateInterval = viewModel.monthBeforeDateInterval
			{
				CardWithChartView(systemImageName: "sleep",
				                  titleText: "Month sleep duration",
				                  mainTitleText: "Here is some info about your month sleep sessions",
                                  titleColor: ColorsRepository.Phase.deepSleep,
				                  showChevron: false,
				                  chartView: StandardChartView(chartType: .defaultChart(barType: .rectangle(color: ColorsRepository.Phase.deepSleep)),
				                                               chartHeight: 75,
				                                               points: monthSleepPoints,
				                                               dateInterval: monthBeforeDateInterval,
				                                               needTimeLine: false,
				                                               dragGestureEnabled: false),
				                  bottomView: EmptyView())
                    .roundedCardBackground(color: ColorsRepository.Card.cardBackground)
			}

			if shouldShowAdvice {
				MotivationCellView(type: .asleep)
			}

			if !viewModel.cellData.isEmpty {
				SectionNameTextView(text: "Last 30 days",
				                    color: ColorsRepository.Text.standard)

				StatisticsCellCollectionView(data: viewModel.cellData)
			}

			ProgressChartView(titleText: "Progress",
			                  mainText: "Thats some progress you've made in several weeks",
			                  systemImage: "timer",
			                  currentProgress:
			                  ProgressElementViewModel(title: viewModel.currentWeeksProgress.title,
			                               text: viewModel.currentWeeksProgress.text,
			                               value: viewModel.currentWeeksProgress.value),
			                  beforeProgress:
			                  ProgressElementViewModel(title: viewModel.beforeWeeksProgress.title,
			                               text: viewModel.beforeWeeksProgress.text,
			                               value: viewModel.beforeWeeksProgress.value),
			                  analysisString: viewModel.analysisString,
			                  mainColor: colorProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor)),
			                  mainTextColor: ColorsRepository.Text.standard)
				.roundedCardBackground(color: colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
		}
	}
}

struct SleepHistoryStatsViewModel {
	let cellData: [StatisticsCellViewModel]
	let monthSleepPoints: [Double]?
	let monthBeforeDateInterval: DateInterval?
	let currentWeeksProgress: ProgressElementViewModel
	let beforeWeeksProgress: ProgressElementViewModel
	let analysisString: String
}

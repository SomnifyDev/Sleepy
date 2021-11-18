// Copyright (c) 2021 Sleepy.

import HKVisualKit
import SwiftUI

struct RespiratoryHistoryStatsView: View {
	private let viewModel: RespiratoryHistoryStatsViewModel
	private let colorProvider: ColorSchemeProvider
	private var shouldShowAdvice = false

	init(viewModel: RespiratoryHistoryStatsViewModel, colorProvider: ColorSchemeProvider) {
		self.viewModel = viewModel
		self.colorProvider = colorProvider
	}

	/// Use for shimmers only
	init(colorProvider: ColorSchemeProvider) {
		self.viewModel = RespiratoryHistoryStatsViewModel(cellData: [
			StatisticsCellData(title: "Fest sw", value: "23 BPM"),
			StatisticsCellData(title: "Ewd sw", value: "143 min"),
			StatisticsCellData(title: "Wdf sw", value: "9 max"),
		])
		self.colorProvider = colorProvider
	}

	var body: some View {
		VStack {
			if shouldShowAdvice {
				MotivationCellView(type: .heart, colorProvider: colorProvider)
			}

			if !viewModel.cellData.isEmpty {
				SectionNameTextView(text: "Last 30 days",
				                    color: colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))

				HorizontalStatisticCellView(data: viewModel.cellData,
				                            colorScheme: colorProvider.sleepyColorScheme)
			}
		}
	}
}

struct RespiratoryHistoryStatsViewModel {
	let cellData: [StatisticsCellData]
}

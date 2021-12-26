// Copyright (c) 2021 Sleepy.

import SwiftUI
import UIComponents

struct HeartHistoryStatisticsView: View {
	private let viewModel: HeartHistoryStatisticsViewModel

	init(viewModel: HeartHistoryStatisticsViewModel) {
		self.viewModel = viewModel
	}

	/// Use for shimmers only
	init(colorProvider: ColorSchemeProvider) {
		self.viewModel = HeartHistoryStatisticsViewModel(cellData: [
			StatisticsCellData(title: "Fest sw", value: "23 BPM"),
			StatisticsCellData(title: "Ewd sw", value: "143 min"),
			StatisticsCellData(title: "Wdf sw", value: "9 max"),
		])
		self.colorProvider = colorProvider
	}

	var body: some View {
		VStack {
			MotivationCellView(type: .heart, colorProvider: colorProvider)

			if !viewModel.cellData.isEmpty {
				SectionNameTextView(text: "Last 30 days",
				                    color: colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))

				//                StatisticsCellView(with: <#T##StatisticsCellViewModel#>)
				viewModel

				HorizontalStatisticCellView(data: viewModel.cellData,
				                            colorScheme: colorProvider.sleepyColorScheme)
			}
		}
	}
}

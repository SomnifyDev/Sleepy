// Copyright (c) 2021 Sleepy.

import SwiftUI
import UIComponents

struct RespiratoryHistoryStatsView: View {
	private let viewModel: StatisticsCellCollectionViewModel

	private var shouldShowAdvice = false

	init(viewModel: StatisticsCellCollectionViewModel) {
		self.viewModel = viewModel
	}

	/// Use for shimmers only
	init() {
		self.viewModel = StatisticsCellCollectionViewModel(cellData: [
			StatisticsCellViewModel(title: "Fest sw", value: "23 BPM"),
			StatisticsCellViewModel(title: "Ewd sw", value: "143 min"),
			StatisticsCellViewModel(title: "Wdf sw", value: "9 max"),
		])
	}

	var body: some View {
		VStack {
//			if shouldShowAdvice {
//				MotivationCellView(with: .heart)
//			}

			if !viewModel.cellData.isEmpty {
				SectionNameTextView(text: "Last 30 days",
                                    color: ColorsRepository.Text.standard)

                StatisticsCellCollectionView(with: viewModel)
			}
		}
	}
}

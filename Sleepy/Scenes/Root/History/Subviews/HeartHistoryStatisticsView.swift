// Copyright (c) 2021 Sleepy.

import SwiftUI
import UIComponents

struct HeartHistoryStatisticsView: View {
	private let viewModel: StatisticsCellCollectionViewModel

	init(viewModel: StatisticsCellCollectionViewModel) {
		self.viewModel = viewModel
	}

	/// Use for shimmers only
	init() {
        self.viewModel = StatisticsCellCollectionViewModel(with: [
			StatisticsCellViewModel(title: "Fest sw", value: "23 BPM"),
			StatisticsCellViewModel(title: "Ewd sw", value: "143 min"),
			StatisticsCellViewModel(title: "Wdf sw", value: "9 max"),
		])
	}

	var body: some View {
		VStack {
            MotivationCellView(with: .init(leadIcon: IconsRepository.article,
                                           title: "What your sleep data means",
                                           description: "A normal resting heart rate ranges from 60 to 100 beats per minute, according to Harvard Health.",
                                           url: URL(string: "https://www.cnet.com/health/sleep/sleeping-heart-rate-breathing-rate-and-hrv-what-your-sleep-data-means/")!))

            if !viewModel.cellModels.isEmpty {
				SectionNameTextView(text: "Last 30 days",
				                    color: ColorsRepository.Text.standard)

                StatisticsCellCollectionView(with: viewModel)
			}
		}
	}
}

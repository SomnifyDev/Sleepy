// Copyright (c) 2022 Sleepy.

import SwiftUI
import UIComponents

struct EnergyHistoryStatsView: View {
    private let viewModel: StatisticsCellCollectionViewModel

    private var shouldShowAdvice = true

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
            MotivationCellView(with: .init(
                leadIcon: IconsRepository.article,
                title: "How Your Body Use Calories While You Sleep",
                description: "Energy use is particularly high during REM (rapid eye movement) sleep.",
                url: URL(string: "https://www.alaskasleep.com/blog/how-your-body-use-calories-while-you-sleep")!
            ))

            if !viewModel.cellModels.isEmpty {
                SectionNameTextView(
                    text: "Last 30 days",
                    color: ColorsRepository.Text.standard
                )

                StatisticsCellCollectionView(with: viewModel)
            }
        }
    }
}

// Copyright (c) 2021 Sleepy.

import HKVisualKit
import SwiftUI

struct EnergyHistoryStatsView: View
{
    private let viewModel: EnergyHistoryStatsViewModel
    private let colorProvider: ColorSchemeProvider
    private var shouldShowAdvice = true

    init(viewModel: EnergyHistoryStatsViewModel, colorProvider: ColorSchemeProvider)
    {
        self.viewModel = viewModel
        self.colorProvider = colorProvider
    }

    /// use for shimmers only
    init(colorProvider: ColorSchemeProvider)
    {
        self.viewModel = EnergyHistoryStatsViewModel(cellData: [
            StatisticsCellData(title: "Fest sw", value: "23 BPM"),
            StatisticsCellData(title: "Ewd sw", value: "143 min"),
            StatisticsCellData(title: "Wdf sw", value: "9 max"),
        ])
        self.colorProvider = colorProvider
    }

    var body: some View
    {
        VStack
        {
            if shouldShowAdvice
            {
                MotivationCellView(type: .energy, colorProvider: colorProvider)
            }

            if !viewModel.cellData.isEmpty
            {
                SectionNameTextView(
                    text: "Last 30 days",
                    color: colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText))
                )

                HorizontalStatisticCellView(
                    data: viewModel.cellData,
                    colorScheme: colorProvider.sleepyColorScheme
                )
            }
        }
    }
}

struct EnergyHistoryStatsViewModel
{
    let cellData: [StatisticsCellData]
}

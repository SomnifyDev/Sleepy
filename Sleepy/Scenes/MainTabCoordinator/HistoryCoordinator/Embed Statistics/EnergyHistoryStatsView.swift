//
//  SleepStatsView.swift
//  Sleepy
//
//  Created by Никита Казанцев on 04.07.2021.
//

import SwiftUI
import HKVisualKit

struct EnergyHistoryStatsView: View {

    private let viewModel: SleepHistoryStatsViewModel
    private let colorProvider: ColorSchemeProvider

    init(viewModel: SleepHistoryStatsViewModel, colorProvider: ColorSchemeProvider) {
        self.viewModel = viewModel
        self.colorProvider = colorProvider
    }

    var body: some View {
        VStack {
            MotivationCellView(type: .energy, colorProvider: colorProvider)

            if !viewModel.cellData.isEmpty {
                CardNameTextView(text: "Last 30 days",
                                 color: colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))

                HorizontalStatisticCellView(data: viewModel.cellData,
                                            colorScheme: colorProvider.sleepyColorScheme)
            }
        }
    }
}

struct EnergyHistoryStatsViewModel {
    let cellData: [StatisticsCellData]
}

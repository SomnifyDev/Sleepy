//
//  SleepStatsView.swift
//  Sleepy
//
//  Created by Никита Казанцев on 04.07.2021.
//

import SwiftUI
import HKVisualKit

struct HeartHistoryStatsView: View {

    private let viewModel: HeartHistoryStatsViewModel
    private let colorProvider: ColorSchemeProvider

    init(viewModel: HeartHistoryStatsViewModel, colorProvider: ColorSchemeProvider) {
        self.viewModel = viewModel
        self.colorProvider = colorProvider
    }

    var body: some View {

        VStack {

            MotivationCellView(type: .heart, colorProvider: colorProvider)

            if !viewModel.cellData.isEmpty {
                CardNameTextView(text: "Last 30 days",
                                 color: colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))

                HorizontalStatisticCellView(data: viewModel.cellData,
                                            colorScheme: colorProvider.sleepyColorScheme)
            }
        }
    }
}

struct HeartHistoryStatsViewModel {
    let cellData: [StatisticsCellData]
}

//
//  SleepStatsView.swift
//  Sleepy
//
//  Created by Никита Казанцев on 04.07.2021.
//

import SwiftUI
import HKVisualKit

struct SleepHistoryStatsView: View {

    let model: SleepHistoryStatsViewModel
    let colorProvider: ColorSchemeProvider

    var body: some View {
        ProgressChartView(colorProvider: colorProvider,
                          currentWeeksProgress:
                            ProgressItem(title: model.currentWeeksProgress.title,
                                         text: model.currentWeeksProgress.text,
                                         value: model.currentWeeksProgress.value),
                          beforeWeeksProgress:
                            ProgressItem(title: model.beforeWeeksProgress.title,
                                         text: model.beforeWeeksProgress.text,
                                         value: model.beforeWeeksProgress.value),
                          analysisString: model.analysisString)
            .roundedCardBackground(color: colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
    }
}

struct SleepHistoryStatsViewModel {
    let currentWeeksProgress: ProgressItem
    let beforeWeeksProgress: ProgressItem
    let analysisString: String
}

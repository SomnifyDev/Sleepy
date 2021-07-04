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
    let colorScheme: SleepyColorScheme

    var body: some View {
        ProgressChartView(currentWeeksProgress: ProgressItem(title: "Ср время сна: \(model.currentWeeksProgress.value) м ",
                                                             text: "08.07 - 14.07",
                                                             value: model.currentWeeksProgress.value),
                          beforeWeeksProgress: ProgressItem(title: "Ср время сна: \(model.beforeWeeksProgress.value)",
                                                            text: "01.07 - 07.07",
                                                            value: model.beforeWeeksProgress.value))
            .roundedCardBackground(color: colorScheme.getColor(of: .card(.cardBackgroundColor)))
    }
}

struct SleepHistoryStatsViewModel {
    let currentWeeksProgress: ProgressItem
    let beforeWeeksProgress: ProgressItem
}

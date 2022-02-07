// Copyright (c) 2022 Sleepy.

import SwiftUI
import UIComponents
import XUI

struct SleepHistoryStatsDisplayItem {
    let cellData: StatisticsCellCollectionViewModel
    let monthSleepPoints: [Double]?
    let monthBeforeDateInterval: DateInterval?
    let currentWeeksProgress: ProgressElementViewModel
    let beforeWeeksProgress: ProgressElementViewModel
    let analysisString: String
}

struct SleepHistoryStatsView: View {
    let viewModel: HistoryCoordinator
    let displayItem: SleepHistoryStatsDisplayItem

    init(viewModel: HistoryCoordinator, displayItem: SleepHistoryStatsDisplayItem) {
        self.viewModel = viewModel
        self.displayItem = displayItem
    }

    /// Use for shimmers only
    init(viewModel: HistoryCoordinator) {
        self.displayItem = SleepHistoryStatsDisplayItem(
            cellData: .init(with: [StatisticsCellViewModel(title: "some data", value: "14.243")]),
            monthSleepPoints: [350, 320, 450, 300, 0, 302, 350, 320, 450, 300, 0, 302],
            monthBeforeDateInterval: DateInterval(start: Calendar.current.date(byAdding: .day, value: -30, to: Date())!, end: Date()),
            currentWeeksProgress: ProgressElementViewModel(title: "some title", payloadText: "some subtitle", value: 480),
            beforeWeeksProgress: ProgressElementViewModel(title: "some title", payloadText: "some subtitle", value: 480),
            analysisString: "your sleep is idewkd weoo weoow woo qo oqwoe qoe wewe eweefrv"
        )
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            MotivationCellView(with: .init(
                leadIcon: IconsRepository.article,
                title: "Quality of sleep",
                description: "Research shows that poor sleep has immediate negative effects on your hormones, exercise performance, and brain function.",
                url: URL(string: "https://www.mayoclinic.org/healthy-lifestyle/adult-health/in-depth/sleep/art-20048379")!
            ))

            if !displayItem.cellData.cellModels.isEmpty {
                SectionNameTextView(
                    text: "Last 30 days",
                    color: ColorsRepository.Text.standard
                )

                StatisticsCellCollectionView(with: displayItem.cellData)
            }

            ProgressChartView(with: .init(
                cardTitleViewModel: .init(
                    leadIcon: IconsRepository.timer,
                    title: "Progress",
                    description: "Thats some progress you've made in several weeks",
                    trailIcon: nil,
                    trailText: nil,
                    titleColor: ColorsRepository.Text.standard,
                    descriptionColor: nil,
                    shouldShowSeparator: false
                ),
                description: displayItem.analysisString,
                beforeProgressViewModel: ProgressElementViewModel(
                    title: displayItem.beforeWeeksProgress.title,
                    payloadText: displayItem.beforeWeeksProgress.payloadText,
                    value: displayItem.beforeWeeksProgress.value
                ),
                currentProgressViewModel: ProgressElementViewModel(
                    title: displayItem.currentWeeksProgress.title,
                    payloadText: displayItem.currentWeeksProgress.payloadText,
                    value: displayItem.currentWeeksProgress.value
                )
            ))
                .roundedCardBackground(color: ColorsRepository.Card.cardBackground)
        }
    }
}

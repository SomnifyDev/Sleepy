// Copyright (c) 2021 Sleepy.

import SwiftUI
import UIComponents

struct SleepHistoryStatsView: View {
    private let viewModel: SleepHistoryStatsViewModel
    
    init(viewModel: SleepHistoryStatsViewModel) {
        self.viewModel = viewModel
    }

    /// Use for shimmers only
    init() {
        self.viewModel = SleepHistoryStatsViewModel(cellData: .init(with: [StatisticsCellViewModel(title: "some data", value: "14.243")]),
                                                    monthSleepPoints: [350, 320, 450, 300, 0, 302, 350, 320, 450, 300, 0, 302],
                                                    monthBeforeDateInterval: DateInterval(start: Calendar.current.date(byAdding: .day, value: -30, to: Date())!, end: Date()),
                                                    currentWeeksProgress: ProgressElementViewModel(title: "some title", payloadText: "some subtitle", value: 480),
                                                    beforeWeeksProgress: ProgressElementViewModel(title: "some title", payloadText: "some subtitle", value: 480),
                                                    analysisString: "your sleep is idewkd weoo weoow woo qo oqwoe qoe wewe eweefrv")
    }

    var body: some View {
        VStack {
            if let monthSleepPoints = viewModel.monthSleepPoints,
               let monthBeforeDateInterval = viewModel.monthBeforeDateInterval
            {
                CardWithContentView(with: .init(leadIcon: IconsRepository.sleep,
                                                title: "Month sleep duration",
                                                description: "Here is some info about your month sleep sessions",
                                                trailIcon: nil,
                                                trailText: nil,
                                                titleColor: ColorsRepository.Phase.deepSleep,
                                                descriptionColor: nil,
                                                shouldShowSeparator: false),
                                    content: { StandardChartView(chartType: .defaultChart(barType: .rectangular(color: ColorsRepository.Phase.deepSleep)),
                                                                 chartHeight: 75,
                                                                 points: monthSleepPoints,
                                                                 dateInterval: monthBeforeDateInterval,
                                                                 needTimeLine: false,
                                                                 dragGestureEnabled: false) })
                    .roundedCardBackground(color: ColorsRepository.Card.cardBackground)
            }

                MotivationCellView(with: .init(leadIcon: IconsRepository.article,
                                               title: "Quality of sleep",
                                               description: "Research shows that poor sleep has immediate negative effects on your hormones, exercise performance, and brain function.",
                                               url: URL(string: "https://www.mayoclinic.org/healthy-lifestyle/adult-health/in-depth/sleep/art-20048379")!))

            if !viewModel.cellData.cellModels.isEmpty {
                SectionNameTextView(text: "Last 30 days",
                                    color: ColorsRepository.Text.standard)

                StatisticsCellCollectionView(with: viewModel.cellData)
            }

            ProgressChartView(with: .init(cardTitleViewModel: .init(leadIcon: IconsRepository.timer,
                                                                    title: "Progress",
                                                                    description: "Thats some progress you've made in several weeks", trailIcon: nil,
                                                                    trailText: nil,
                                                                    titleColor: ColorsRepository.Text.standard,
                                                                    descriptionColor: nil,
                                                                    shouldShowSeparator: false),
                                          description: viewModel.analysisString,
                                          beforeProgressViewModel: ProgressElementViewModel(title: viewModel.beforeWeeksProgress.title,
                                                                                            payloadText: viewModel.beforeWeeksProgress.payloadText,
                                                                                            value: viewModel.beforeWeeksProgress.value),
                                          currentProgressViewModel: ProgressElementViewModel(title: viewModel.currentWeeksProgress.title,
                                                                                             payloadText: viewModel.currentWeeksProgress.payloadText,
                                                                                             value: viewModel.currentWeeksProgress.value)))
                .roundedCardBackground(color: ColorsRepository.Card.cardBackground)
        }
    }
}

struct SleepHistoryStatsViewModel {
    let cellData: StatisticsCellCollectionViewModel
    let monthSleepPoints: [Double]?
    let monthBeforeDateInterval: DateInterval?
    let currentWeeksProgress: ProgressElementViewModel
    let beforeWeeksProgress: ProgressElementViewModel
    let analysisString: String
}

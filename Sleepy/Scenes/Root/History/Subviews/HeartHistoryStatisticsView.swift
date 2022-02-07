// Copyright (c) 2022 Sleepy.

import HKStatistics
import SwiftUI
import UIComponents
import XUI

struct HeartHistoryStatsDisplayItem {
    let cellData: [StatisticsCellViewModel]
    let ssdnCardTitleViewModel: CardTitleViewModel
    let ssdnMonthChangesValues: [ChartPointDisplayItem]
}

struct HeartHistoryStatisticsView: View {
    let viewModel: HistoryCoordinator
    let displayItem: HeartHistoryStatsDisplayItem

    init(viewModel: HistoryCoordinator, displayItem: HeartHistoryStatsDisplayItem) {
        self.viewModel = viewModel
        self.displayItem = displayItem
    }

    /// Use for shimmers only
    init(viewModel: HistoryCoordinator) {
        self.displayItem = .init(
            cellData: [
                StatisticsCellViewModel(title: "Fest sw", value: "23 BPM"),
                StatisticsCellViewModel(title: "Ewd sw", value: "143 min"),
                StatisticsCellViewModel(title: "Wdf sw", value: "9 max"),
            ],
            ssdnCardTitleViewModel: HistoryFactory().makeSsdnCardTitleViewModel(),
            ssdnMonthChangesValues: []
        )

        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            MotivationCellView(with: .init(
                leadIcon: IconsRepository.article,
                title: "What your sleep data means",
                description: "A normal resting heart rate ranges from 60 to 100 beats per minute, according to Harvard Health.",
                url: URL(string: "https://www.cnet.com/health/sleep/sleeping-heart-rate-breathing-rate-and-hrv-what-your-sleep-data-means/")!
            ))

            if !self.displayItem.cellData.isEmpty {
                SectionNameTextView(
                    text: "Last 30 days",
                    color: ColorsRepository.Text.standard
                )

                StatisticsCellCollectionView(with: StatisticsCellCollectionViewModel(with: displayItem.cellData))
            }

            if self.displayItem.ssdnMonthChangesValues.count > 14 {
                SectionNameTextView(
                    text: "SSDN for last month",
                    color: ColorsRepository.Text.standard
                )
                CardWithContentView(with: viewModel.ssdnCardTitleViewModel) {
                    StandardChartView(
                        chartType: .defaultChart(
                            barType: .circular(color: ColorsRepository.Heart.heart),
                            stringFormatter: "%.0f"
                        ),
                        points: self.displayItem.ssdnMonthChangesValues,
                        chartHeight: 75,
                        timeLineType: .some(dateInterval: self.viewModel.monthBeforeDateInterval, formatType: .days)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .roundedCardBackground(color: ColorsRepository.Card.cardBackground)
            }
        }
    }
}

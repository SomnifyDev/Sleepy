// Copyright (c) 2021 Sleepy.

import SwiftUI
import UIComponents
import HKStatistics

struct HeartHistoryStatisticsView: View {
    private let viewModel: HeartHistoryStatsViewModel

    init(viewModel: HeartHistoryStatsViewModel) {
        self.viewModel = viewModel
    }

    /// Use for shimmers only
    init() {
        self.viewModel = .init(cellData: [
            StatisticsCellViewModel(title: "Fest sw", value: "23 BPM"),
            StatisticsCellViewModel(title: "Ewd sw", value: "143 min"),
            StatisticsCellViewModel(title: "Wdf sw", value: "9 max")],
                               ssdnCardTitleViewModel: HistoryFactory().makeSsdnCardTitleViewModel(),
                               ssdnMonthChangesValues: [])
    }

    var body: some View {
        VStack {
            MotivationCellView(with: .init(leadIcon: IconsRepository.article,
                                           title: "What your sleep data means",
                                           description: "A normal resting heart rate ranges from 60 to 100 beats per minute, according to Harvard Health.",
                                           url: URL(string: "https://www.cnet.com/health/sleep/sleeping-heart-rate-breathing-rate-and-hrv-what-your-sleep-data-means/")!))

            if !viewModel.cellData.isEmpty {
                SectionNameTextView(text: "Last 30 days",
                                    color: ColorsRepository.Text.standard)

                StatisticsCellCollectionView(with: StatisticsCellCollectionViewModel(with: viewModel.cellData))
            }

            SectionNameTextView(
                text: "SSDN for last month",
                color: ColorsRepository.Text.standard
            )
            CardWithContentView(with: viewModel.ssdnCardTitleViewModel) {
                StandardChartView(
                    chartType: .defaultChart(barType: .circular(color: ColorsRepository.Heart.heart)),
                    chartHeight: 75,
                    points: self.viewModel.ssdnMonthChangesValues.compactMap { $0?.value },
                    dateInterval: .init(start: Date().startOfMonth.startOfDay, end: Date().endOfDay),
                    needOXLine: true,
                    needTimeLine: false,
                    dragGestureEnabled: false
                )
            }
            .buttonStyle(PlainButtonStyle())
            .roundedCardBackground(color: ColorsRepository.Card.cardBackground)
        }
    }
}

struct HeartHistoryStatsViewModel {
    let cellData: [StatisticsCellViewModel]
    let ssdnCardTitleViewModel: CardTitleViewModel
    let ssdnMonthChangesValues: [StatsIndicatorModel?]
}

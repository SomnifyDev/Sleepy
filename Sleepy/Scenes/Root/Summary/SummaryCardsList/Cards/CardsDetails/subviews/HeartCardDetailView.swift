// Copyright (c) 2022 Sleepy.

import FirebaseAnalytics
import HKCoreSleep
import HKStatistics
import SwiftUI
import UIComponents
import XUI

struct HeartCardDetailView: View {
    @Store var viewModel: CardDetailsViewCoordinator
    @EnvironmentObject var cardService: CardService

    @State private var showAdvice = false
    @State private var activeSheet: AdviceType!

    var body: some View {
        ZStack {
            ColorsRepository.General.appBackground
                .edgesIgnoringSafeArea(.all)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .center) {
                    if let heartViewModel = cardService.heartViewModel,
                       let generalViewModel = cardService.generalViewModel
                    {
                        // MARK: Chart

                        StandardChartView(
                            chartType: .defaultChart(
                                barType: .circular(color: ColorsRepository.Heart.heart)
                            ),
                            chartHeight: 75,
                            points: heartViewModel.heartRateData,
                            dateInterval: generalViewModel.sleepInterval,
                            needOXLine: true,
                            needTimeLine: true,
                            dragGestureEnabled: true
                        )
                            .roundedCardBackground(
                                color: ColorsRepository.Card.cardBackground
                            )
                            .padding(.top)

                        // MARK: Statistics

                        SectionNameTextView(
                            text: "Summary",
                            color: ColorsRepository.Text.standard
                        )

                        StatisticsCellCollectionView(
                            with: StatisticsCellCollectionViewModel(
                                with: [
                                    StatisticsCellViewModel(
                                        title: "Average pulse",
                                        value: heartViewModel.averageHeartRate
                                    ),
                                    StatisticsCellViewModel(
                                        title: "Max pulse",
                                        value: heartViewModel.maxHeartRate
                                    ),
                                    StatisticsCellViewModel(
                                        title: "Min pulse",
                                        value: heartViewModel.minHeartRate
                                    ),
                                ]
                            )
                        )

                        // MARK: Indicators

                        SectionNameTextView(
                            text: "Indicators",
                            color: ColorsRepository.Text.standard
                        )

                        VStack {
                            ForEach(heartViewModel.indicators, id: \.self) { model in
                                StatsIndicatorView(viewModel: model)
                                    .roundedCardBackground(
                                        color: ColorsRepository.Card.cardBackground
                                    )
                            }
                        }
                    }

                    // MARK: Advices

                    SectionNameTextView(
                        text: "What else?",
                        color: ColorsRepository.Text.standard
                    )

                    ArticleCardView(
                        with: ArticleCardViewModel(
                            title: "Heart and sleep",
                            description: "Learn more about the importance of sleep for heart health.",
                            coverImage: Image("heartAdvice")
                        ),
                        shouldOpenDestinationView: $showAdvice,
                        destinationView: AdviceView(
                            sheetType: .heartAdvice,
                            showAdvice: $showAdvice
                        )
                    )
                        .usefulInfoCardBackground(color: ColorsRepository.Card.cardBackground)
                }
            }
            .navigationTitle("Heart")
            .onAppear(perform: self.sendAnalytics)
        }
    }

    private func sendAnalytics() {
        FirebaseAnalytics.Analytics.logEvent("HeartCard_viewed", parameters: [
            "contentShown": self.cardService.generalViewModel != nil && self.cardService.heartViewModel != nil,
        ])
    }
}

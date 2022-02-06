// Copyright (c) 2022 Sleepy.

import FirebaseAnalytics
import HKCoreSleep
import HKStatistics
import SwiftUI
import UIComponents
import XUI

struct PhasesCardDetailView: View {
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
                    if let phasesViewModel = cardService.phasesViewModel,
                       let generalViewModel = cardService.generalViewModel
                    {
                        // MARK: Chart

                        StandardChartView(
                            chartType: .phasesChart,
                            points: phasesViewModel.phasesData,
                            chartHeight: 75,
                            timeLineType: .some(dateInterval: generalViewModel.sleepInterval, formatType: .time)
                        )
                            .roundedCardBackground(color: ColorsRepository.Card.cardBackground)
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
                                        title: "Total NREM sleep duration",
                                        value: phasesViewModel.timeInDeepPhase
                                    ),
                                    StatisticsCellViewModel(
                                        title: "Max NREM sleep interval",
                                        value: phasesViewModel.mostIntervalInDeepPhase
                                    ),
                                    StatisticsCellViewModel(
                                        title: "Total REM sleep duration",
                                        value: phasesViewModel.timeInLightPhase
                                    ),
                                    StatisticsCellViewModel(
                                        title: "Max REM sleep interval",
                                        value: phasesViewModel.mostIntervalInLightPhase
                                    ),
                                ]
                            )
                        )
                    }

                    // MARK: Advice

                    SectionNameTextView(
                        text: "What else?",
                        color: ColorsRepository.Text.standard
                    )

                    ArticleCardView(
                        with: ArticleCardViewModel(
                            title: "Sleep phases and stages",
                            description: "Learn more about sleep phases and stages.",
                            coverImage: Image("phasesAdvice")
                        ),
                        shouldOpenDestinationView: $showAdvice,
                        destinationView: AdviceView(
                            sheetType: .phasesAdvice,
                            showAdvice: $showAdvice
                        )
                    )
                        .usefulInfoCardBackground(color: ColorsRepository.Card.cardBackground)
                }
            }
            .navigationTitle("Sleep phases")
            .onAppear(perform: self.sendAnalytics)
        }
    }

    private func sendAnalytics() {
        FirebaseAnalytics.Analytics.logEvent("PhasesCard_viewed", parameters: [
            "contentShown": self.cardService.generalViewModel != nil && self.cardService.phasesViewModel != nil,
        ])
    }
}

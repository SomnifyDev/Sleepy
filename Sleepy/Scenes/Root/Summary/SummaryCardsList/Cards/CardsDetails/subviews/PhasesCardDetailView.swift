// Copyright (c) 2021 Sleepy.

import FirebaseAnalytics
import HKCoreSleep
import HKStatistics
import HKVisualKit
import SwiftUI
import XUI

struct PhasesCardDetailView: View {
    @Store var viewModel: CardDetailsViewCoordinator
    @EnvironmentObject var cardService: CardService
    @State private var showAdvice = false
    @State private var activeSheet: AdviceType!

    var body: some View {
        GeometryReader { _ in
            ZStack {
                viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.appBackgroundColor))
                    .edgesIgnoringSafeArea(.all)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .center) {
                        if let phasesViewModel = cardService.phasesViewModel,
                           let generalViewModel = cardService.generalViewModel
                        {
                            // MARK: Chart

                            StandardChartView(
                                colorProvider: viewModel.colorProvider,
                                chartType: .phasesChart,
                                chartHeight: 75,
                                points: phasesViewModel.phasesData,
                                dateInterval: generalViewModel.sleepInterval
                            )
                                .roundedCardBackground(
                                    color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor))
                                )
                                .padding(.top)

                            // MARK: Statistics

                            SectionNameTextView(
                                text: "Summary",
                                color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText))
                            )

                            HorizontalStatisticCellView(
                                data: [
                                    StatisticsCellData(
                                        title: "Total NREM sleep duration",
                                        value: phasesViewModel.timeInDeepPhase
                                    ),
                                    StatisticsCellData(
                                        title: "Max NREM sleep interval",
                                        value: phasesViewModel.mostIntervalInDeepPhase
                                    ),
                                    StatisticsCellData(
                                        title: "Total REM sleep duration",
                                        value: phasesViewModel.timeInLightPhase
                                    ),
                                    StatisticsCellData(
                                        title: "Max REM sleep interval",
                                        value: phasesViewModel.mostIntervalInLightPhase
                                    ),
                                ],
                                colorScheme: viewModel.colorProvider.sleepyColorScheme
                            )
                        }

                        // MARK: Advice

                        SectionNameTextView(
                            text: "What else?",
                            color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText))
                        )

                        UsefulInfoCardView(
                            imageName: AdviceType.phasesAdvice.rawValue,
                            title: "Sleep phases and stages",
                            description: "Learn more about sleep phases and stages.",
                            destinationView: AdviceView(
                                sheetType: .phasesAdvice,
                                showAdvice: $showAdvice
                            ),
                            showModalView: $showAdvice
                        )
                            .usefulInfoCardBackground(
                                color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor))
                            )
                    }
                }
                .navigationTitle("Sleep phases")
                .onAppear(perform: self.sendAnalytics)
            }
        }
    }

    private func sendAnalytics() {
        FirebaseAnalytics.Analytics.logEvent("PhasesCard_viewed", parameters: [
            "contentShown": self.cardService.generalViewModel != nil && self.cardService.phasesViewModel != nil,
        ])
    }
}

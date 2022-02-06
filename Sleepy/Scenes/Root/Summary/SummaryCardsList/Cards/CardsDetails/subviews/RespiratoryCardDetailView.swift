// Copyright (c) 2022 Sleepy.

import FirebaseAnalytics
import HKCoreSleep
import HKStatistics
import SwiftUI
import UIComponents
import XUI

struct RespiratoryCardDetailView: View {
    @Store var viewModel: CardDetailsViewCoordinator
    @EnvironmentObject var cardService: CardService

    var body: some View {
        ZStack {
            ColorsRepository.General.appBackground
                .edgesIgnoringSafeArea(.all)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .center) {
                    if let respiratoryViewModel = cardService.respiratoryViewModel,
                       let generalViewModel = cardService.generalViewModel
                    {
                        // MARK: Chart

                        StandardChartView(
                            chartType: .defaultChart(barType: .rectangular(color: Color(.systemBlue)), stringFormatter: "%.0f, BrPM"),
                            points: respiratoryViewModel.respiratoryRateData,
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
                                        title: "Max. respiratory rate",
                                        value: respiratoryViewModel.maxRespiratoryRate
                                    ),
                                    StatisticsCellViewModel(
                                        title: "Mean. respiratory rate",
                                        value: respiratoryViewModel.averageRespiratoryRate
                                    ),
                                    StatisticsCellViewModel(
                                        title: "Min. respiratory rate",
                                        value: respiratoryViewModel.minRespiratoryRate
                                    ),
                                ]
                            )
                        )
                    }
                }
            }
            .navigationTitle("Respiratory rate")
        }
    }

    // MARK: Private methods

    private func sendAnalytics() {
        FirebaseAnalytics.Analytics.logEvent("RespiratoryCard_viewed", parameters: [
            "contentShown": self.cardService.generalViewModel != nil && self.cardService.respiratoryViewModel != nil,
        ])
    }
}

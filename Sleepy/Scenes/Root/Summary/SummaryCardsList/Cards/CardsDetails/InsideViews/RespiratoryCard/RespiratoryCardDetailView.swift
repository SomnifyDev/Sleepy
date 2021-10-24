import FirebaseAnalytics
import HKCoreSleep
import HKStatistics
import HKVisualKit
import SwiftUI
import XUI

struct RespiratoryCardDetailView: View {

    @Store var viewModel: CardDetailsViewCoordinator
    @EnvironmentObject var cardService: CardService

    var body: some View {
        GeometryReader { _ in
            ZStack {
                viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.appBackgroundColor))
                    .edgesIgnoringSafeArea(.all)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .center) {
                        if let respiratoryViewModel = cardService.respiratoryViewModel,
                           let generalViewModel = cardService.generalViewModel {

                            // MARK: Chart
                            StandardChartView(
                                colorProvider: viewModel.colorProvider,
                                chartType: .defaultChart(
                                    barType: .rectangle(
                                        color: Color(.systemBlue)
                                    )
                                ),
                                chartHeight: 75,
                                points: respiratoryViewModel.respiratoryRateData,
                                dateInterval: generalViewModel.sleepInterval
                            )
                                .roundedCardBackground(
                                    color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor))
                                )
                                .padding(.top)

                            // MARK: Statistics

                            SectionNameTextView(
                                text: "Summary".localized,
                                color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText))
                            )

                            HorizontalStatisticCellView(
                                data: [
                                    StatisticsCellData(
                                        title: "Max. respiratory rate".localized,
                                        value: respiratoryViewModel.maxRespiratoryRate
                                    ),
                                    StatisticsCellData(
                                        title: "Mean. respiratory rate".localized,
                                        value: respiratoryViewModel.averageRespiratoryRate
                                    ),
                                    StatisticsCellData(
                                        title: "Min. respiratory rate".localized,
                                        value: respiratoryViewModel.minRespiratoryRate
                                    ),
                                ],
                                colorScheme: viewModel.colorProvider.sleepyColorScheme)
                        }
                    }
                }
                .navigationTitle("Respiratory rate".localized)
            }
        }
    }

    // MARK: Private methods

    private func sendAnalytics() {
        FirebaseAnalytics.Analytics.logEvent("RespiratoryCard_viewed", parameters: [
            "contentShown": cardService.generalViewModel != nil && cardService.respiratoryViewModel != nil,
        ])
    }
}

import SwiftUI
import HKStatistics
import HKVisualKit
import HKCoreSleep
import XUI

struct HeartCardDetailView: View {

    @Store var viewModel: CardDetailsViewCoordinator
    @EnvironmentObject var cardService: CardService
    @State private var showAdvice = false
    @State private var activeSheet: AdviceType!

    var body: some View {
        GeometryReader { geometry in
            ZStack {

                viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.appBackgroundColor))
                    .edgesIgnoringSafeArea(.all)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .center) {

                        if let heartViewModel = cardService.heartViewModel,
                           let generalViewModel = cardService.generalViewModel {
                            StandardChartView(colorProvider: viewModel.colorProvider,
                                              chartType: .defaultChart,
                                              chartHeight: 75,
                                              points: heartViewModel.heartRateData,
                                              chartColor: viewModel.colorProvider.sleepyColorScheme.getColor(of: .heart(.heartColor)),
                                              dateInterval: generalViewModel.sleepInterval)
                                .roundedCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
                                .padding(.top)

                            SectionNameTextView(text: "Summary".localized,
                                             color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))

                            HorizontalStatisticCellView(data: [
                                StatisticsCellData(title: "Average pulse".localized, value: heartViewModel.averageHeartRate),
                                StatisticsCellData(title: "Max pulse".localized, value: heartViewModel.maxHeartRate),
                                StatisticsCellData(title: "Min pulse".localized, value: heartViewModel.minHeartRate)
                            ],
                                                        colorScheme: viewModel.colorProvider.sleepyColorScheme)
                        }

                        SectionNameTextView(text: "What else?".localized,
                                         color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))

                        UsefulInfoCardView(
                            imageName: AdviceType.heartAdvice.rawValue,
                            title: "Heart and sleep".localized,
                            description: "Learn more about the importance of sleep for heart health.".localized,
                            destinationView: AdviceView(sheetType: .heartAdvice, showAdvice: $showAdvice),
                            showModalView: $showAdvice
                        )
                            .usefulInfoCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))

                    }
                }
                .navigationTitle("Heart")
            }
        }
    }

}

import SwiftUI
import XUI
import HKVisualKit

struct SummaryCardsListView: View {

    @Store var viewModel: SummaryCardsListCoordinator

    @EnvironmentObject var cardService: CardService
    @State private var generalViewModel: SummaryGeneralDataViewModel?
    @State private var phasesViewModel: SummaryPhasesDataViewModel?
    @State private var heartViewModel: SummaryHeartDataViewModel?
    @State private var somethingBroken = false
    

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.appBackgroundColor))
                    .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(alignment: .center) {

                        if somethingBroken {
                            BannerView(bannerViewType: .advice(type: .wearMore, imageSystemName: "wearAdvice"),
                                      colorProvider: viewModel.colorProvider)
                                .roundedCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
                        }

                        if let generalViewModel = cardService.generalViewModel {
                            CardNameTextView(text: "Sleep information".localized,
                                             color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))
                                .padding(.top)

                            GeneralSleepInfoCardView(viewModel: generalViewModel,
                                                colorProvider: viewModel.colorProvider)
                                .roundedCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
                                .onNavigation {
                                    viewModel.open(.general)
                                }
                                .buttonStyle(PlainButtonStyle())
                        } else {

                            BannerView(bannerViewType: .brokenData(type: .sleep),
                                      colorProvider: viewModel.colorProvider)
                                .roundedCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
                        }

                        CardNameTextView(text: "Sleep session".localized,
                                         color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))

                        if let phasesViewModel = cardService.phasesViewModel,
                           let generalViewModel = cardService.generalViewModel {

                            CardWithChartView(colorProvider: viewModel.colorProvider,
                                              systemImageName: "sleep",
                                              titleText: "Phases".localized,
                                              mainTitleText: "Here is some info about phases of your last sleep".localized,
                                              titleColor: viewModel.colorProvider.sleepyColorScheme.getColor(of: .phases(.deepSleepColor)),
                                              showChevron: true,
                                              chartView: StandardChartView(colorProvider: viewModel.colorProvider,
                                                                           chartType: .phasesChart,
                                                                           chartHeight: 75,
                                                                           points: phasesViewModel.phasesData,
                                                                           chartColor: nil,
                                                                           dateInterval: generalViewModel.sleepInterval),
                                              bottomView: CardBottomSimpleDescriptionView(descriptionText:
                                                                                            Text(String(format: "Duration of light phase was %@, while the duration of deep sleep was %@".localized, phasesViewModel.timeInLightPhase, phasesViewModel.timeInDeepPhase)), colorProvider: viewModel.colorProvider))
                                .roundedCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
                                .onNavigation {
                                    viewModel.open(.phases)
                                }
                                .buttonStyle(PlainButtonStyle())
                        } else {

                            BannerView(bannerViewType: .emptyData(type: .sleep),
                                      colorProvider: viewModel.colorProvider)
                                .roundedCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))

                            CardWithChartView<StandardChartView, EmptyView>(colorProvider: viewModel.colorProvider,
                                                                            color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .phases(.deepSleepColor)),
                                                                            chartType: .phasesChart)
                                .roundedCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
                                .blur(radius: 4)
                        }

                        CardNameTextView(text: "Heart rate".localized,
                                         color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))

                        if let heartViewModel = cardService.heartViewModel,
                           let generalViewModel = cardService.generalViewModel {
                            
                            CardWithChartView(colorProvider: viewModel.colorProvider,
                                              systemImageName: "suit.heart.fill",
                                              titleText: "Heart".localized,
                                              mainTitleText: "Here is some info about heart rate of your last sleep".localized,
                                              titleColor: viewModel.colorProvider.sleepyColorScheme.getColor(of: .heart(.heartColor)),
                                              showChevron: true,
                                              chartView: CirclesChartView(colorProvider: viewModel.colorProvider,
                                                                          points: heartViewModel.heartRateData,
                                                                          chartColor: viewModel.colorProvider.sleepyColorScheme.getColor(of: .heart(.heartColor)),
                                                                          chartHeight: 100,
                                                                          dateInterval: generalViewModel.sleepInterval),
                                              bottomView: CardBottomSimpleDescriptionView(descriptionText:
                                                                                            Text(String(format: "The maximal heartbeat was %@ bpm while the minimal was %@".localized, heartViewModel.minHeartRate, heartViewModel.maxHeartRate)), colorProvider: viewModel.colorProvider))
                                .roundedCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
                                .onNavigation {
                                    viewModel.open(.heart)
                                }
                                .buttonStyle(PlainButtonStyle())
                        } else {

                            BannerView(bannerViewType: .emptyData(type: .heart),
                                      colorProvider: viewModel.colorProvider)
                                .roundedCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))

                            CardWithChartView<StandardChartView, EmptyView>(colorProvider: viewModel.colorProvider,
                                                                            color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .heart(.heartColor)),
                                                                            chartType: .defaultChart)
                                .roundedCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
                                .blur(radius: 4)
                        }
                    }
                }
            }
        }
        .navigationTitle("\("Summary".localized), \(Date().getFormattedDate(format: "MMM d"))")
    }
}
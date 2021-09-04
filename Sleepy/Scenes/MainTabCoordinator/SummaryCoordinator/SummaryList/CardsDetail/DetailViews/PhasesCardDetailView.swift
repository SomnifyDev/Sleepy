import SwiftUI
import HKStatistics
import HKVisualKit
import HKCoreSleep
import XUI

struct PhasesCardDetailView: View {

    @Store var viewModel: CardDetailViewCoordinator

    @State private var generalViewModel: SummaryGeneralDataViewModel?
    @State private var phasesViewModel: SummaryPhasesDataViewModel?

    var body: some View {
        GeometryReader { geometry in
            ZStack {

                viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.appBackgroundColor))
                    .edgesIgnoringSafeArea(.all)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .center) {

                        if let phasesViewModel = phasesViewModel,
                           let generalViewModel = generalViewModel {
                            StandardChartView(colorProvider: viewModel.colorProvider,
                                              chartType: .phasesChart,
                                              chartHeight: 75,
                                              points: phasesViewModel.phasesData,
                                              chartColor: viewModel.colorProvider.sleepyColorScheme.getColor(of: .heart(.heartColor)),
                                              dateInterval: generalViewModel.sleepInterval)
                                .roundedCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
                                .padding(.top)

                            CardNameTextView(text: "Summary".localized,
                                             color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))

                            HorizontalStatisticCellView(data: [StatisticsCellData(title: "Total NREM sleep duration".localized, value: phasesViewModel.timeInDeepPhase),
                                                               StatisticsCellData(title: "Max NREM sleep interval".localized, value: phasesViewModel.mostIntervalInDeepPhase),
                                                               StatisticsCellData(title: "Total REM sleep duration".localized, value: phasesViewModel.timeInLightPhase),
                                                               StatisticsCellData(title: "Max REM sleep interval".localized, value: phasesViewModel.mostIntervalInLightPhase)
                                                              ],
                                                        colorScheme: viewModel.colorProvider.sleepyColorScheme)
                        }

                        CardNameTextView(text: "What else?".localized,
                                         color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))

                        UsefulInfoCardView(imageName: "sleep3", title: "title", description: "description")
                            .usefulInfoCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
                    }
                }
                .navigationTitle("Sleep phases")
            }
        }
        .onAppear {
            getSleepData()
            getPhasesData()
        }
    }

    // MARK: Sleep data

    private func getSleepData() {
        let provider = viewModel.statisticsProvider
        guard let sleepDuration = provider.getTodaySleepIntervalBoundary(boundary: .asleep),
              let inBedDuration = provider.getTodaySleepIntervalBoundary(boundary: .inbed),
              let goal = provider.getTodayFallingAsleepDuration() else { return }

        generalViewModel = SummaryGeneralDataViewModel(sleepInterval: sleepDuration,
                                                       inbedInterval: inBedDuration,
                                                       sleepGoal: goal)
    }

    // MARK: Phases data

    private func getPhasesData() {
        let provider = viewModel.statisticsProvider
        guard
            let deepSleepMinutes = provider.getData(for: .deepPhaseTime) as? Int,
            let lightSleepMinutes = provider.getData(for: .lightPhaseTime) as? Int,
            let phasesData = provider.getData(for: .phasesData) as? [Double],
            let mostIntervalInDeepPhase = provider.getData(for: .mostIntervalInDeepPhase) as? Int,
            let mostIntervalInLightPhase = provider.getData(for: .mostIntervalInLightPhase) as? Int
        else {
            return
        }

        if !phasesData.isEmpty {
            phasesViewModel = SummaryPhasesDataViewModel(phasesData: phasesData,
                                                         timeInLightPhase: "\(lightSleepMinutes / 60)h \(lightSleepMinutes - (lightSleepMinutes / 60) * 60)min",
                                                         timeInDeepPhase: "\(deepSleepMinutes / 60)h \(deepSleepMinutes - (deepSleepMinutes / 60) * 60)min",
                                                         mostIntervalInLightPhase: "\(mostIntervalInLightPhase / 60)h \(mostIntervalInLightPhase - (mostIntervalInLightPhase / 60) * 60)min",
                                                         mostIntervalInDeepPhase: "\(mostIntervalInDeepPhase / 60)h \(mostIntervalInDeepPhase - (mostIntervalInDeepPhase / 60) * 60)min")
        }
    }

}

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
                                              startTime: generalViewModel.sleepStart,
                                              endTime: generalViewModel.sleepEnd)
                                .roundedCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
                                .padding(.top)

                            CardNameTextView(text: "Info",
                                             color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))

                            HorizontalStatisticCellView(data: [StatisticsCellData(title: "Total NREM sleep duration", value: phasesViewModel.timeInDeepPhase),
                                                               StatisticsCellData(title: "Max NREM sleep interval", value: phasesViewModel.mostIntervalInDeepPhase),
                                                               StatisticsCellData(title: "Total REM sleep duration", value: phasesViewModel.timeInLightPhase),
                                                               StatisticsCellData(title: "Max REM sleep interval", value: phasesViewModel.mostIntervalInLightPhase)],
                                                        colorScheme: viewModel.colorProvider.sleepyColorScheme)
                        }

                        CardNameTextView(text: "What else?",
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
        let sleepDuration = provider.getData(for: .asleep)
        let inBedDuration = provider.getData(for: .inBed)

        generalViewModel = SummaryGeneralDataViewModel(sleepStart: provider.getTodaySleepIntervalBoundary(boundary: .start),
                                                       sleepEnd: provider.getTodaySleepIntervalBoundary(boundary: .end),
                                                       sleepDuration: "\(sleepDuration / 60)h \(sleepDuration - (sleepDuration / 60) * 60)min",
                                                       inBedDuration: "\(inBedDuration / 60)h \(inBedDuration - (inBedDuration / 60) * 60)min",
                                                       fallAsleepDuration: provider.getTodayFallingAsleepDuration())
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

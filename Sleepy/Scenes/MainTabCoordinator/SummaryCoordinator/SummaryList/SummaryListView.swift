import SwiftUI
import XUI
import HKVisualKit

struct SummaryListView: View {

    // MARK: Stored Propertie

    @Store var viewModel: SummaryListCoordinator

    // MARK: State Properties

    @State private var generalViewModel: SummaryGeneralDataModelView?
    @State private var phasesViewModel: SummaryPhasesDataModelView?
    @State private var heartViewModel: SummaryHeartDataModelView?

    @State private var showGeneralCard: Bool = false
    @State private var showPhasesCard: Bool = false
    @State private var showHeartCard: Bool = false

    // MARK: View

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.appBackgroundColor))
                    .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(alignment: .center) {

                        if let generalViewModel = generalViewModel,
                           showGeneralCard {
                            CardNameTextView(text: "Sleep information",
                                             color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))
                                .padding(.top)

                            SummaryInfoCardView(colorProvider: viewModel.colorProvider,
                                                sleepStartTime: generalViewModel.sleepStart,
                                                sleepDuration: generalViewModel.sleepDuration,
                                                awakeTime: generalViewModel.sleepEnd,
                                                fallingAsleepDuration: generalViewModel.fallAsleepDuration)
                                .roundedCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
                                .onNavigation {
                                    viewModel.open(.general)
                                }
                        }

                        if let phasesViewModel = phasesViewModel,
                           let generalViewModel = generalViewModel,
                           showPhasesCard {
                            CardNameTextView(text: "Sleep session",
                                             color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))

                            CardWithChartView(colorProvider: viewModel.colorProvider,
                                              systemImageName: "sleep",
                                              titleText: "Sleep: phases",
                                              mainTitleText: "Here is the info about phases of your last sleep.",
                                              titleColor: viewModel.colorProvider.sleepyColorScheme.getColor(of: .phases(.deepSleepColor)),
                                              showChevron: true,
                                              chartView: StandardChartView(colorProvider: viewModel.colorProvider,
                                                                           chartType: .phasesChart,
                                                                           chartHeight: 75,
                                                                           points: phasesViewModel.phasesData,
                                                                           dragGestureData: "",
                                                                           chartColor: nil,
                                                                           needOXLine: true,
                                                                           needTimeLine: true,
                                                                           startTime: generalViewModel.sleepStart,
                                                                           endTime: generalViewModel.sleepEnd,
                                                                           needDragGesture: false),
                                              bottomView: CardBottomSimpleDescriptionView(descriptionText:
                                                                                            Text("The duration of light phase was ")
                                                                                          + Text(phasesViewModel.timeInLightPhase)
                                                                                            .foregroundColor(viewModel.colorProvider.sleepyColorScheme.getColor(of: .phases(.lightSleepColor)))
                                                                                            .bold()
                                                                                          + Text(", while the duration of deep phase was ")
                                                                                          + Text(phasesViewModel.timeInDeepPhase)
                                                                                            .foregroundColor(viewModel.colorProvider.sleepyColorScheme.getColor(of: .phases(.deepSleepColor)))
                                                                                            .bold()
                                                                                          + Text("."), colorProvider: viewModel.colorProvider))
                                .roundedCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
                                .onNavigation {
                                    viewModel.open(.phases)
                                }
                        }

                        if let heartViewModel = heartViewModel,
                           let generalViewModel = generalViewModel,
                           showHeartCard {
                            CardNameTextView(text: "Heart rate",
                                             color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))
                            
                            CardWithChartView(colorProvider: viewModel.colorProvider,
                                              systemImageName: "suit.heart.fill",
                                              titleText: "Sleep: heart rate",
                                              mainTitleText: "Here is the info about heart rate of your last sleep.",
                                              titleColor: viewModel.colorProvider.sleepyColorScheme.getColor(of: .heart(.heartColor)),
                                              showChevron: true,
                                              chartView: CirclesChartView(colorProvider: viewModel.colorProvider,
                                                                          points: heartViewModel.heartRateData,
                                                                          dragGestureData: nil,
                                                                          chartColor: viewModel.colorProvider.sleepyColorScheme.getColor(of: .heart(.heartColor)),
                                                                          chartHeight: 100,
                                                                          needOXLine: true,
                                                                          needTimeLine: true,
                                                                          startTime: generalViewModel.sleepStart,
                                                                          endTime: generalViewModel.sleepEnd),
                                              bottomView: CardBottomSimpleDescriptionView(descriptionText:
                                                                                            Text("The maximal heartbeat was ")
                                                                                          + Text(heartViewModel.maxHeartRate)
                                                                                            .foregroundColor(viewModel.colorProvider.sleepyColorScheme.getColor(of: .heart(.heartColor)))
                                                                                            .bold()
                                                                                          + Text(", while the minimal was ")
                                                                                          + Text(heartViewModel.minHeartRate)
                                                                                            .foregroundColor(viewModel.colorProvider.sleepyColorScheme.getColor(of: .heart(.heartColor)))
                                                                                            .bold()
                                                                                          + Text("."), colorProvider: viewModel.colorProvider))
                                .roundedCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
                                .onNavigation {
                                    viewModel.open(.heart)
                                }
                        }
                    }
                }
            }
        }
        .navigationTitle("Summary, \(Date().getFormattedDate(format: "MMM d"))")
        .onAppear {
            getSleepData()
            getPhasesData()
            getHeartData()
        }
    }

    // MARK: Sleep data

    private func getSleepData() {
        let provider = viewModel.statisticsProvider
        generalViewModel = SummaryGeneralDataModelView(sleepStart: provider.getTodaySleepIntervalBoundary(boundary: .start),
                                                       sleepEnd: provider.getTodaySleepIntervalBoundary(boundary: .end),
                                                       sleepDuration: provider.getTodaySleepDuration(),
                                                       fallAsleepDuration: provider.getTodayFallingAsleepDuration())
        showGeneralCard = true
    }

    // MARK: Phases data

    private func getPhasesData() {
        let provider = viewModel.statisticsProvider
        guard
            let deepSleepMinutes = viewModel.statisticsProvider.getData(for: .deepPhaseTime) as? Int,
            let lightSleepMinutes = viewModel.statisticsProvider.getData(for: .lightPhaseTime) as? Int,
            let phasesData = provider.getData(for: .phasesData) as? [Double]
        else {
            return
        }

        if !phasesData.isEmpty {
            phasesViewModel = SummaryPhasesDataModelView(phasesData: phasesData,
                                                         timeInLightPhase: "\(lightSleepMinutes / 60)h \(lightSleepMinutes - (lightSleepMinutes / 60) * 60)min",
                                                         timeInDeepPhase: "\(deepSleepMinutes / 60)h \(deepSleepMinutes - (deepSleepMinutes / 60) * 60)min")
            showPhasesCard = true
        }
    }

    // MARK: Heart data

    private func getHeartData() {
        let provider = viewModel.statisticsProvider
        var minHeartRate = "-", maxHeartRate = "-"
        let heartRateData = getShortHeartRateData(heartRateData: provider.getTodayData(of: .heart))

        if !heartRateData.isEmpty,
           let maxHR = provider.getData(dataType: .heart, indicatorType: .max),
           let minHR = provider.getData(dataType: .heart, indicatorType: .min) {
            maxHeartRate = "\(Int(maxHR)) bpm"
            minHeartRate = "\(Int(minHR)) bpm"
            heartViewModel = SummaryHeartDataModelView(heartRateData: heartRateData, maxHeartRate: maxHeartRate, minHeartRate: minHeartRate)
            showHeartCard = true
        }
    }

    private func getShortHeartRateData(heartRateData: [Double]) -> [Double] {
        guard
            heartRateData.count > 25
        else {
            return heartRateData
        }

        let stackCapacity = heartRateData.count / 25
        var shortData: [Double] = []

        for index in stride(from: 0, to: heartRateData.count, by: stackCapacity) {
            var mean: Double = 0.0
            for stackIndex in index..<index+stackCapacity {
                guard stackIndex < heartRateData.count else { return shortData }
                mean += heartRateData[stackIndex]
            }
            shortData.append(mean / Double(stackCapacity))
        }

        return shortData
    }

}

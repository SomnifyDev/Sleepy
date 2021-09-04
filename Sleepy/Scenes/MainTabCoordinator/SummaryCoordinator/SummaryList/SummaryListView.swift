import SwiftUI
import XUI
import HKVisualKit

struct SummaryListView: View {

    // MARK: Stored Propertie

    @Store var viewModel: SummaryListCoordinator

    // MARK: State Properties

    @State private var generalViewModel: SummaryGeneralDataViewModel?
    @State private var phasesViewModel: SummaryPhasesDataViewModel?
    @State private var heartViewModel: SummaryHeartDataViewModel?
    @State private var somethingBroken = false
    // MARK: View

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.appBackgroundColor))
                    .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(alignment: .center) {

                        if somethingBroken {
                            ErrorView(errorType: .advice(type: .wearMore, imageSystemName: "wearAdvice"),
                                      colorProvider: viewModel.colorProvider)
                                .roundedCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
                        }

                        if let generalViewModel = generalViewModel {
                            CardNameTextView(text: "Sleep information".localized,
                                             color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))
                                .padding(.top)

                            SummaryInfoCardView(viewModel: generalViewModel,
                                colorProvider: viewModel.colorProvider)
                                .roundedCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
                                .onNavigation {
                                    viewModel.open(.general)
                                }
                                .buttonStyle(PlainButtonStyle())
                        } else {

                            ErrorView(errorType: .brokenData(type: .sleep),
                                      colorProvider: viewModel.colorProvider)
                                .roundedCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
                        }

                        CardNameTextView(text: "Sleep session".localized,
                                         color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))

                        if let phasesViewModel = phasesViewModel,
                           let generalViewModel = generalViewModel {

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

                            ErrorView(errorType: .emptyData(type: .sleep),
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

                        if let heartViewModel = heartViewModel,
                           let generalViewModel = generalViewModel {
                            
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

                            ErrorView(errorType: .emptyData(type: .heart),
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
        .onAppear {
            getSleepData()
            getPhasesData()
            getHeartData()
        }
    }

    // MARK: Sleep data

    private func getSleepData() {
        let provider = viewModel.statisticsProvider
        guard let sleepInterval = provider.getTodaySleepIntervalBoundary(boundary: .asleep),
              let inBedInterval = provider.getTodaySleepIntervalBoundary(boundary: .inbed) else { return }

        self.generalViewModel = SummaryGeneralDataViewModel(sleepInterval: sleepInterval,
                                                            inbedInterval: inBedInterval,
                                                            sleepGoal: UserDefaults.standard.getInt(forKey: .sleepGoal) ?? 480)
    }

    // MARK: Phases data

    private func getPhasesData() {
        let provider = viewModel.statisticsProvider
        guard
            let deepSleepMinutes = provider.getData(for: .deepPhaseTime) as? Int,
            let lightSleepMinutes = provider.getData(for: .lightPhaseTime) as? Int,
            let phasesData = provider.getData(for: .phasesData) as? [Double]
        else {
            return
        }

        if !phasesData.isEmpty {
            self.phasesViewModel = SummaryPhasesDataViewModel(phasesData: phasesData,
                                                         timeInLightPhase: "\(lightSleepMinutes / 60)h \(lightSleepMinutes - (lightSleepMinutes / 60) * 60)min",
                                                         timeInDeepPhase: "\(deepSleepMinutes / 60)h \(deepSleepMinutes - (deepSleepMinutes / 60) * 60)min",
                                                         mostIntervalInLightPhase: "-",
                                                         mostIntervalInDeepPhase: "-")
        } else {
            self.somethingBroken = true
        }
    }

    // MARK: Heart data

    private func getHeartData() {
        let provider = viewModel.statisticsProvider
        var minHeartRate = "-", maxHeartRate = "-", averageHeartRate = "-"
        let heartRateData = getShortHeartRateData(heartRateData: provider.getTodayData(of: .heart))

        if !heartRateData.isEmpty,
           let maxHR = provider.getData(dataType: .heart, indicatorType: .max),
           let minHR = provider.getData(dataType: .heart, indicatorType: .min),
           let averageHR = provider.getData(dataType: .heart, indicatorType: .mean) {
            maxHeartRate = "\(Int(maxHR)) bpm"
            minHeartRate = "\(Int(minHR)) bpm"
            averageHeartRate = "\(Int(averageHR)) bpm"
            
            self.heartViewModel = SummaryHeartDataViewModel(heartRateData: heartRateData,
                                                       maxHeartRate: maxHeartRate,
                                                       minHeartRate: minHeartRate,
                                                       averageHeartRate: averageHeartRate)
        } else {
            self.somethingBroken = true
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

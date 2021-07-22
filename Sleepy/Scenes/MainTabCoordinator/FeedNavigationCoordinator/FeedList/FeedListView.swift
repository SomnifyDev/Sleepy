import SwiftUI
import XUI
import HKVisualKit

struct FeedListView: View {

    // MARK: Stored Properties

    @Store var viewModel: FeedListCoordinator

    // MARK: State Properties

    @State private var sleepStart: String = ""
    @State private var sleepEnd: String = ""
    @State private var sleepDuration: String = ""
    @State private var fallAsleepDuration: String = ""

    @State private var heartRateData: [Double] = []
    @State private var maxHeartRate: String = ""
    @State private var minHeartRate: String = ""

    @State private var phasesData: [Double] = []
    @State private var timeInLightPhase: String = ""
    @State private var timeInDeepPhase: String = ""

    @State private var showHeartCard: Bool = false
    @State private var showPhasesCard: Bool = false

    // MARK: Views

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.appBackgroundColor))
                    .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(alignment: .center) {
                        CardNameTextView(text: "Sleep information",
                                         color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))
                            .padding(.top)

                        SummaryInfoCardView(colorProvider: viewModel.colorProvider,
                                            sleepStartTime: sleepStart,
                                            sleepDuration: sleepDuration,
                                            awakeTime: sleepEnd,
                                            fallingAsleepDuration: fallAsleepDuration)
                            .roundedCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
                            .onNavigation {
                                viewModel.open(.general)
                            }

                        if showPhasesCard {
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
                                                                           points: phasesData,
                                                                           dragGestureData: "",
                                                                           chartColor: nil,
                                                                           needOXLine: true,
                                                                           needTimeLine: true,
                                                                           startTime: sleepStart,
                                                                           endTime: sleepEnd,
                                                                           needDragGesture: false),
                                              bottomView: CardBottomSimpleDescriptionView(descriptionText:
                                                                                            Text("The duration of light phase was ")
                                                                                          + Text(timeInLightPhase)
                                                                                            .foregroundColor(viewModel.colorProvider.sleepyColorScheme.getColor(of: .phases(.lightSleepColor)))
                                                                                            .bold()
                                                                                          + Text(", while the duration of deep phase was ")
                                                                                          + Text(timeInDeepPhase)
                                                                                            .foregroundColor(viewModel.colorProvider.sleepyColorScheme.getColor(of: .phases(.deepSleepColor)))
                                                                                            .bold()
                                                                                          + Text("."), colorProvider: viewModel.colorProvider))
                                .roundedCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
                                .onNavigation {
                                    viewModel.open(.phases)
                                }
                        }

                        if showHeartCard {
                            CardNameTextView(text: "Heart rate",
                                             color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))
                            
                            CardWithChartView(colorProvider: viewModel.colorProvider,
                                              systemImageName: "suit.heart.fill",
                                              titleText: "Sleep: heart rate",
                                              mainTitleText: "Here is the info about heart rate of your last sleep.",
                                              titleColor: viewModel.colorProvider.sleepyColorScheme.getColor(of: .heart(.heartColor)),
                                              showChevron: true,
                                              chartView: CirclesChartView(colorProvider: viewModel.colorProvider,
                                                                          points: heartRateData,
                                                                          dragGestureData: nil,
                                                                          chartColor: viewModel.colorProvider.sleepyColorScheme.getColor(of: .heart(.heartColor)),
                                                                          chartHeight: 75,
                                                                          needOXLine: true,
                                                                          needTimeLine: true,
                                                                          startTime: sleepStart,
                                                                          endTime: sleepEnd),
                                              bottomView: CardBottomSimpleDescriptionView(descriptionText:
                                                                                            Text("The maximal heartbeat was ")
                                                                                          + Text(maxHeartRate)
                                                                                            .foregroundColor(viewModel.colorProvider.sleepyColorScheme.getColor(of: .heart(.heartColor)))
                                                                                            .bold()
                                                                                          + Text(", while the minimal was ")
                                                                                          + Text(minHeartRate)
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

    private func getHeartData() {
        let provider = viewModel.statisticsProvider
        heartRateData = getShortHeartRateData(heartRateData: provider.getTodayData(of: .heart))

        if let maxHR = provider.getData(dataType: .heart, indicatorType: .max),
           let minHR = provider.getData(dataType: .heart, indicatorType: .min) {
            maxHeartRate = "\(Int(maxHR)) bpm"
            minHeartRate = "\(Int(minHR)) bpm"
        } else {
            maxHeartRate = "-"
            minHeartRate = "-"
        }

        if !heartRateData.isEmpty {
            showHeartCard = true
            print(heartRateData)
        }
    }

    private func getPhasesData() {
        let provider = viewModel.statisticsProvider
        guard
            let deepSleepMinutes = viewModel.statisticsProvider.getData(for: .deepPhaseTime) as? Int,
            let lightSleepMinutes = viewModel.statisticsProvider.getData(for: .lightPhaseTime) as? Int,
            let phasesData = provider.getData(for: .phasesData) as? [Double]
        else {
            return
        }

        self.phasesData = phasesData
        self.timeInLightPhase = "\(lightSleepMinutes / 60)h \(lightSleepMinutes - (lightSleepMinutes / 60) * 60)min"
        self.timeInDeepPhase = "\(deepSleepMinutes / 60)h \(deepSleepMinutes - (deepSleepMinutes / 60) * 60)min"

        if !phasesData.isEmpty {
            showPhasesCard = true
        }
    }

    private func getSleepData() {
        let provider = viewModel.statisticsProvider
        sleepStart = provider.getTodaySleepIntervalBoundary(boundary: .start)
        sleepEnd = provider.getTodaySleepIntervalBoundary(boundary: .end)
        sleepDuration = provider.getTodaySleepDuration()
        fallAsleepDuration = provider.getTodayFallingAsleepDuration()
    }

    private func getShortHeartRateData(heartRateData: [Double]) -> [Double] {
        guard
            heartRateData.count > 27,
            let max = heartRateData.max(),
            let min = heartRateData.min()
        else {
            return heartRateData
        }

        let stackCapacity = heartRateData.count / 27
        var shortData: [Double] = []

        for index in stride(from: 0, to: heartRateData.count, by: stackCapacity) {
            for stackIndex in index..<index+stackCapacity {
                if stackIndex < heartRateData.count {
                    if !(heartRateData[stackIndex] == max) && !(heartRateData[stackIndex] == min) {
                        shortData.append(heartRateData[index])
                        break
                    }
                } else {
                    return shortData
                }
            }
        }

        return shortData
    }

}

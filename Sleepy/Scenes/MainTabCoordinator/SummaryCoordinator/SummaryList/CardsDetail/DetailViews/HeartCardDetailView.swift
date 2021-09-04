import SwiftUI
import HKStatistics
import HKVisualKit
import HKCoreSleep
import XUI

struct HeartCardDetailView: View {

    @Store var viewModel: CardDetailViewCoordinator

    @State private var heartViewModel: SummaryHeartDataViewModel?
    @State private var generalViewModel: SummaryGeneralDataViewModel?

    var body: some View {
        GeometryReader { geometry in
            ZStack {

                viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.appBackgroundColor))
                    .edgesIgnoringSafeArea(.all)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .center) {

                        if let heartViewModel = heartViewModel,
                           let generalViewModel = generalViewModel {
                            StandardChartView(colorProvider: viewModel.colorProvider,
                                              chartType: .defaultChart,
                                              chartHeight: 75,
                                              points: heartViewModel.heartRateData,
                                              chartColor: viewModel.colorProvider.sleepyColorScheme.getColor(of: .heart(.heartColor)),
                                              dateInterval: generalViewModel.sleepInterval)
                                .roundedCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
                                .padding(.top)

                            CardNameTextView(text: "Summary".localized,
                                             color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))

                            HorizontalStatisticCellView(data: [StatisticsCellData(title: "Average pulse".localized, value: heartViewModel.averageHeartRate),
                                                               StatisticsCellData(title: "Max pulse".localized, value: heartViewModel.maxHeartRate),
                                                               StatisticsCellData(title: "Min pulse".localized, value: heartViewModel.minHeartRate)],
                                                        colorScheme: viewModel.colorProvider.sleepyColorScheme)
                        }

                        CardNameTextView(text: "What else?".localized,
                                         color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))

                        UsefulInfoCardView(imageName: "heart1", title: "title", description: "description")
                            .usefulInfoCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
                    }
                }
                .navigationTitle("Heart")
            }
        }
        .onAppear {
            getHeartData()
            getSleepData()
        }
    }

    // MARK: Sleep data

    private func getSleepData() {
        let provider = viewModel.statisticsProvider
        guard let sleepInterval = provider.getTodaySleepIntervalBoundary(boundary: .asleep),
              let inBedDuration = provider.getTodaySleepIntervalBoundary(boundary: .inbed),
              let goal = provider.getTodayFallingAsleepDuration() else { return }

        generalViewModel = SummaryGeneralDataViewModel(sleepInterval: sleepInterval,
                                                       inbedInterval: inBedDuration,
                                                       sleepGoal: goal)
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
            heartViewModel = SummaryHeartDataViewModel(heartRateData: heartRateData, maxHeartRate: maxHeartRate, minHeartRate: minHeartRate, averageHeartRate: averageHeartRate)
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

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
                                              startTime: generalViewModel.sleepStart,
                                              endTime: generalViewModel.sleepEnd)
                                .roundedCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
                                .padding(.top)

                            CardNameTextView(text: "Info",
                                             color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))

                            HorizontalStatisticCellView(data: [StatisticsCellData(title: "Average pulse, bpm", value: heartViewModel.averageHeartRate),
                                                               StatisticsCellData(title: "Max pulse", value: heartViewModel.maxHeartRate),
                                                               StatisticsCellData(title: "Min pulse", value: heartViewModel.minHeartRate)],
                                                        colorScheme: viewModel.colorProvider.sleepyColorScheme)
                        }

                        CardNameTextView(text: "What else?",
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
        let sleepDuration = provider.getData(for: .asleep)
        let inBedDuration = provider.getData(for: .inBed)

        generalViewModel = SummaryGeneralDataViewModel(sleepStart: provider.getTodaySleepIntervalBoundary(boundary: .start),
                                                       sleepEnd: provider.getTodaySleepIntervalBoundary(boundary: .end),
                                                       sleepDuration: "\(sleepDuration / 60)h \(sleepDuration - (sleepDuration / 60) * 60)min",
                                                       inBedDuration: "\(inBedDuration / 60)h \(inBedDuration - (inBedDuration / 60) * 60)min",
                                                       fallAsleepDuration: provider.getTodayFallingAsleepDuration())
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

import Foundation
import SwiftUI
import HKStatistics
import SettingsKit

enum SummaryViewCardType: String {
    case heart
    case general
    case phases
}

enum AdvicesViewType: String {
    case sleepImportance
    case sleepImprovement
    case phasesAndStages
    case heartAndSleep
}

extension SummaryViewCardType: Identifiable {
    var id: Self { self }
}

class CardService: ObservableObject {

    var statisticsProvider: HKStatisticsProvider

    @Published var bankOfSleepViewModel: BankOfSleepDataViewModel?
    @Published var phasesViewModel: SummaryPhasesDataViewModel?
    @Published var generalViewModel: SummaryGeneralDataViewModel?
    @Published var heartViewModel: SummaryHeartDataViewModel?

    private let mainCard: SummaryViewCardType = .general
    private let phasesCard: SummaryViewCardType = .phases
    private let heartCard: SummaryViewCardType = .heart

    init(statisticsProvider: HKStatisticsProvider) {
        self.statisticsProvider = statisticsProvider

        self.getbankOfSleepInfo()
        self.getSleepData()
        self.getPhasesData()
        self.getHeartData()

    }

    func fetchCard(id: String, _ completion: @escaping (SummaryViewCardType?) -> Void) {
        fetchCards { cards in
            completion( cards.first )
        }
    }

    func fetchCards(_ completion: @escaping ([SummaryViewCardType]) -> Void) {
        completion(
            Mirror(reflecting: self)
                .children
                .compactMap { ($0.value as? SummaryViewCardType) }
        )
    }

    private func getbankOfSleepInfo() {
        guard
            let sleepGoal = statisticsProvider.getTodayFallingAsleepDuration(),
            let twoWeeksBackDate = Calendar.current.date(byAdding: .day, value: -14, to: Date())
        else {
            return
        }
        self.statisticsProvider.getDataByInterval(healthType: .asleep, for: DateInterval(start: twoWeeksBackDate, end: Date()), bundlePrefixes: ["com.sinapsis", "com.benmustafa"]) { data in
            if data.count == 14 {

                let bankOfSleepData = data.map({$0 / Double(sleepGoal)})

                let backlogValue = Int(data.reduce(0.0) { $1 < Double(sleepGoal) ? $0 + (Double(sleepGoal) - $1) : $0 + 0 })
                let backlogString = Date.minutesToClearString(minutes: backlogValue)

                let timeToCloseDebtValue = backlogValue / 14 + sleepGoal
                let timeToCloseDebtString = Date.minutesToClearString(minutes: timeToCloseDebtValue)

                self.bankOfSleepViewModel = BankOfSleepDataViewModel(bankOfSleepData: bankOfSleepData,
                                                                     backlog: backlogString,
                                                                     timeToCloseDebt: timeToCloseDebtString)
            }
        }
    }

    private func getSleepData() {
        guard let sleepInterval = statisticsProvider.getTodaySleepIntervalBoundary(boundary: .asleep),
              let inBedInterval = statisticsProvider.getTodaySleepIntervalBoundary(boundary: .inbed) else { return }

        self.generalViewModel = SummaryGeneralDataViewModel(sleepInterval: sleepInterval,
                                                            inbedInterval: inBedInterval,
                                                            sleepGoal: UserDefaults.standard.integer(forKey: SleepySettingsKeys.sleepGoal.rawValue))
    }

    private func getPhasesData() {
        guard
            let deepSleepMinutes = statisticsProvider.getData(for: .deepPhaseTime) as? Int,
            let lightSleepMinutes = statisticsProvider.getData(for: .lightPhaseTime) as? Int,
            let phasesData = statisticsProvider.getData(for: .phasesData) as? [Double]
        else {
            return
        }

        if !phasesData.isEmpty {
            self.phasesViewModel = SummaryPhasesDataViewModel(phasesData: phasesData,
                                                         timeInLightPhase: "\(lightSleepMinutes / 60)h \(lightSleepMinutes - (lightSleepMinutes / 60) * 60)min",
                                                         timeInDeepPhase: "\(deepSleepMinutes / 60)h \(deepSleepMinutes - (deepSleepMinutes / 60) * 60)min",
                                                         mostIntervalInLightPhase: "-",
                                                         mostIntervalInDeepPhase: "-")
        }
    }

    private func getHeartData() {
            var minHeartRate = "-", maxHeartRate = "-", averageHeartRate = "-"
            let heartRateData = getShortHeartRateData(heartRateData: statisticsProvider.getTodayData(of: .heart))

            if !heartRateData.isEmpty,
               let maxHR = statisticsProvider.getData(dataType: .heart, indicatorType: .max),
               let minHR = statisticsProvider.getData(dataType: .heart, indicatorType: .min),
               let averageHR = statisticsProvider.getData(dataType: .heart, indicatorType: .mean) {
                maxHeartRate = "\(Int(maxHR)) bpm"
                minHeartRate = "\(Int(minHR)) bpm"
                averageHeartRate = "\(Int(averageHR)) bpm"
                self.heartViewModel = SummaryHeartDataViewModel(heartRateData: heartRateData, maxHeartRate: maxHeartRate, minHeartRate: minHeartRate, averageHeartRate: averageHeartRate)
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

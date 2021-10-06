import Foundation
import HKStatistics
import SettingsKit
import SwiftUI

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
    @Published var respiratoryViewModel: SummaryRespiratoryDataViewModel?

    private let mainCard: SummaryViewCardType = .general
    private let phasesCard: SummaryViewCardType = .phases
    private let heartCard: SummaryViewCardType = .heart

    init(statisticsProvider: HKStatisticsProvider) {
        self.statisticsProvider = statisticsProvider

        getbankOfSleepInfo()
        getSleepData()
        getPhasesData()
        getHeartData()
        getRespiratoryData()
    }

    func fetchCard(id _: String, _ completion: @escaping (SummaryViewCardType?) -> Void) {
        fetchCards { cards in
            completion(cards.first)
        }
    }

    func fetchCards(_ completion: @escaping ([SummaryViewCardType]) -> Void) {
        completion(
            Mirror(reflecting: self)
                .children
                .compactMap { $0.value as? SummaryViewCardType }
        )
    }

    private func getbankOfSleepInfo() {
        guard
            let twoWeeksBackDate = Calendar.current.date(byAdding: .day, value: -14, to: Date())
        else {
            return
        }
        let sleepGoal = getSleepGoal()
        statisticsProvider.getDataByInterval(healthType: .asleep, for: DateInterval(start: twoWeeksBackDate, end: Date()), bundlePrefixes: ["com.sinapsis", "com.benmustafa"]) { data in
            if data.count == 14 {
                let bankOfSleepData = data.map { $0 / Double(sleepGoal) }

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

        generalViewModel = SummaryGeneralDataViewModel(sleepInterval: sleepInterval,
                                                       inbedInterval: inBedInterval,
                                                       sleepGoal: getSleepGoal())
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
            phasesViewModel = SummaryPhasesDataViewModel(phasesData: phasesData,
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
           let averageHR = statisticsProvider.getData(dataType: .heart, indicatorType: .mean)
        {
            maxHeartRate = String(format: "%u bpm".localized, Int(maxHR))
            minHeartRate = String(format: "%u bpm".localized, Int(minHR))
            averageHeartRate = String(format: "%u bpm".localized, Int(averageHR))
            heartViewModel = SummaryHeartDataViewModel(heartRateData: heartRateData, maxHeartRate: maxHeartRate, minHeartRate: minHeartRate, averageHeartRate: averageHeartRate)
        }
    }

    private func getRespiratoryData() {
        var minRespiratoryRate = "-", maxRespiratoryRate = "-", averageRespiratoryRate = "-"
        let breatheRateData = statisticsProvider.getTodayData(of: .respiratory)

        if !breatheRateData.isEmpty,
           let maxRespiratory = statisticsProvider.getData(dataType: .respiratory, indicatorType: .max),
           let minRespiratory = statisticsProvider.getData(dataType: .respiratory, indicatorType: .min),
           let averageRespiratory = statisticsProvider.getData(dataType: .respiratory, indicatorType: .mean)
        {
            maxRespiratoryRate = String(format: "%u count/min".localized, Int(maxRespiratory))
            minRespiratoryRate = String(format: "%u count/min".localized, Int(minRespiratory))
            averageRespiratoryRate = String(format: "%u count/min".localized, Int(averageRespiratory))
            respiratoryViewModel = SummaryRespiratoryDataViewModel(respiratoryRateData: breatheRateData, maxRespiratoryRate: maxRespiratoryRate, minRespiratoryRate: minRespiratoryRate, averageRespiratoryRate: averageRespiratoryRate)
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
            for stackIndex in index ..< index + stackCapacity {
                guard stackIndex < heartRateData.count else { return shortData }
                mean += heartRateData[stackIndex]
            }
            shortData.append(mean / Double(stackCapacity))
        }

        return shortData
    }

    private func getSleepGoal() -> Int {
        return UserDefaults.standard.integer(forKey: SleepySettingsKeys.sleepGoal.rawValue)
    }
}

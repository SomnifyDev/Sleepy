import Foundation
import HealthKit
import HKCoreSleep

final class HKDailyStatisticsProvider {

    // MARK: - Properties

    private let generalStatisticsProvider: HKGeneralStatisticsProvider = HKGeneralStatisticsProvider()

    // MARK: - Methods

    func data(healthtype: HKService.HealthType, sleep: Sleep) -> [Double] {
        switch healthtype {
        case .energy:
            return generalStatisticsProvider.data(healthType: .energy, data: sleep.phases?.flatMap { $0.energyData } ?? [])
        case .heart:
            return generalStatisticsProvider.data(healthType: .heart, data: sleep.phases?.flatMap { $0.heartData } ?? [])
        case .respiratory:
            return generalStatisticsProvider.data(healthType: .respiratory, data: sleep.phases?.flatMap { $0.breathData } ?? [])
        case .asleep, .inbed:
            assertionFailure("Do not use this method for that. You can get inbed asleep stat from date intervals in Sleep object")
        }
        return []
    }

    func intervalBoundary(intervalType: SleepInterval, sleep: Sleep) -> DateInterval? {
        return intervalType == .inbed ? sleep.inBedInterval : sleep.sleepInterval
    }

}

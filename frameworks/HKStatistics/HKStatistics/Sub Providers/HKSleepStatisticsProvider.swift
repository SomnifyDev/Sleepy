import Foundation
import HKCoreSleep
import HealthKit

final class HKSleepStatisticsProvider {

    func handleSleepStatistics(for sleepStatType: SleepStatType, sleep: Sleep) -> Int {
        switch sleepStatType {
        case .asleep:
            return sleep.sleepInterval.end.minutes(from: sleep.sleepInterval.start)
        case .inBed:
            return sleep.inBedInterval.end.minutes(from: sleep.inBedInterval.start)
        }
    }

}

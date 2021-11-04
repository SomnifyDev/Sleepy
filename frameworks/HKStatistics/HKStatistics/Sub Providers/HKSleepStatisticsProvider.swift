import Foundation
import HealthKit
import HKCoreSleep

final class HKSleepStatisticsProvider {

    // MARK: - Methods

    func sleepData(dataType: SleepData, sleep: Sleep) -> Int {
        switch dataType {
        case .asleep:
            return sleep.sleepInterval.end.minutes(from: sleep.sleepInterval.start)
        case .inBed:
            return sleep.inBedInterval.end.minutes(from: sleep.inBedInterval.start)
        case .fallAsleepDuration:
            return sleep.sleepInterval.start.minutes(from: sleep.inBedInterval.start)
        }
    }

}

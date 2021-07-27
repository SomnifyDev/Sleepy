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

    func getSleepIntervalBoundary(boundary: SleepBoundaryType, sleep: Sleep) -> String {
        switch boundary {
        case .start:
            return sleep.sleepInterval.start.getFormattedDate(format: "HH:mm")
        case .end:
            return sleep.sleepInterval.end.getFormattedDate(format: "HH:mm")
        }
    }

    func getFallingAsleepDuration(sleep: Sleep) -> String {
        let mins = sleep.sleepInterval.start.minutes(from: sleep.inBedInterval.start)
        return mins < 0 ? "0m" : "\(mins)m"
    }

}

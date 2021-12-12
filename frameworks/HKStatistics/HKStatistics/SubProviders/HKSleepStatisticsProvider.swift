// Copyright (c) 2021 Sleepy.

import Foundation
import HealthKit
import HKCoreSleep

final class HKSleepStatisticsProvider {
	// MARK: - Methods

	func sleepData(dataType: SleepData, sleep: Sleep) -> Int {
		switch dataType {
		case .asleep:
			guard let firstMicroSleep = sleep.samples.last,
			      let lastMicroSleep = sleep.samples.first else { return 0 }
			return abs(firstMicroSleep.sleepInterval.end.minutes(from: lastMicroSleep.sleepInterval.start))
		case .inBed:
			guard let firstMicroSleep = sleep.samples.last,
			      let lastMicroSleep = sleep.samples.first else { return 0 }
			return abs(firstMicroSleep.inBedInterval.end.minutes(from: lastMicroSleep.inBedInterval.start))
		case .fallAsleepDuration:
			guard let firstMicroSleep = sleep.samples.last else { return 0 }
			return abs(firstMicroSleep.sleepInterval.start.minutes(from: firstMicroSleep.inBedInterval.start))
		}
	}
}

// Copyright (c) 2021 Sleepy.

import Foundation
import HealthKit
import HKCoreSleep

final class HKSleepStatisticsProvider {
	func handleSleepStatistics(for sleepStatType: SleepStatType, sleep: Sleep) -> Int {
		switch sleepStatType {
		case .asleep:
			return sleep.sleepInterval.end.minutes(from: sleep.sleepInterval.start)
		case .inBed:
			return sleep.inBedInterval.end.minutes(from: sleep.inBedInterval.start)
		}
	}

	func getFallingAsleepDuration(sleep: Sleep) -> Int {
		return sleep.sleepInterval.start.minutes(from: sleep.inBedInterval.start)
	}
}

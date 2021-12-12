// Copyright (c) 2021 Sleepy.

import Foundation
import HealthKit
import HKCoreSleep

final class HKDailyStatisticsProvider {
	// MARK: - Properties

	private let generalStatisticsProvider = HKGeneralStatisticsProvider()

	// MARK: - Methods

	func data(healthtype: HKService.HealthType, sleep: Sleep) -> [Double] {
		let flattenArrayPhases = sleep.samples.compactMap { (element: MicroSleep) -> [Phase]? in
			element.phases
		}
		let phases = flattenArrayPhases.flatMap { $0 }

		switch healthtype {
		case .energy:
			return self.generalStatisticsProvider.data(healthType: .energy, data: phases.flatMap { $0.energyData })
		case .heart:
			return self.generalStatisticsProvider.data(healthType: .heart, data: phases.flatMap { $0.heartData })
		case .respiratory:
			return self.generalStatisticsProvider.data(healthType: .respiratory, data: phases.flatMap { $0.breathData })
		case .asleep, .inbed:
			assertionFailure("Do not use this method for that. You can get inbed asleep stat from date intervals in Sleep object")
		}
		return []
	}

	func intervalBoundary(intervalType: SleepInterval, sleep: Sleep) -> DateInterval? {
		guard let firstMicroSleep = sleep.samples.last,
		      let lastMicroSleep = sleep.samples.first else { return nil }
		switch intervalType {
		case .asleep:
			return DateInterval(start: firstMicroSleep.sleepInterval.start, end: lastMicroSleep.sleepInterval.end)
		case .inbed:
			return DateInterval(start: firstMicroSleep.inBedInterval.start, end: lastMicroSleep.inBedInterval.end)
		}
	}
}

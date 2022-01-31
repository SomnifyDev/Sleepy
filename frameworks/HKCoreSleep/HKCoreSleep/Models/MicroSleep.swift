// Copyright (c) 2022 Sleepy.

import Foundation
import HealthKit

public class Sleep {
    public var samples: [MicroSleep] = []

    public var phases: [Phase] {
        let flattenArrayPhases = self.samples.compactMap { (element: MicroSleep) -> [Phase]? in
            element.phases
        }
        return flattenArrayPhases.flatMap { $0 }
    }

    public var sleepInterval: DateInterval? {
        guard let startDate = samples.last?.sleepInterval.start,
              let endDate = samples.first?.sleepInterval.end else { return nil }
        return DateInterval(start: startDate, end: endDate)
    }

    public var inbedInterval: DateInterval? {
        guard let startDate = samples.last?.inBedInterval.start,
              let endDate = samples.first?.inBedInterval.end else { return nil }
        return DateInterval(start: startDate, end: endDate)
    }

    public init(samples: [MicroSleep]) {
        self.samples = samples
    }
}

public class MicroSleep {
    public let sleepInterval: DateInterval
    public let inBedInterval: DateInterval
    public let phases: [Phase]?

    public init(sleepInterval: DateInterval, inBedInterval: DateInterval, phases: [Phase]?) {
        self.sleepInterval = sleepInterval
        self.inBedInterval = inBedInterval
        self.phases = phases
    }
}

// Copyright (c) 2021 Sleepy.

import Foundation
import HealthKit

public class Sleep
{
    public let sleepInterval: DateInterval
    public let inBedInterval: DateInterval
    public let phases: [Phase]?

    public init(sleepInterval: DateInterval, inBedInterval: DateInterval, phases: [Phase]?)
    {
        self.sleepInterval = sleepInterval
        self.inBedInterval = inBedInterval
        self.phases = phases
    }
}

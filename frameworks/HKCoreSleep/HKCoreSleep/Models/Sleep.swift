import Foundation
import HealthKit

public class Sleep {
    
    public let sleepInterval: DateInterval
    public let inBedInterval: DateInterval

    public let inBedSamples: [HKSample]?
    public let asleepSamples: [HKSample]?

    public let heartSamples: [HKSample]?
    public let energySamples: [HKSample]?

    public var phases: [Phase]?

    public init(sleepInterval: DateInterval,
                inBedInterval: DateInterval,
                inBedSamples: [HKSample]?,
                asleepSamples: [HKSample]?,
                heartSamples: [HKSample]?,
                energySamples: [HKSample]?,
                phases: [Phase]?) {
        self.sleepInterval = sleepInterval
        self.inBedInterval = inBedInterval
        self.inBedSamples = inBedSamples
        self.asleepSamples = asleepSamples
        self.heartSamples = heartSamples
        self.energySamples = energySamples
        self.phases = phases
    }
    
}

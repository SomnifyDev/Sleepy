// Copyright (c) 2021 Sleepy.

import Foundation
import HealthKit
import HKCoreSleep

final class HKPhasesStatisticsProvider {
    func handlePhasesStatistic(of type: PhasesStatisticsType, for data: [Phase]?) -> Any? {
        guard let phasesData = data else {
            print("Phases array is probably nil")
            return nil
        }

        switch type {
        case .deepPhaseTime:
            return phasesData.filter { $0.condition == .deep }.reduce(0) { partialResult, phase in
                partialResult + phase.interval.end.minutes(from: phase.interval.start)
            }
        case .lightPhaseTime:
            return phasesData.filter { $0.condition == .light }.reduce(0) { partialResult, phase in
                partialResult + phase.interval.end.minutes(from: phase.interval.start)
            }
        case .mostIntervalInDeepPhase:
            guard
                let max = phasesData.filter({ $0.condition == .deep }).map({ $0.interval.end.minutes(from: $0.interval.start) }).max() else
            {
                return nil
            }
            return max
        case .mostIntervalInLightPhase:
            guard
                let max = phasesData.filter({ $0.condition == .light }).map({ $0.interval.end.minutes(from: $0.interval.start) }).max() else
            {
                return nil
            }
            return max
        case .phasesData:
            return phasesData.map { $0.chartPoint }
        }
    }
}

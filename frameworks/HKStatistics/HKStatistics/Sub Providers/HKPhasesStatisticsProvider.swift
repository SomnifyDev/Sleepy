import Foundation
import HKCoreSleep
import HealthKit

final class HKPhasesStatisticsProvider {

    func handleStatistic(of type: PhasesStatisticsType, for data: [Phase]?) -> Int {
        guard let phasesData = data
        else {
            assertionFailure("Phases array is probably nil")
            return -1
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
            // TODO: @Anas remove force unwrapping
            return phasesData.filter { $0.condition == .deep }.map { $0.interval.end.minutes(from: $0.interval.start) }.max()!
        case .mostIntervalInLightPhase:
            return phasesData.filter { $0.condition == .light }.map { $0.interval.end.minutes(from: $0.interval.start) }.max()!
        }
    }

}

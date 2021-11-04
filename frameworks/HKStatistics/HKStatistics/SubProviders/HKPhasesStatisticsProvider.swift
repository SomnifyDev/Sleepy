import Foundation
import HealthKit
import HKCoreSleep

final class HKPhasesStatisticsProvider {

    // MARK: - Methods
    
    func phasesData(dataType: PhasesData, data: [Phase]?) -> Any? {
        guard let data = data else {
            return nil
        }
        switch dataType {
        case .deepPhaseDuration:
            return reducePhasesData(data.filter { $0.condition == .deep })
        case .lightPhaseDuration:
            return reducePhasesData(data.filter { $0.condition == .light })
        case .chart:
            return data.map { $0.chartPoint }
        }
    }

    // MARK: - Private methods

    private func reducePhasesData(_ data: [Phase]) -> Int {
        return data.reduce(0) { partialResult, phase in
            partialResult + phase.interval.end.minutes(from: phase.interval.start)
        }
    }

}

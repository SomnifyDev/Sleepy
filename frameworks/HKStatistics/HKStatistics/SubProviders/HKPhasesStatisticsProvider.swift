// Copyright (c) 2022 Sleepy.

import Foundation
import HealthKit
import HKCoreSleep
import UIComponents

final class HKPhasesStatisticsProvider {
    // MARK: - Methods

    func phasesData(dataType: PhasesData, data: [Phase]?) -> Any? {
        guard let data = data
        else {
            return nil
        }
        switch dataType {
        case .deepPhaseDuration:
            return self.reducePhasesData(data.filter { $0.condition == .deep })
        case .lightPhaseDuration:
            return self.reducePhasesData(data.filter { $0.condition == .light })
        case .chart:
            return data.map { SampleData(date: $0.interval.start, value: $0.chartPoint) }
        }
    }

    // MARK: - Private methods

    private func reducePhasesData(_ data: [Phase]) -> Int {
        return data.reduce(0) { partialResult, phase in
            partialResult + phase.interval.end.minutes(from: phase.interval.start)
        }
    }
}

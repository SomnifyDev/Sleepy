import Foundation
import HealthKit
import HKCoreSleep

final class HKNumericTypesStatisticsProvider {
    
    // MARK: - Methods

    func numericData(
        dataType: NumericData,
        indicator: Indicator,
        sleep: Sleep
    ) -> Double? {
        switch dataType {
        case .heart:
            return data(indicator, sleep.phases?.flatMap { $0.heartData } ?? [])
        case .energy:
            return data(indicator, sleep.phases?.flatMap { $0.energyData } ?? [])
        case .respiratory:
            return data(indicator, sleep.phases?.flatMap { $0.breathData } ?? [])
        }
    }

    // MARK: - Private methods

    private func data(
        _ indicator: Indicator,
        _ data: [SampleData]
    ) -> Double? {
        guard !data.isEmpty else {
            return nil
        }
        return dataByIndicator(indicator: indicator, data: data.map { $0.value })
    }

    private func dataByIndicator(
        indicator: Indicator,
        data: [Double]
    ) -> Double? {
        switch indicator {
        case .min:
            return data.min() ?? nil
        case .max:
            return data.max() ?? nil
        case .mean:
            return (data.reduce(0.0) { $0 + $1 }) / Double(data.count)
        case .sum:
            return data.reduce(0.0) { $0 + $1 }
        }
    }
    
}

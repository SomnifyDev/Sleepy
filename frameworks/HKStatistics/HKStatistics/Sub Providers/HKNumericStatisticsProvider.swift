import Foundation
import HKCoreSleep
import HealthKit

// Здесь обрабатываются сразу двое - сердце и энергия (потенциально еще звук)
final class HKNumericTypesStatisticsProvider {

    func handleStatistic(for dataType: NumericDataType, of indicatorType: IndicatorType, sleep: Sleep) -> Double {
        switch dataType {
        case .heart:
            return switchType(for: indicatorType, for: sleep.heartSamples, with: HKUnit(from: "count/min"))
        case .energy:
            return switchType(for: indicatorType, for: sleep.energySamples, with: HKUnit.kilocalorie())
        }
    }

    private func switchType(for indicatorType: IndicatorType, for samples: [HKSample]?, with unit: HKUnit) -> Double {
        if let healthData = samples as? [HKQuantitySample] {
            let data = healthData.map { $0.quantity.doubleValue(for: unit) }

            switch indicatorType {
            case .min:
                if let min = data.min() {
                    return min
                } else {
                    assertionFailure("Couldn't get min from data")
                    return -1
                }
            case .max:
                if let max = data.max() {
                    return max
                } else {
                    assertionFailure("Couldn't get max from data")
                    return -1
                }
            case .mean:
                return data.reduce(0.0) { $0 + $1 } / Double(data.count)
            }
        } else {
            assertionFailure("Couldn't get data from samples")
            return -1
        }
    }
}

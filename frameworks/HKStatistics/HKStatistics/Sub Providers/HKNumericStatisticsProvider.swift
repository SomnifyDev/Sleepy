import Foundation
import HKCoreSleep
import HealthKit

// Здесь обрабатываются сразу двое - сердце и энергия (потенциально еще звук)
final class HKNumericTypesStatisticsProvider {

    func handleNumericStatistic(for dataType: NumericDataType, of indicatorType: IndicatorType, sleep: Sleep) -> Double? {
        switch dataType {
        case .heart:
            return switchType(for: indicatorType, for: sleep.heartSamples, with: HKUnit(from: "count/min"))
        case .energy:
            return switchType(for: indicatorType, for: sleep.energySamples, with: HKUnit.kilocalorie())
        }
    }

    private func switchType(for indicatorType: IndicatorType, for samples: [HKSample]?, with unit: HKUnit) -> Double? {
        if let healthData = samples as? [HKQuantitySample] {
            let data = healthData.map { $0.quantity.doubleValue(for: unit) }

            switch indicatorType {
            case .min:
                guard let min = data.min() else { print("Couldn't get min from data in HKNumericTypesStatisticsProvider"); return nil }
                return min
            case .max:
                guard let max = data.max() else { print("Couldn't get max from data in HKNumericTypesStatisticsProvider"); return nil }
                return max
            case .mean:
                if data.isEmpty { print("Data is nil in HKNumericTypesStatisticsProvider"); return nil }
                return data.reduce(0.0) { $0 + $1 } / Double(data.count)
            }
        } else {
            print("Couldn't get data from samples")
            return nil
        }
    }
}

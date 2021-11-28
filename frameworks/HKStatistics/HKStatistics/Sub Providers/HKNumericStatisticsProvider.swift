// Copyright (c) 2021 Sleepy.

import Foundation
import HealthKit
import HKCoreSleep

// Здесь обрабатываются сразу двое - сердце и энергия (потенциально еще звук)
final class HKNumericTypesStatisticsProvider {
    func handleNumericStatistic(for dataType: NumericDataType, of indicatorType: IndicatorType, sleep: Sleep) -> Double?
    {
        switch dataType {
        case .heart:
            return self.switchType(for: indicatorType, for: sleep.phases?.flatMap { $0.heartData })
        case .respiratory:
            return self.switchType(for: indicatorType, for: sleep.phases?.flatMap { $0.breathData })
        case .energy:
            return self.switchType(for: indicatorType, for: sleep.phases?.flatMap { $0.energyData })
        }
    }

    private func switchType(for indicatorType: IndicatorType, for samples: [SampleData]?) -> Double?
    {
        if let samples = samples {
            let data = samples.map { $0.value }

            switch indicatorType {
            case .min:
                guard let min = data.min() else {
                    print("Couldn't get min from data in HKNumericTypesStatisticsProvider")
                    return nil
                }
                return min
            case .max:
                guard let max = data.max() else {
                    print("Couldn't get max from data in HKNumericTypesStatisticsProvider")
                    return nil
                }
                return max
            case .mean:
                if data.isEmpty {
                    print("Data is nil in HKNumericTypesStatisticsProvider")
                    return nil
                }
                return data.reduce(0.0) { $0 + $1 } / Double(data.count)
            case .sum:
                let sum = data.reduce(0.0) { $0 + $1 }
                guard sum > 0 else {
                    print("Couldn't get sum from data in HKNumericTypesStatisticsProvider")
                    return nil
                }
                return sum
            }
        } else {
            print("Couldn't get data from samples")
            return nil
        }
    }
}

import Foundation
import HealthKit
import HKCoreSleep

final class HKGeneralStatisticsProvider {
    func getData(for healthType: HKService.HealthType, sleepData: [SampleData]?) -> [Double] {
        if let sleepData = sleepData {
            return sleepData.map { $0.value }
        }
        print("sleepData is probably nil")
        return []
    }

    func getDataWithIndicator(for healthType: HKService.HealthType, for indicatorType: IndicatorType, sleepData: [HKSample]?) -> Double? {
        switch healthType {
        case .energy:
            return handleForQuantitySample(for: indicatorType, arr: sleepData, for: HKUnit.kilocalorie())

        case .heart, .respiratory:
            return handleForQuantitySample(for: indicatorType, arr: sleepData, for: HKUnit(from: "count/min"))

        case .asleep, .inbed:
            return handleForCategorySample(for: indicatorType, arr: sleepData)
        }
    }

    private func handleForCategorySample(for indicator: IndicatorType, arr: [HKSample]?) -> Double? {
        if let categData = arr as? [HKCategorySample] {
            let data = categData.map { $0.endDate.minutes(from: $0.startDate) }
            switch indicator {
            case .min:
                guard let min = data.min() else {
                    return nil
                }
                return Double(min)
            case .max:
                guard let max = data.max() else {
                    return nil
                }
                return Double(max)
            case .mean:
                if data.isEmpty {
                    return nil
                }
                return (data.reduce(0.0) { $0 + Double($1) }) / Double(data.count)
            case .sum:
                let sum = data.reduce(0) { $0 + $1 }
                guard sum > 0 else {
                    print("Couldn't get sum from data in HKNumericTypesStatisticsProvider")
                    return nil
                }
                return Double(sum)
            }
        } else {
            return nil
        }
    }

    private func handleForQuantitySample(for indicator: IndicatorType, arr: [HKSample]?, for unit: HKUnit) -> Double? {
        if let quantityData = arr as? [HKQuantitySample] {
            let data = quantityData.map { $0.quantity.doubleValue(for: unit) }
            switch indicator {
            case .min:
                guard let min = data.min() else {
                    return nil
                }
                return Double(min)
            case .max:
                guard let max = data.max() else {
                    return nil
                }
                return Double(max)
            case .mean:
                if data.isEmpty {
                    return nil
                }
                return (data.reduce(0.0) { $0 + Double($1) }) / Double(data.count)
            case .sum:
                let sum = data.reduce(0.0) { $0 + $1 }
                guard sum > 0 else {
                    print("Couldn't get sum from data in HKNumericTypesStatisticsProvider")
                    return nil
                }
                return sum
            }
        } else {
            return nil
        }
    }
}

import Foundation
import HKCoreSleep
import HealthKit

final class HKGeneralStatisticsProvider {

    func getData(for healthType: HKService.HealthType, sleepData: [HKSample]?) -> [Double] {
        switch healthType {
        case .energy:
            if let energyData = sleepData as? [HKQuantitySample] {
                let data = energyData.map { $0.quantity.doubleValue(for: HKUnit.kilocalorie()) }
                return data
            }

        case .heart:
            if let heartData = sleepData as? [HKQuantitySample] {
                let data = heartData.map { $0.quantity.doubleValue(for: HKUnit(from: "count/min")) }
                return data
            }

        case .asleep, .inbed:
            if let categData = sleepData as? [HKCategorySample] {
                let data = categData.map { Double($0.endDate.minutes(from: $0.startDate)) }
                return data
            }
        }

        print("sleepData is probably nil")
        return []
    }

    func getDataWithIndicator(for healthType: HKService.HealthType, for indicatorType: IndicatorType, sleepData: [HKSample]?) -> Double? {
        switch healthType {
        case .energy:
            return self.handleForQuantitySample(for: indicatorType, arr: sleepData, for: HKUnit.kilocalorie())

        case .heart:
            return self.handleForQuantitySample(for: indicatorType, arr: sleepData, for: HKUnit(from: "count/min"))

        case .asleep, .inbed:
            return self.handleForCategorySample(for: indicatorType, arr: sleepData)
        }
    }

    private func handleForCategorySample(for indicator: IndicatorType, arr: [HKSample]?) -> Double? {
        if let categData = arr as? [HKCategorySample] {
            let data = categData.map { $0.endDate.minutes(from: $0.startDate) }
            switch indicator {
            case .min:
                guard let min = data.min() else { return nil }
                return Double(min)
            case .max:
                guard let max = data.max() else { return nil }
                return Double(max)
            case .mean:
                if data.isEmpty { return nil }
                return (data.reduce(0.0) { $0 + Double($1) }) / Double(data.count)
            case .sum:
                return nil
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
                guard let min = data.min() else { return nil }
                return Double(min)
            case .max:
                guard let max = data.max() else { return nil }
                return Double(max)
            case .mean:
                if data.isEmpty { return nil }
                return (data.reduce(0.0) { $0 + Double($1) }) / Double(data.count)
            case .sum:
                let sum = data.reduce(0.0) { $0 + $1 }
                guard sum > 0 else { print("Couldn't get sum from data in HKNumericTypesStatisticsProvider"); return nil }
                return sum
            }
        } else {
            return nil
        }
    }

}

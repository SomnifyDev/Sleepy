import Foundation
import HKCoreSleep
import HealthKit

final class HKGeneralStatisticsProvider {

    func getDataByInterval(for healthType: HKService.HealthType, sleepData: [HKSample]?) -> [Double] {
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

        assertionFailure("sleepData is probably nil")
        return []
    }

    func getDataByIntervalWithIndicator(for healthType: HKService.HealthType, for indicatorType: IndicatorType, sleepData: [HKSample]?) -> Double {
        switch healthType {
        case .energy:
            return self.handleForQuantitySample(for: indicatorType, arr: sleepData, for: HKUnit.kilocalorie())

        case .heart:
            return self.handleForQuantitySample(for: indicatorType, arr: sleepData, for: HKUnit(from: "count/min"))

        case .asleep, .inbed:
            return self.handleForCategorySample(for: indicatorType, arr: sleepData)
        }
    }

    func handleForCategorySample(for indicator: IndicatorType, arr: [HKSample]?) -> Double {
        if let categData = arr as? [HKCategorySample] {

            let data = categData.map { $0.endDate.minutes(from: $0.startDate) }

            switch indicator {
            case .min:
                // TODO: @Anas remove force unwrapping
                return Double(data.min()!)
            case .max:
                return Double(data.max()!)
            case .mean:
                return (data.reduce(0.0) { $0 + Double($1) }) / Double(data.count)
            }
        } else {
            return -1.0
        }
    }

    func handleForQuantitySample(for indicator: IndicatorType, arr: [HKSample]?, for unit: HKUnit) -> Double {
        if let quantityData = arr as? [HKQuantitySample] {

            let data = quantityData.map { $0.quantity.doubleValue(for: unit) }

            switch indicator {
            case .min:
                // TODO: @Anas remove force unwrapping
                return data.min()!
            case .max:
                return data.max()!
            case .mean:
                return (data.reduce(0.0) { $0 + $1 }) / Double(data.count)
            }
        } else {
            return -1.0
        }
    }

}

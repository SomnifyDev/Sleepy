//
//  SubProviders.swift
//  HKStatistics
//
//  Created by Анас Бен Мустафа on 6/25/21.
//

import Foundation
import HKCoreSleep
import HealthKit

final class HKGenrealStatisticsProvider {

    func getDataByInterval(for healthType: HKService.HealthType, sleepData: [HKSample]?) -> [Double] {
        switch healthType {
        case .energy:
            if let en_data = sleepData as? [HKQuantitySample] {
                let data = en_data.map { $0.quantity.doubleValue(for: HKUnit.kilocalorie()) }
                return data
            }

        case .heart:
            if let heart_data = sleepData as? [HKQuantitySample] {
                let data = heart_data.map { $0.quantity.doubleValue(for: HKUnit(from: "count/min")) }
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
                return Double(data.min()!) // форс - плохо
            case .max:
                return Double(data.max()!) // форс - плохо
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
                return data.min()! // форс - плохо
            case .max:
                return data.max()! // форс - плохо
            case .mean:
                return (data.reduce(0.0) { $0 + $1 }) / Double(data.count)
            }
        } else {
            return -1.0
        }
    }

}

// Здесь обрабатываются сразу двое - сердце и энергия (потенциально еще звук)
final class HKNumericTypesStatisticsProvider {
    
    func handlingStatistic(for dataType: NumericDataType, of indicatorType: IndicatorType, sleep: Sleep) -> Double {
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
                if let min = data.min() { return min } else { assertionFailure("Couldn't get min from data"); return -1 }
            case .max:
                if let max = data.max() { return max } else { assertionFailure("Couldn't get max from data"); return -1 }
            case .mean:
                return data.reduce(0.0) { $0 + $1 } / Double(data.count)
            }
        } else {
            assertionFailure("Couldn't get data from samples")
            return -1
        }
    }
    
}

final class HKPhasesStatisticsProvider {
    
    func handlingStatistic(of type: PhasesStatisticsType, for data: [Phase]?) -> Int {

        guard
            let phasesData = data
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
            return phasesData.filter { $0.condition == .deep }.map { $0.interval.end.minutes(from: $0.interval.start) }.max()!
        case .mostIntervalInLightPhase:
            return phasesData.filter { $0.condition == .light }.map { $0.interval.end.minutes(from: $0.interval.start) }.max()!
        }
    }
    
}

final class HKSleepStatisticsProvider {

    func handlingStatistics(for sleepStatType: SleepStatType, sleep: Sleep) -> Int {
        switch sleepStatType {
        case .asleep:
            return sleep.sleepInterval.end.minutes(from: sleep.sleepInterval.start)
        case .inBed:
            return sleep.inBedInterval.end.minutes(from: sleep.inBedInterval.start)
        }
    }

}

//
//  HKStatisticsProvider.swift
//  HKStatistics
//
//  Created by Анас Бен Мустафа on 6/25/21.
//

import Foundation
import HKCoreSleep
import HealthKit

final class HKStatisticsProvider: HKStatistics {
    
    // MARK: Properties
    
    private var healthService: HKService
    private var heartRateData: [Double] = []
    private var energyData: [Double] = []
    private var phasesData: [Phase]
    
    // MARK: SubProviders
    
    private var numericTypesStatisticsProvider: HKNumericTypesStatisticsProvider = HKNumericTypesStatisticsProvider()
    private var phasesStatisticsProvider: HKPhasesStatisticsProvider = HKPhasesStatisticsProvider()
    
    // MARK: Initialization
    
    init(sleep: Sleep, healthService: HKService) {
        if let heartRateData = sleep.heartSamples as? [HKQuantitySample] {
            self.heartRateData = heartRateData.map { $0.quantity.doubleValue(for: HKUnit(from: "count/min")) }
        }
        
        if let energyData = sleep.energySamples as? [HKQuantitySample] {
            self.energyData = energyData.map { $0.quantity.doubleValue(for: HKUnit.kilocalorie()) }
        }
        
        self.phasesData = sleep.phases ?? []
        self.healthService = healthService
    }
    
    // MARK: Functions
    
    func getData(dataType: NumericDataType, indicatorType: IndicatorType) -> Double {
        switch dataType {
        case .heart:
            return numericTypesStatisticsProvider.handlingIndicator(of: indicatorType, for: heartRateData)
        case .energy:
            return numericTypesStatisticsProvider.handlingIndicator(of: indicatorType, for: energyData)
        }
    }
    
    func getData(dataType: SleepDataType, for phasesStatType: PhasesStatisticsType) -> Double {
        switch dataType {
        case .sleep:
            return 0.0
        case .phases:
            return phasesStatisticsProvider.handlingStatistic(of: phasesStatType, for: phasesData)
        }
    }
    
    func getDataByIntervalWithIndicator(dataType: HKService.HealthType, indicatorType: IndicatorType, for timeInterval: DateInterval, completion: @escaping (Double) -> ()) {
        healthService.readData(type: dataType, interval: timeInterval, ascending: true) { _, sleepData, error in
            switch dataType {
            case .energy:
                completion(self.handleForQuantitySample(for: indicatorType, arr: sleepData, for: HKUnit.kilocalorie()))
                
            case .heart:
                completion(self.handleForQuantitySample(for: indicatorType, arr: sleepData, for: HKUnit(from: "count/min")))
                
            case .asleep, .inbed:
                completion(self.handleForCategorySample(for: indicatorType, arr: sleepData))
            }
        }
    }
    
    func getDataByInterval(dataType: HKService.HealthType, for timeInterval: DateInterval, completion: @escaping ([Double]) -> ()) {
        healthService.readData(type: dataType, interval: timeInterval, ascending: true) { _, sleepData, error in
            switch dataType {
            case .energy:
                if let en_data = sleepData as? [HKQuantitySample] {
                    let data = en_data.map { $0.quantity.doubleValue(for: HKUnit.kilocalorie()) }
                    completion(data)
                }

            case .heart:
                if let heart_data = sleepData as? [HKQuantitySample] {
                    let data = heart_data.map { $0.quantity.doubleValue(for: HKUnit(from: "count/min")) }
                    completion(data)
                }

            case .asleep, .inbed:
                if let categData = sleepData as? [HKCategorySample] {
                    let data = categData.map { Double($0.endDate.minutes(from: $0.startDate)) }
                    completion(data)
                }
            }
        }
    }

    
    private func handleForCategorySample(for indicator: IndicatorType, arr: [HKSample]?) -> Double {
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
    
    private func handleForQuantitySample(for indicator: IndicatorType, arr: [HKSample]?, for unit: HKUnit) -> Double {
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

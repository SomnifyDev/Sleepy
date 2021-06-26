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
    
    func getDataByIntervalNumeric(dataType: HKService.HealthType, indicatorType: IndicatorType, for timeInterval: DateInterval, completion: (Double) -> ()) {
        completion(0.0)
    }
    
    func getDataByIntervalNumeric(dataType: HKService.HealthType, for timeInterval: DateInterval, completion: (Double) -> ()) {
        completion(0.0)
    }
}

//
//  Protocols.swift
//  HKStatistics
//
//  Created by Анас Бен Мустафа on 6/25/21.
//

import Foundation
import HKCoreSleep

protocol HKStatistics {

    func getData(dataType: NumericDataType, indicatorType: IndicatorType) -> Double
    func getData(for phasesStatType: PhasesStatisticsType) -> Int
    func getData(for sleepStatType: SleepStatType) -> Int

    func getDataByIntervalWithIndicator(healthType: HKService.HealthType,
                                        indicatorType: IndicatorType,
                                        for timeInterval: DateInterval,
                                        completion: @escaping (Double) -> ())
    
    func getDataByInterval(healthType: HKService.HealthType,
                           for timeInterval: DateInterval,
                           completion: @escaping ([Double]) -> ())
    
}

protocol HKNumericTypesStatistics {
    
    func handlingIndicator(of type: IndicatorType, for data: [Double]) -> Double
    
}

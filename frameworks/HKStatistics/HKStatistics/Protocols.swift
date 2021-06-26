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
    func getData(dataType: SleepDataType, for phasesStatType: PhasesStatisticsType) -> Double
    func getDataByIntervalNumeric(dataType: HKService.HealthType, indicatorType: IndicatorType, for timeInterval: DateInterval, completion: (Double) -> ())
    func getDataByIntervalNumeric(dataType: HKService.HealthType, for timeInterval: DateInterval, completion: (Double) -> ())
    
}

protocol HKNumericTypesStatistics {
    
    func handlingIndicator(of type: IndicatorType, for data: [Double]) -> Double
    
}

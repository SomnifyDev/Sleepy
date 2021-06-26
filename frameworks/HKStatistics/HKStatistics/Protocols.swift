//
//  Protocols.swift
//  HKStatistics
//
//  Created by Анас Бен Мустафа on 6/25/21.
//

import Foundation
import HKCoreSleep

protocol HKStatistics {
    
    // Функции работают с данными в рамках последнего сна
    func getData(dataType: NumericDataType, indicatorType: IndicatorType) -> Double
    func getData(dataType: SleepDataType, for phasesStatType: PhasesStatisticsType) -> Double
    
    // Функции предоставляют данные на заданном интервале времени
    func getDataByIntervalWithIndicator(dataType: HKService.HealthType,
                                        indicatorType: IndicatorType,
                                        for timeInterval: DateInterval,
                                        completion: @escaping (Double) -> ())
    
    func getDataByInterval(dataType: HKService.HealthType,
                           for timeInterval: DateInterval,
                           completion: @escaping ([Double]) -> ())
    
}

protocol HKNumericTypesStatistics {
    
    func handlingIndicator(of type: IndicatorType, for data: [Double]) -> Double
    
}

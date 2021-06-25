//
//  Protocols.swift
//  HKStatistics
//
//  Created by Анас Бен Мустафа on 6/25/21.
//

import Foundation

protocol HKStatistics {
    
    func getData(dataType: DataType, indicatorType: IndicatorType?, for phasesStatType: PhasesStatisticsType?) -> Double
    func getDataByInterval(dataType: DataType, indicatorType: IndicatorType, for timeInterval: DateInterval) -> Double
    
}

protocol HKNumericTypesStatistics {
    
    func handlingIndicator(of type: IndicatorType, for data: [Double]) -> Double
    
}

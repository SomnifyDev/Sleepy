//
//  HKStatisticsProvider.swift
//  HKStatistics
//
//  Created by Анас Бен Мустафа on 6/25/21.
//

import Foundation

final class HKStatisticsProvider: HKStatistics {
    
    // Якобы эти массивчики лежат в SleepData и приходят в инициилизаторе
    private var heartRateData = [0.0]
    private var energyData = [0.0]
    private var phasesData: [Phase] = [Phase(startTime: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, endTime: Date(), condition: .deepPhase, verdictCoefficient: 0.0)]
    
    // HealthStats
    private var numericTypesStatisticsProvider: HKNumericTypesStatisticsProvider = HKNumericTypesStatisticsProvider()
    private var phasesStatisticsProvider: HKPhasesStatisticsProvider = HKPhasesStatisticsProvider()
    
    func getData(dataType: DataType, indicatorType: IndicatorType?, for phasesStatType: PhasesStatisticsType?) -> Double {
        switch dataType {
        case .heart:
            return numericTypesStatisticsProvider.handlingIndicator(of: indicatorType!, for: heartRateData)
        case .energy:
            return numericTypesStatisticsProvider.handlingIndicator(of: indicatorType!, for: energyData)
        case .sleep:
            return 0.0
        case .phases:
            // Force unwrapping, поскольку если уж мы вызываем эту функцию где-то для фаз, мы точно будем передавать phasesStatType в параметрах
            return phasesStatisticsProvider.handlingStatistic(of: phasesStatType!, for: phasesData)
        }
    }
    
    func getDataByInterval(dataType: DataType, indicatorType: IndicatorType, for timeInterval: DateInterval) -> Double {
        
        // TODO
        
        return 0.0
    }
    
}

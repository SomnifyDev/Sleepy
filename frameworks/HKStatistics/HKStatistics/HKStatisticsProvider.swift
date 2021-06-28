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
    private var sleep: Sleep
    
    // MARK: SubProviders
    
    private var numericTypesStatisticsProvider: HKNumericTypesStatisticsProvider = HKNumericTypesStatisticsProvider()
    private var phasesStatisticsProvider: HKPhasesStatisticsProvider = HKPhasesStatisticsProvider()
    private var sleepStatisticsProvider: HKSleepStatisticsProvider = HKSleepStatisticsProvider()
    private var generalStatisticsProvider: HKGenrealStatisticsProvider = HKGenrealStatisticsProvider()
    
    // MARK: Initialization
    
    init(sleep: Sleep, healthService: HKService) {
        self.sleep = sleep
        self.healthService = healthService
    }
    
    // MARK: Functions

    /// Возвращает данные по сегодняшнему сну: сердцебиение, энергия с переданным индиктором
    func getData(dataType: NumericDataType, indicatorType: IndicatorType) -> Double {
        return numericTypesStatisticsProvider.handlingStatistic(for: dataType, of: indicatorType, sleep: sleep)
    }

    /// Возвращает данные по фазам по сегодняшнему сну, параметр типа статистики
    func getData(for phasesStatType: PhasesStatisticsType) -> Int {
        return phasesStatisticsProvider.handlingStatistic(of: phasesStatType, for: sleep.phases)
    }

    /// Возвращает длительность сна за сегодня
    func getData(for sleepStatType: SleepStatType) -> Int {
        return sleepStatisticsProvider.handlingStatistics(for: sleepStatType, sleep: sleep)
    }

    /// Возвращает значение по любому типу здоровья, по соответствующему индикатору и в нужном интервале времени
    func getDataByIntervalWithIndicator(healthType: HKService.HealthType, indicatorType: IndicatorType, for timeInterval: DateInterval, completion: @escaping (Double) -> ()) {
        healthService.readData(type: healthType, interval: timeInterval, ascending: true) { _, sleepData, error in
            completion(self.generalStatisticsProvider.getDataByIntervalWithIndicator(for: healthType, for: indicatorType, sleepData: sleepData))
        }
    }

    /// Возвращает значение по любому типу здоровья в нужном интервале времени (без индикатора)
    func getDataByInterval(healthType: HKService.HealthType, for timeInterval: DateInterval, completion: @escaping ([Double]) -> ()) {
        healthService.readData(type: healthType, interval: timeInterval, ascending: true) { _, sleepData, error in
            completion(self.generalStatisticsProvider.getDataByInterval(for: healthType, sleepData: sleepData))
        }
    }
    
}

//
//  HKStatisticsProvider.swift
//  HKStatistics
//
//  Created by Анас Бен Мустафа on 6/25/21.
//

import Foundation
import HKCoreSleep
import HealthKit

public protocol HKStatistics {

    func getData(dataType: NumericDataType, indicatorType: IndicatorType, roundPlaces: Int) -> Double?
    func getData(for phasesStatType: PhasesStatisticsType) -> Any?
    func getData(for sleepStatType: SleepStatType) -> Int?

    func getDataByIntervalWithIndicator(healthType: HKService.HealthType,
                                        indicatorType: IndicatorType,
                                        for timeInterval: DateInterval,
                                        bundlePrefixes: [String],
                                        completion: @escaping (Double?) -> Void)

    func getDataByInterval(healthType: HKService.HealthType,
                           for timeInterval: DateInterval,
                           bundlePrefixes: [String],
                           completion: @escaping ([Double]) -> Void)
}

public final class HKStatisticsProvider: HKStatistics {
    
    // MARK: Properties
    
    private var healthService: HKService
    private var sleep: Sleep?
    
    // MARK: SubProviders
    
    private var numericTypesStatisticsProvider: HKNumericTypesStatisticsProvider = HKNumericTypesStatisticsProvider()
    private var phasesStatisticsProvider: HKPhasesStatisticsProvider = HKPhasesStatisticsProvider()
    private var sleepStatisticsProvider: HKSleepStatisticsProvider = HKSleepStatisticsProvider()
    private var generalStatisticsProvider: HKGeneralStatisticsProvider = HKGeneralStatisticsProvider()
    
    
    
    public init(sleep: Sleep?, healthService: HKService) {
        self.sleep = sleep
        self.healthService = healthService
    }
    
    // MARK: Functions

    /// Возвращает данные по сегодняшнему сну: сердцебиение, энергия с переданным индиктором
    public func getData(dataType: NumericDataType, indicatorType: IndicatorType, roundPlaces: Int = 2) -> Double? {
        guard let sleep = sleep else { return nil }
        return numericTypesStatisticsProvider.handleNumericStatistic(for: dataType, of: indicatorType, sleep: sleep)?.rounded(toPlaces: roundPlaces)
    }

    /// Возвращает данные по фазам по сегодняшнему сну, параметр типа статистики
    public func getData(for phasesStatType: PhasesStatisticsType) -> Any? {
        guard let sleep = sleep else { return nil }
        return phasesStatisticsProvider.handlePhasesStatistic(of: phasesStatType, for: sleep.phases)
    }

    /// Возвращает длительность сна за сегодня
    public func getData(for sleepStatType: SleepStatType) -> Int? {
        guard let sleep = sleep else { return nil }
        return sleepStatisticsProvider.handleSleepStatistics(for: sleepStatType, sleep: sleep)
    }

    /// Возвращает массивы с обработанными данными за последний сон, записанный в Sleep
    public func getTodayData(of healthtype: HKService.HealthType) -> [Double] {
        guard let sleep = sleep else { return [] }
        switch healthtype {
        case .energy:
            return generalStatisticsProvider.getData(for: .energy, sleepData: sleep.energySamples)
        case .heart:
            return generalStatisticsProvider.getData(for: .heart, sleepData: sleep.heartSamples)
        case .asleep:
            return generalStatisticsProvider.getData(for: .asleep, sleepData: sleep.asleepSamples)
        case .inbed:
            return generalStatisticsProvider.getData(for: .inbed, sleepData: sleep.inBedSamples)
        }
    }

    /// Возвращает границы сна (начало, конец)
    public func getTodaySleepIntervalBoundary(boundary: SleepIntervalType) -> DateInterval? {
        guard let sleep = sleep else { return nil }
        return boundary == .inbed ? sleep.inBedInterval : sleep.sleepInterval
    }

    /// Возвращает время засыпания в минутах
    public func getTodayFallingAsleepDuration() -> Int? {
        guard let sleep = sleep else { return nil }
        return sleepStatisticsProvider.getFallingAsleepDuration(sleep: sleep)
    }

    /// Возвращает значение по любому типу здоровья, по соответствующему индикатору и в нужном интервале времени
    public func getDataByIntervalWithIndicator(healthType: HKService.HealthType,
                                               indicatorType: IndicatorType,
                                               for timeInterval: DateInterval,
                                               bundlePrefixes: [String] = ["com.apple"],
                                               completion: @escaping (Double?) -> Void) {
        healthService.readData(type: healthType, interval: timeInterval, ascending: true, bundlePrefixes: bundlePrefixes) { [weak self] _, sleepData, error in
            completion(self?.generalStatisticsProvider.getDataWithIndicator(for: healthType, for: indicatorType, sleepData: sleepData))
        }
    }

    /// Возвращает значение метадаты по любому типу здоровья, по соответствующему индикатору и в нужном интервале времени
    public func getMetaDataByIntervalWithIndicator(healthType: HKService.HealthType,
                                                   indicatorType: IndicatorType,
                                                   for timeInterval: DateInterval,
                                                   bundlePrefixes: [String] = ["com.apple"],
                                                   completion: @escaping (Double?) -> Void) {
        healthService.readMetaData(key: healthType.metaDataKey, interval: timeInterval, ascending: true) { _, data, error in
            completion(data)
        }
    }

    /// Возвращает значение по любому типу здоровья в нужном интервале времени (без индикатора)
    public func getDataByInterval(healthType: HKService.HealthType,
                                  for timeInterval: DateInterval,
                                  bundlePrefixes: [String] = ["com.apple"],
                                  completion: @escaping ([Double]) -> Void) {
        healthService.readData(type: healthType, interval: timeInterval, ascending: true, bundlePrefixes: bundlePrefixes) { [weak self] _, sleepData, error in
            completion(self?.generalStatisticsProvider.getData(for: healthType, sleepData: sleepData) ?? [])
        }
    }
    
}

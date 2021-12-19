// Copyright (c) 2021 Sleepy.

import Foundation
import HealthKit
import HKCoreSleep

public protocol HKStatistics
{
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

public final class HKStatisticsProvider: HKStatistics
{
    // MARK: Properties

    private var healthService: HKService
    private var sleep: Sleep?

    // MARK: SubProviders

    private var numericTypesStatisticsProvider = HKNumericTypesStatisticsProvider()
    private var phasesStatisticsProvider = HKPhasesStatisticsProvider()
    private var sleepStatisticsProvider = HKSleepStatisticsProvider()
    private var generalStatisticsProvider = HKGeneralStatisticsProvider()

    public init(sleep: Sleep?, healthService: HKService)
    {
        self.sleep = sleep
        self.healthService = healthService
    }

    // MARK: Functions

    /// Возвращает данные по сегодняшнему сну: сердцебиение, энергия с переданным индиктором
    public func getData(dataType: NumericDataType, indicatorType: IndicatorType, roundPlaces: Int = 2) -> Double?
    {
        guard let sleep = sleep else
        {
            return nil
        }
        return self.numericTypesStatisticsProvider.handleNumericStatistic(for: dataType, of: indicatorType, sleep: sleep)?.rounded(toPlaces: roundPlaces)
    }

    /// Возвращает данные по фазам по сегодняшнему сну, параметр типа статистики
    public func getData(for phasesStatType: PhasesStatisticsType) -> Any?
    {
        guard let sleep = sleep else
        {
            return nil
        }
        return self.phasesStatisticsProvider.handlePhasesStatistic(of: phasesStatType, for: sleep.phases)
    }

    /// Возвращает длительность сна за сегодня
    public func getData(for sleepStatType: SleepStatType) -> Int?
    {
        guard let sleep = sleep else
        {
            return nil
        }
        return self.sleepStatisticsProvider.handleSleepStatistics(for: sleepStatType, sleep: sleep)
    }

    /// Возвращает массивы с обработанными данными за последний сон, записанный в Sleep
    public func getTodayData(of healthtype: HKService.HealthType) -> [Double]
    {
        guard let sleep = sleep else
        {
            return []
        }
        switch healthtype
        {
        case .energy:
            return self.generalStatisticsProvider.getData(for: .energy, sleepData: sleep.phases?.flatMap { $0.energyData })
        case .heart:
            return self.generalStatisticsProvider.getData(for: .heart, sleepData: sleep.phases?.flatMap { $0.heartData })
        case .respiratory:
            return self.generalStatisticsProvider.getData(for: .respiratory, sleepData: sleep.phases?.flatMap { $0.breathData })
        case .asleep, .inbed:
            assertionFailure("Do not use this method for that. You can get inbed asleep stat from date intervals in Sleep object")
        }
        return []
    }

    /// Возвращает границы сна (начало, конец)
    public func getTodaySleepIntervalBoundary(boundary: SleepIntervalType) -> DateInterval?
    {
        guard let sleep = sleep else
        {
            return nil
        }
        return boundary == .inbed ? sleep.inBedInterval : sleep.sleepInterval
    }

    /// Возвращает время засыпания в минутах
    public func getTodayFallingAsleepDuration() -> Int?
    {
        guard let sleep = sleep else
        {
            return nil
        }
        print(self.sleepStatisticsProvider.getFallingAsleepDuration(sleep: sleep))
        return self.sleepStatisticsProvider.getFallingAsleepDuration(sleep: sleep)
    }

    /// Возвращает значение по любому типу здоровья, по соответствующему индикатору и в нужном интервале времени
    public func getDataByIntervalWithIndicator(healthType: HKService.HealthType,
                                               indicatorType: IndicatorType,
                                               for timeInterval: DateInterval,
                                               bundlePrefixes: [String] = ["com.apple"],
                                               completion: @escaping (Double?) -> Void)
    {
        self.healthService.readData(type: healthType, interval: timeInterval, ascending: true, bundlePrefixes: bundlePrefixes)
        { [weak self] _, sleepData, _ in
            completion(self?.generalStatisticsProvider.getDataWithIndicator(for: healthType, for: indicatorType, sleepData: sleepData))
        }
    }

    /// Возвращает значение метадаты по любому типу здоровья, по соответствующему индикатору и в нужном интервале времени
    public func getMetaDataByIntervalWithIndicator(healthType: HKService.HealthType,
                                                   indicatorType _: IndicatorType,
                                                   for timeInterval: DateInterval,
                                                   bundlePrefixes _: [String] = ["com.apple"],
                                                   completion: @escaping (Double?) -> Void)
    {
        self.healthService.readMetaData(key: healthType.metaDataKey, interval: timeInterval, ascending: true)
        { _, data, _ in
            completion(data)
        }
    }

    /// Возвращает значение по любому типу здоровья в нужном интервале времени (без индикатора)
    public func getDataByInterval(healthType: HKService.HealthType,
                                  for timeInterval: DateInterval,
                                  bundlePrefixes: [String] = ["com.apple"],
                                  completion: @escaping ([Double]) -> Void)
    {
        self.healthService.readData(type: healthType, interval: timeInterval, ascending: true, bundlePrefixes: bundlePrefixes)
        { [weak self] _, samples, _ in
            switch healthType
            {
            case .energy:
                if let healthData = samples as? [HKQuantitySample]
                {
                    let data = healthData.map { SampleData(date: $0.startDate, value: $0.quantity.doubleValue(for: HKUnit.kilocalorie())) }
                    completion(self?.generalStatisticsProvider.getData(for: healthType, sleepData: data) ?? [])
                }
            case .heart, .respiratory:
                if let healthData = samples as? [HKQuantitySample]
                {
                    let data = healthData.map { SampleData(date: $0.startDate, value: $0.quantity.doubleValue(for: HKUnit(from: "count/min"))) }
                    completion(self?.generalStatisticsProvider.getData(for: healthType, sleepData: data) ?? [])
                }
            case .asleep, .inbed:
                if let healthData = samples
                {
                    let data = healthData.map { abs(Double($0.startDate.minutes(from: $0.endDate))) }
                    completion(data)
                }
            }
        }
    }
}

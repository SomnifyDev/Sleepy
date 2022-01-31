// Copyright (c) 2022 Sleepy.

import Foundation
import HealthKit
import HKCoreSleep
import SwiftUI
import UIComponents

public final class HKStatisticsProvider {
    private let healthService: HKService
    private let sleep: Sleep?
    private let numericTypesStatisticsProvider: HKNumericTypesStatisticsProvider
    private let phasesStatisticsProvider = HKPhasesStatisticsProvider()
    private let sleepStatisticsProvider = HKSleepStatisticsProvider()
    private let generalStatisticsProvider = HKGeneralStatisticsProvider()
    private let dailyStatisticsProvider = HKDailyStatisticsProvider()

    // MARK: - Init

    public init(sleep: Sleep?, healthService: HKService) {
        self.sleep = sleep
        self.healthService = healthService
        self.numericTypesStatisticsProvider = HKNumericTypesStatisticsProvider(healthService: healthService)
    }

    // MARK: - Public methods

    /// Returns numeric data (heart, energy etc) by data type with indicator (min, max etc)
    public func getData(
        dataType: NumericData,
        indicator: Indicator,
        roundPlaces: Int = 2
    ) -> Double? {
        guard let sleep = sleep
        else {
            return nil
        }
        return self.numericTypesStatisticsProvider.numericData(dataType: dataType, indicator: indicator, sleep: sleep)?.rounded(toPlaces: roundPlaces)
    }

    /// Returns phases data by data type
    public func getData(dataType: PhasesData) -> Any? {
        guard let sleep = sleep
        else {
            return nil
        }

        return self.phasesStatisticsProvider.phasesData(dataType: dataType, data: sleep.phases)
    }

    /// Returns sleep data by data type
    public func getData(dataType: SleepData) -> Int? {
        guard let sleep = sleep
        else {
            return nil
        }
        return self.sleepStatisticsProvider.sleepData(dataType: dataType, sleep: sleep)
    }

    /// Returns metrics data like ssdn of heart rythems by metric type
    public func getData(dataType: MetricsData, interval: DateInterval, completion: @escaping (StatsIndicatorModel?) -> Void)
    {
        switch dataType {
        case .rmssd:
            self.numericTypesStatisticsProvider.calculateRMSSD(interval: interval, completion: completion)
        case .ssdn:
            self.numericTypesStatisticsProvider.calculateSSDN(interval: interval, completion: completion)
        }
    }

    /// Returns today sleep hata of special health type (energy, heart, asleep, inbed, respiratory)
    public func getTodaySleepData(healthtype: HKService.HealthType) -> [Double] {
        guard let sleep = sleep
        else {
            return []
        }
        return self.dailyStatisticsProvider.data(healthtype: healthtype, sleep: sleep)
    }

    /// Returns today sleep interval with interval type (inbed, asleep)
    public func getTodaySleepInterval(intervalType: SleepInterval) -> DateInterval? {
        guard let sleep = sleep
        else {
            return nil
        }
        return self.dailyStatisticsProvider.intervalBoundary(intervalType: intervalType, sleep: sleep)
    }

    /// Returns metrics data like ssdn of heart rythems by metric type split by days
    public func getMetricDataByDays(dataType: MetricsData, interval: DateInterval, completion: @escaping ([StatsIndicatorModel?]) -> Void)
    {
        let group = DispatchGroup()

        let daysInInterval = Date.daysBetween(start: interval.start, end: interval.end)
        var result = [StatsIndicatorModel?](repeating: nil, count: Date.daysBetween(start: interval.start, end: interval.end) + 1)
        for index in 1 ... daysInInterval {
            if let dayDate = Calendar.current.date(byAdding: .day, value: index - 1, to: interval.start)
            {
                group.enter()
                DispatchQueue.main.async(flags: .barrier) { [weak self] in
                    switch dataType {
                    case .rmssd:
                        self?.numericTypesStatisticsProvider.calculateRMSSD(interval: .init(start: dayDate.startOfDay, end: dayDate.endOfDay))
                            { model in
                                result[index] = model
                                group.leave()
                            }
                    case .ssdn:
                        self?.numericTypesStatisticsProvider.calculateSSDN(interval: .init(start: dayDate.startOfDay, end: dayDate.endOfDay))
                            { model in
                                result[index] = model
                                group.leave()
                            }
                    }
                }
            }
        }

        group.notify(queue: .main) {
            completion(result)
        }
    }

    public func getIntervalDataByDays(
        healthType: HKService.HealthType,
        indicator: Indicator,
        interval: DateInterval,
        bundlePrefixes: [String] = ["com.apple"],
        completion: @escaping ([Double]) -> Void
    ) {
        let group = DispatchGroup()

        let daysInInterval = Date.daysBetween(start: interval.start, end: interval.end)
        var result = [Double](repeating: 0, count: Date.daysBetween(start: interval.start, end: interval.end) + 1)

        for index in 0 ... daysInInterval {
            if let dayDate = Calendar.current.date(byAdding: .day, value: index, to: interval.start)
            {
                group.enter()
                DispatchQueue.main.async(flags: .barrier) { [weak self] in
                    if healthType == .inbed || healthType == .asleep {
                        self?.healthService.readData(
                            type: healthType,
                            interval: .init(start: dayDate.startOfDay, end: dayDate.endOfDay),
                            ascending: true,
                            bundlePrefixes: bundlePrefixes
                        ) { [weak self] _, sleepData, _ in
                            result[index] = self?.generalStatisticsProvider.data(healthType: healthType, indicator: indicator, data: sleepData ?? []) ?? 0.0
                            group.leave()
                        }
                    } else {
                        self?.getMetaData(
                            healthType: healthType,
                            indicator: .sum,
                            interval: .init(start: dayDate.startOfDay, end: dayDate.endOfDay),
                            bundlePrefixes: bundlePrefixes
                        ) { value in
                            result[index] = value ?? 0.0
                            group.leave()
                        }
                    }
                }
            }
        }

        group.notify(queue: .main) {
            completion(result)
        }
    }

    /// Returns data by interval with health type and indicator from CoreSleep
    public func getData(
        healthType: HKService.HealthType,
        indicator: Indicator,
        interval: DateInterval,
        bundlePrefixes: [String] = ["com.apple"],
        completion: @escaping (Double?) -> Void
    ) {
        self.healthService.readData(
            type: healthType,
            interval: interval,
            ascending: true,
            bundlePrefixes: bundlePrefixes
        ) { [weak self] _, sleepData, _ in
            completion(self?.generalStatisticsProvider.data(healthType: healthType, indicator: indicator, data: sleepData ?? []))
        }
    }

    /// Returns  data by interval with health type from CoreSleep
    public func getData(
        healthType: HKService.HealthType,
        interval: DateInterval,
        bundlePrefixes: [String] = ["com.apple"],
        completion: @escaping ([Double]) -> Void
    ) {
        self.healthService.readData(
            type: healthType,
            interval: interval,
            ascending: true,
            bundlePrefixes: bundlePrefixes
        ) { [weak self] _, samples, _ in
            switch healthType {
            case .energy:
                if let samples = samples as? [HKQuantitySample] {
                    let data = samples.map { SampleData(date: $0.startDate, value: $0.quantity.doubleValue(for: HKUnit.kilocalorie())) }
                    completion(self?.generalStatisticsProvider.data(healthType: healthType, data: data) ?? [])
                }
            case .heart, .respiratory:
                if let samples = samples as? [HKQuantitySample] {
                    let data = samples.map { SampleData(date: $0.startDate, value: $0.quantity.doubleValue(for: HKUnit(from: "count/min"))) }
                    completion(self?.generalStatisticsProvider.data(healthType: healthType, data: data) ?? [])
                }
            case .asleep, .inbed:
                if let samples = samples {
                    let data = samples.map { abs(Double($0.startDate.minutes(from: $0.endDate))) }
                    completion(data)
                }
            }
        }
    }

    /// Returns meta data by interval with health type and indicator
    public func getMetaData(
        healthType: HKService.HealthType,
        indicator _: Indicator,
        interval: DateInterval,
        bundlePrefixes _: [String] = ["com.apple"],
        completion: @escaping (Double?) -> Void
    ) {
        self.healthService.readMetaData(
            key: healthType.metaDataKey,
            interval: interval,
            ascending: true
        ) { _, data, _ in
            completion(data)
        }
    }
}

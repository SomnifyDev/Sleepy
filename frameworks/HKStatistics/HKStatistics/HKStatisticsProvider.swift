import Foundation
import HealthKit
import HKCoreSleep

public final class HKStatisticsProvider {

    // MARK: - Properties

    private let healthService: HKService
    private let sleep: Sleep?
    private let numericTypesStatisticsProvider = HKNumericTypesStatisticsProvider()
    private let phasesStatisticsProvider = HKPhasesStatisticsProvider()
    private let sleepStatisticsProvider = HKSleepStatisticsProvider()
    private let generalStatisticsProvider = HKGeneralStatisticsProvider()
    private let dailyStatisticsProvider = HKDailyStatisticsProvider()

    // MARK: - Init

    public init(sleep: Sleep?, healthService: HKService) {
        self.sleep = sleep
        self.healthService = healthService
    }

    // MARK: - Public methods

    /// Returns numeric data (heart, energy etc) by data type with indicator (min, max etc)
    public func getData(
        _ dataType: NumericData,
        _ indicator: Indicator,
        roundPlaces: Int = 2
    ) -> Double? {
        guard let sleep = sleep else {
            return nil
        }
        return numericTypesStatisticsProvider.numericData(dataType: dataType, indicator: indicator, sleep: sleep)?.rounded(toPlaces: roundPlaces)
    }

    /// Returns phases data by data type
    public func getData(_ dataType: PhasesData) -> Any? {
        guard let sleep = sleep else {
            return nil
        }
        return phasesStatisticsProvider.phasesData(dataType: dataType, data: sleep.phases)
    }

    /// Returns sleep data by data type
    public func getData(_ dataType: SleepData) -> Int? {
        guard let sleep = sleep else {
            return nil
        }
        return sleepStatisticsProvider.sleepData(dataType: dataType, sleep: sleep)
    }

    /// Returns today sleep hata of special health type (energy, heart, asleep, inbed, respiratory)
    public func getTodaySleepData(_ healthtype: HKService.HealthType) -> [Double] {
        guard let sleep = sleep else {
            return []
        }
        return dailyStatisticsProvider.data(healthtype: healthtype, sleep: sleep)
    }

    /// Returns today sleep interval with interval type (inbed, asleep)
    public func getTodaySleepInterval(_ intervalType: SleepInterval) -> DateInterval? {
        guard let sleep = sleep else {
            return nil
        }
        return dailyStatisticsProvider.intervalBoundary(intervalType: intervalType, sleep: sleep)
    }

    /// Returns data by interval with health type and indicator from CoreSleep
    public func getData(
        _ healthType: HKService.HealthType,
        _ indicator: Indicator,
        _ interval: DateInterval,
        bundlePrefixes: [String] = ["com.apple"],
        completion: @escaping (Double?) -> ()
    ) {
        healthService.readData(
            type: healthType,
            interval: interval,
            ascending: true,
            bundlePrefixes: bundlePrefixes
        ) { [weak self] _, sleepData, _ in
            completion(self?.generalStatisticsProvider.data(healthType: healthType, indicator: indicator, data: sleepData ?? []))
        }
    }

    /// Returns meta data by interval with health type from CoreSleep
    public func getData(
        _ healthType: HKService.HealthType,
        _ interval: DateInterval,
        bundlePrefixes: [String] = ["com.apple"],
        completion: @escaping ([Double]) -> ()
    ) {
        healthService.readData(
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
        _ healthType: HKService.HealthType,
        _ indicatorType: Indicator,
        _ interval: DateInterval,
        bundlePrefixes: [String] = ["com.apple"],
        completion: @escaping (Double?) -> ()
    ) {
        healthService.readMetaData(
            key: healthType.metaDataKey,
            interval: interval,
            ascending: true
        ) { _, data, _ in
            completion(data)
        }
    }

}

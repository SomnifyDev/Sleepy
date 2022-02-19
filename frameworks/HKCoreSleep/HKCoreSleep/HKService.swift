// Copyright (c) 2022 Sleepy.

import Foundation
import HealthKit

public class HKService {
    public enum HealthType: String, CaseIterable {
        case energy, heart, asleep, inbed, respiratory

        public var hkValue: HKSampleType {
            switch self {
            case .energy:
                return HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)!
            case .heart:
                return HKSampleType.quantityType(forIdentifier: .heartRate)!
            case .asleep:
                return HKSampleType.categoryType(forIdentifier: .sleepAnalysis)!
            case .inbed:
                return HKSampleType.categoryType(forIdentifier: .sleepAnalysis)!
            case .respiratory:
                return HKSampleType.quantityType(forIdentifier: .respiratoryRate)!
            }
        }

        public var metaDataKey: String {
            switch self {
            case .energy:
                return "Energy consumption"
            case .heart:
                return "Heart rate mean"
            case .respiratory:
                return "Respiratory rate"
            default:
                fatalError("should be used like that")
            }
        }
    }

    public enum BundleAuthor {
        case sleepy
        case apple

        var bundles: [String] {
            switch self {
            case .sleepy:
                return ["com.benmustafa", "com.sinapsis"]
            case .apple:
                return ["com.apple"]
            }
        }
    }

    public init() {}

    // MARK: Private properties

    public static let healthStore = HKHealthStore()

    private static var readDataTypes: Set<HKObjectType> = [
        HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
        HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
        HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.respiratoryRate)!,
        HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!,
        HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
        HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!,
    ]

    private static var writeDataTypes: Set<HKSampleType> = [HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!]

    // MARK: - Private methods

    /// Проверка на наличие прав для сохранения
    /// - Parameters:
    ///   - type: тип данных для сохранения
    ///   - completionHandler: completionHandler
    private static func checkSavePermissions(type: HKService.HealthType, completionHandler: @escaping (Bool, Error?) -> Void) {
        let authorizationStatus = self.healthStore.authorizationStatus(for: type.hkValue)

        switch authorizationStatus {
        case .sharingAuthorized:
            completionHandler(true, nil)

        case .sharingDenied:
            self.healthStore.requestAuthorization(toShare: self.writeDataTypes, read: self.readDataTypes, completion: completionHandler)

        default:
            print("not determined")
            self.healthStore.requestAuthorization(toShare: self.writeDataTypes, read: self.readDataTypes, completion: completionHandler)
        }
    }

    /// Проверка на права чтения
    ///
    /// Из-за огранечний эпла в плане безопасности нативного апи для проверки нет.
    /// см. https://stackoverflow.com/questions/53203701/check-if-user-has-authorised-steps-in-healthkit
    ///
    /// Теоретически пользователь может быть новичком и тогда checkReadPermissions подумает, что права не были выданы
    /// на inbed asleep, но ведь пользователь просто не пользовался раньше отслеживанием сна.
    ///
    /// В случае сомнений в выдаче прав Sleepy максимум что сделает - откроет вью с их запросом еще раз
    ///
    /// - Parameters:
    ///   - type: тип данных для чтения
    ///   - completionHandler: completionHandler
    private func checkReadPermissions(type: HKService.HealthType, completionHandler: @escaping (Bool, Error?) -> Void) {
        self.readDataLast(type: type, completionHandler: { _, samples, error in
            if error != nil || ((type == .asleep || type == .inbed) && (samples ?? []).isEmpty) {
                HKService.healthStore.requestAuthorization(toShare: HKService.writeDataTypes, read: HKService.readDataTypes, completion: completionHandler)
            } else if error != nil && (samples ?? []).isEmpty {
                HKService.healthStore.requestAuthorization(toShare: HKService.writeDataTypes, read: HKService.readDataTypes, completion: completionHandler)
            } else {
                completionHandler(true, error)
            }
        })
    }

    // MARK: Public methods

    public static func readBirthday() -> DateComponents? {
        return try? self.healthStore.dateOfBirthComponents()
    }

    public static func readSex() -> HKBiologicalSexObject? {
        return try? self.healthStore.biologicalSex()
    }

    public static func requestPermissions(completion: @escaping (Bool, Error?) -> Void) {
        self.healthStore.requestAuthorization(toShare: self.writeDataTypes, read: self.readDataTypes, completion: completion)
    }

    /// Разрешает обновления в фоне для типов здоровья в которых мы заинтересованы, iOS разбудит приложение когда будет возможно.
    /// - Parameters:
    ///   - completionHandler: completionHandler
    public func enableBackgroundDelivery(completionHandler: @escaping (Bool, Error?) -> Void) {
        for type in [HealthType.asleep.hkValue] {
            HKService.healthStore.enableBackgroundDelivery(for: type, frequency: .immediate, withCompletion: completionHandler)
        }
    }

    /// Функция для чтения данныз здоровья из хранилища HealthKit
    /// - Parameters:
    ///   - type: тип данных для чтения
    ///   - interval: временной интервал в котором мы хотим их прочитать
    ///   - ascending: по возрастанию (временному) ли вернуть значения
    ///   - bundlePrefix: Автор сэмплов, которые хотим прочитать (Apple или Sleepy)
    ///   - completionHandler: completionHandler
    public func readData(
        type: HKService.HealthType,
        interval: DateInterval?,
        ascending: Bool = false,
        bundleAuthor: BundleAuthor,
        limit: Int = 100_000,
        completionHandler: @escaping (HKSampleQuery?, [HKSample]?, Error?) -> Void
    ) {
        self.checkReadPermissions(type: type) { _, error in
            if error == nil {
                var predicate: NSPredicate?
                if let interval = interval {
                    predicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end, options: [.strictEndDate])
                }

                let sortDescriptors = [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: ascending)]
                let query: HKSampleQuery
                if type != .asleep, type != .inbed {
                    query = HKSampleQuery(
                        sampleType: type.hkValue,
                        predicate: predicate,
                        limit: limit,
                        sortDescriptors: sortDescriptors,
                        resultsHandler: completionHandler
                    )
                } else {
                    query = HKSampleQuery(
                        sampleType: type.hkValue,
                        predicate: predicate,
                        limit: limit,
                        sortDescriptors: sortDescriptors,
                        resultsHandler: { sampleQuery, samples, error in
                            let samplesFiltered = samples?.filter { sample in
                                (bundleAuthor.bundles.contains(where: { sample.sourceRevision.source.bundleIdentifier.hasPrefix($0) })) &&
                                    (sample as? HKCategorySample)?.value == ((type == .asleep)
                                        ? HKCategoryValueSleepAnalysis.asleep.rawValue
                                        : HKCategoryValueSleepAnalysis.inBed.rawValue)
                            }
                            completionHandler(sampleQuery, samplesFiltered, error)
                        }
                    )
                }

                HKService.healthStore.execute(query)
            } else {
                completionHandler(nil, [], error)
            }
        }
    }

    /// Функция для чтения метаданных из сэмплов здоровья (время, статистику и тд)
    /// - Parameters:
    ///   - key: ключ метаданных для чтения
    ///   - interval: интервал сэмплов, во временном промежутке котором мы хотим получить данные
    ///   - completionHandler: completionHandler
    public func readMetaData(
        key: String,
        interval: DateInterval,
        ascending: Bool = false,
        completionHandler: @escaping (HKSampleQuery?, Double?, Error?) -> Void
    ) {
        self.checkReadPermissions(type: .asleep) { _, error in
            if error == nil {
                let datePredicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end, options: [])
                let myAppPredicate = HKQuery.predicateForObjects(from: HKSource.default()) // This would retrieve only my app's data
                let sortDescriptors = [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: ascending)]
                let queryPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, myAppPredicate])

                let query = HKSampleQuery(
                    sampleType: HKService.HealthType.asleep.hkValue,
                    predicate: queryPredicate,
                    limit: 50,
                    sortDescriptors: sortDescriptors,
                    resultsHandler: { sampleQuery, samples, error in
                        guard error == nil else {
                            completionHandler(sampleQuery, 0, error)
                            return
                        }

                        let samplesFiltered = samples?.filter { sample in
                            (sample as? HKCategorySample)?.value == HKCategoryValueSleepAnalysis.asleep.rawValue
                        }

                        var result: Double = samplesFiltered?.reduce(0.0) { Double($0.metadata?[key] as? String ?? "") + Double($1.metadata?[key] as? String ?? "") }
                        completionHandler(sampleQuery, result, error)
                    }
                )

                HKService.healthStore.execute(query)
            } else {
                completionHandler(nil, nil, error)
                return
            }
        }
    }

    /// Получение последнего сэмпла (самого нового) из базы данных
    /// Важно помнить что для хранилища типы  inbed == asleep
    public func readDataLast(type: HKService.HealthType, completionHandler: @escaping (HKSampleQuery?, [HKSample]?, Error?) -> Void) {
        let sortDescriptor = [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date.distantFuture, options: [])

        let query = HKSampleQuery(
            sampleType: type.hkValue,
            predicate: predicate,
            limit: 1,
            sortDescriptors: sortDescriptor,
            resultsHandler: completionHandler
        )

        HKService.healthStore.execute(query)
    }

    /// Сохранение сэмплов в хранилище HealthKit
    /// Важно помнить что для хранилища типы  inbed == asleep
    public func writeData(objects: [HKSample], type: HKService.HealthType, completionHandler: @escaping (Bool, Error?) -> Void) {
        HKService.checkSavePermissions(type: type) { _, error in
            if error == nil {
                HKService.healthStore.save(objects, withCompletion: completionHandler)
            } else {
                completionHandler(false, error)
            }
        }
    }
}

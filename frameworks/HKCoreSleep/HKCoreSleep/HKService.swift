// Copyright (c) 2021 Sleepy.

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

    /// Checking for save permissions
    /// - Parameters:
    ///   - type: health type you want be able to save
    ///   - completionHandler: result that contains boolean value indicating your permissions and error if it occured during func work
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

    /// Checking for read permissions
    /// - Parameters:
    ///   - type: health type you want be able to read
    ///   - completionHandler: result that contains boolean value indicating your permissions and error if it occured during func work
    private func checkReadPermissions(type: HKService.HealthType, completionHandler: @escaping (Bool, Error?) -> Void) {
        // Why did i code so?
        // https://stackoverflow.com/questions/53203701/check-if-user-has-authorised-steps-in-healthkit
        self.readDataLast(type: type, completionHandler: { _, samples, error in
            if error != nil || ((type == .asleep || type == .inbed) && (samples ?? []).isEmpty) {
                // теоретически пользователь может быть новичком и тогда checkReadPermissions подумает, что права не были выданы
                // на inbed asleep, но ведь пользователь просто не пользовался раньше отслеживанием сна
                // поэтому на сто процентов убедиться не можем - убрал в if выше  || (samples ?? []).isEmpty
                HKService.healthStore.requestAuthorization(toShare: HKService.writeDataTypes, read: HKService.readDataTypes, completion: completionHandler)
            } else if error != nil && (samples ?? []).isEmpty {
                // а др семплы (сердце, энергия точно должны быть ибо они начинают записываться с первых минут пользования
                // Если офк юзер вручную не отключил это лол
                // TODO: обработать юзеров, отключивших сердце и энергию к записи
                HKService.healthStore.requestAuthorization(toShare: HKService.writeDataTypes, read: HKService.readDataTypes, completion: { _, _ in })
                self.checkReadPermissions(type: .heart, completionHandler: completionHandler)
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

    /// Enables background updates for the types we're interested, iOS will wake app up when possible, and this triggers our object queries later.
    ///
    /// - Parameters:
    ///   - completionHandler: result that contains boolean value indicating if enabled state and error if it occured during func work
    public func enableBackgroundDelivery(completionHandler: @escaping (Bool, Error?) -> Void) {
        for type in [HealthType.asleep.hkValue] {
            HKService.healthStore.enableBackgroundDelivery(for: type, frequency: .immediate, withCompletion: completionHandler)
        }
    }

    /// Function to read data from HealthKit storage
    /// Be awate that inbed == asleep == Sleep samples
    /// - Parameters:
    ///   - type: health sample type you want to read
    ///   - interval: time interval for your desired samples
    ///   - ascending: boolean value indicating your need in ascending order sorting
    ///   - bundlePrefix: bundle prefix of application that created samples you want to read. Do not pass anything if you want every application samples
    ///   - completionHandler: completion with success or failure of this operation and data
    public func readData(type: HKService.HealthType,
                         interval: DateInterval?,
                         ascending: Bool = false,
                         bundlePrefixes: [String] = [],
                         limit: Int = 100_000,
                         completionHandler: @escaping (HKSampleQuery?, [HKSample]?, Error?) -> Void)
    {
        self.checkReadPermissions(type: type) { _, error in
            if error == nil {
                var predicate: NSPredicate? = nil
                if let interval = interval {
                    predicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end, options: [.strictEndDate])
                }

                let sortDescriptors = [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: ascending)]

                if type != .asleep, type != .inbed {
                    let query = HKSampleQuery(sampleType: type.hkValue,
                                              predicate: predicate,
                                              limit: limit,
                                              sortDescriptors: sortDescriptors,
                                              resultsHandler: completionHandler)

                    HKService.healthStore.execute(query)
                } else {

                    let query = HKSampleQuery(sampleType: type.hkValue,
                                              predicate: predicate,
                                              limit: limit,
                                              sortDescriptors: sortDescriptors,
                                              resultsHandler: { sampleQuery, samples, error in

                        // trying to fiter samples by bundle we need and type if inbed/asleep requested
                        let samplesFiltered = samples?.filter { sample in
                            (!bundlePrefixes.isEmpty
                             ? bundlePrefixes.contains(where: { sample.sourceRevision.source.bundleIdentifier.hasPrefix($0) })
                             : true) &&
                            (sample as? HKCategorySample)?.value == ((type == .asleep)
                                                                     ? HKCategoryValueSleepAnalysis.asleep.rawValue
                                                                     : HKCategoryValueSleepAnalysis.inBed.rawValue)
                        }
                        completionHandler(sampleQuery, samplesFiltered, error)
                        return
                    })

                    HKService.healthStore.execute(query)
                }

            } else {
                completionHandler(nil, [], error)
            }
        }
    }

    public func readMetaData(key: String,
                             interval: DateInterval,
                             ascending: Bool = false,
                             completionHandler: @escaping (HKSampleQuery?, Double?, Error?) -> Void)
    {
        self.checkReadPermissions(type: .inbed) { _, error in

            if error == nil {
                let datePredicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end, options: [])
                let myAppPredicate = HKQuery.predicateForObjects(from: HKSource.default()) // This would retrieve only my app's data
                let sortDescriptors = [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: ascending)]
                let queryPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, myAppPredicate])

                let query = HKSampleQuery(sampleType: HKService.HealthType.inbed.hkValue,
                                          predicate: queryPredicate,
                                          limit: 50,
                                          sortDescriptors: sortDescriptors,
                                          resultsHandler: { sampleQuery, samples, error in

                    let samplesFiltered = samples?.filter { sample in
                        (sample as? HKCategorySample)?.value == HKCategoryValueSleepAnalysis.inBed.rawValue
                    }

                    if let metadata = samplesFiltered?.first?.metadata {
                        completionHandler(sampleQuery, Double(metadata[key] as? String ?? ""), error)
                        return
                    }
                })

                HKService.healthStore.execute(query)

            } else {
                completionHandler(nil, nil, error)
            }
        }
    }

    /// Gets last sample in database
    /// Be awate that inbed == asleep == Sleep samples
    /// - Parameters:
    ///   - type: health type you want be able to read
    ///   - completionHandler: result that contains boolean value indicating samples if so and error if it occured during func work
    public func readDataLast(type: HKService.HealthType, completionHandler: @escaping (HKSampleQuery?, [HKSample]?, Error?) -> Void) {
        // We want descending order to get the most recent date FIRST
        let sortDescriptor = [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date.distantFuture, options: [])

        let query = HKSampleQuery(sampleType: type.hkValue,
                                  predicate: predicate,
                                  limit: 1,
                                  sortDescriptors: sortDescriptor,
                                  resultsHandler: completionHandler)

        HKService.healthStore.execute(query)
    }
    
    /// Function to save samples into HealthKit storage
    /// Be awate that inbed == asleep == Sleep samples
    /// - Parameters:
    ///   - objects: objects to write into storage
    ///   - type: health sample type
    ///   - completionHandler: completion with success or failure of this operation
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

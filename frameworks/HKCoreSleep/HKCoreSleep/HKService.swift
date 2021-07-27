import Foundation
import HealthKit

public class HKService {

    public enum HealthType {
        case energy, heart, asleep, inbed

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
            }
        }

        public var metaDataKey: String {
            switch self {
            case .energy:
                return "Energy Consumption"
            case .heart:
                return "Heart rate mean"
            case .asleep:
                return ""
            case .inbed:
                return ""
            }
        }
    }

    // MARK: Init

    public init() {
    }

    // MARK: Private properties

    public let healthStore = HKHealthStore()

    private var readDataTypes: Set<HKSampleType> = [
        HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
        HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
        HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!,
    ]

    private var writeDataTypes: Set<HKSampleType> = [HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!]

    // MARK: - Private methods

    /// Checking for save permissions
    /// - Parameters:
    ///   - type: health type you want be able to save
    ///   - completionHandler: result that contains boolean value indicating your permissions and error if it occured during func work
    private func checkSavePermissions(type: HealthType, completionHandler: @escaping (Bool, Error?) -> Void) {
        let authorizationStatus = healthStore.authorizationStatus(for: type.hkValue)

        switch authorizationStatus {

        case .sharingAuthorized:
            completionHandler(true, nil)

        case .sharingDenied:
            healthStore.requestAuthorization(toShare: writeDataTypes, read: readDataTypes, completion: completionHandler)

        default:
            print("not determined")
            healthStore.requestAuthorization(toShare: writeDataTypes, read: readDataTypes, completion: completionHandler)

        }
    }

    /// Checking for read permissions
    /// - Parameters:
    ///   - type: health type you want be able to read
    ///   - completionHandler: result that contains boolean value indicating your permissions and error if it occured during func work
    private func checkReadPermissions(type: HealthType, completionHandler: @escaping (Bool, Error?) -> Void) {
        // Why did i code so?
        // https://stackoverflow.com/questions/53203701/check-if-user-has-authorised-steps-in-healthkit
        self.readDataLast(type: type, completionHandler: { query, samples, error in
            if error != nil || ( (type == .asleep || type == .inbed) && (samples ?? []).isEmpty) {
                // теоретически пользователь может быть новичком и тогда checkReadPermissions подумает, что права не были выданы
                // на inbed asleep, но ведь пользователь просто не пользовался раньше отслеживанием сна
                // поэтому на сто процентов убедиться не можем - убрал в if выше  || (samples ?? []).isEmpty
                self.healthStore.requestAuthorization(toShare: self.writeDataTypes, read: self.readDataTypes, completion: completionHandler)
            } else if error != nil && (samples ?? []).isEmpty {
                // а др семплы (сердце, энергия точно должны быть ибо они начинают записываться с первых минут пользования
                // Если офк юзер вручную не отключил это лол
                // TODO: обработать юзеров, отключивших сердце и энергию к записи
                self.healthStore.requestAuthorization(toShare: self.writeDataTypes, read: self.readDataTypes, completion: { _, _ in})
                self.checkReadPermissions(type: .heart, completionHandler: completionHandler)
            } else {
                completionHandler(true, error)
            }
        })
    }

    // MARK: Public methods

    /// Enables background updates for the types we're interested, iOS will wake app up when possible, and this triggers our object queries later.
    ///
    /// - Parameters:
    ///   - completionHandler: result that contains boolean value indicating if enabled state and error if it occured during func work
    public func enableBackgroundDelivery(completionHandler: @escaping (Bool, Error?) -> Void) {
        for type in [HealthType.asleep.hkValue] {
            healthStore.enableBackgroundDelivery(for: type, frequency: .immediate, withCompletion: completionHandler)
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
    public func readData(type: HealthType,
                         interval: DateInterval,
                         ascending: Bool = false,
                         bundlePrefixes: [String] = [],
                         completionHandler: @escaping (HKSampleQuery?, [HKSample]?, Error?) -> Void) {
        checkReadPermissions(type: type) { result, error in
            if error == nil {

                let predicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end, options: [])
                let sortDescriptors = [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: ascending)]

                if type != .asleep && type != .inbed {
                    let query = HKSampleQuery(sampleType: type.hkValue,
                                              predicate: predicate,
                                              limit: 100000,
                                              sortDescriptors: sortDescriptors,
                                              resultsHandler: completionHandler)

                    self.healthStore.execute(query)
                } else {
                    let query = HKSampleQuery(sampleType: type.hkValue,
                                              predicate: predicate,
                                              limit: 100000,
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
                    })

                    self.healthStore.execute(query)
                }

            } else {
                completionHandler(nil, [], error)
            }
        }
    }

    public func readMetaData(key: String,
                             interval: DateInterval,
                             ascending: Bool = false,
                             completionHandler: @escaping (HKSampleQuery?, Double?, Error?) -> Void) {
        checkReadPermissions(type: .inbed) { result, error in
            if error == nil {

                let datePredicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end, options: [])
                let myAppPredicate = HKQuery.predicateForObjects(from: HKSource.default()) // This would retrieve only my app's data
                let sortDescriptors = [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: ascending)]
                let queryPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, myAppPredicate])


                let query = HKSampleQuery(sampleType: HealthType.inbed.hkValue,
                                          predicate: queryPredicate,
                                          limit: 100000,
                                          sortDescriptors: sortDescriptors,
                                          resultsHandler: { sampleQuery, samples, error in

                    let samplesFiltered = samples?.filter { sample in
                        (sample as? HKCategorySample)?.value == HKCategoryValueSleepAnalysis.inBed.rawValue
                    }

                    if let metadata = samplesFiltered?.first?.metadata {
                        completionHandler(sampleQuery, metadata[key] as? Double, error)
                        return
                    }
                })

                self.healthStore.execute(query)

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
    public func readDataLast(type: HealthType, completionHandler: @escaping (HKSampleQuery?, [HKSample]?, Error?) -> Void ) {
        // We want descending order to get the most recent date FIRST
        let sortDescriptor = [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date.distantFuture, options: [])

        let query = HKSampleQuery(sampleType: type.hkValue,
                                  predicate: predicate,
                                  limit: 1,
                                  sortDescriptors: sortDescriptor,
                                  resultsHandler: completionHandler)

        self.healthStore.execute(query)
    }

    /// Function to save samples into HealthKit storage
    /// Be awate that inbed == asleep == Sleep samples
    /// - Parameters:
    ///   - objects: objects to write into storage
    ///   - type: health sample type
    ///   - completionHandler: completion with success or failure of this operation
    public func writeData(objects: [HKSample], type: HealthType, completionHandler: @escaping (Bool, Error?) -> Void) {
        checkSavePermissions(type: type) { result, error in
            if error == nil {
                self.healthStore.save(objects, withCompletion: completionHandler)
            } else {
                completionHandler(false, error)
            }
        }
    }

}

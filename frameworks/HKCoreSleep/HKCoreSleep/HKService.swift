import Foundation
import HealthKit

public class HKService {

    public enum HealthType {
        case energy, heart, asleep, inbed

        var hkValue: HKSampleType {
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
    }

    // MARK: Init

    public init() {
    }

    // MARK: Private properties

    private let healthStore = HKHealthStore()

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

        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date.distantFuture, options: [])

        let heartRateQuery = HKSampleQuery(sampleType: type.hkValue,
                                           predicate: predicate,
                                           limit: 1,
                                           sortDescriptors: nil,
                                           resultsHandler: { query, samples, error in
            if error != nil || (samples ?? []).isEmpty {
                completionHandler(false, error)
            } else {
                completionHandler(true, error)
            }
        })

        self.healthStore.execute(heartRateQuery)
    }

    // MARK: Public methods

    /// Function to read data from HealthKit storage
    /// - Parameters:
    ///   - type: health sample type you want to read
    ///   - interval: time interval for your desired samples
    ///   - ascending: boolean value indicating your need in ascending order sorting
    ///   - bundlePrefix: bundle prefix of application that created samples you want to read. Do not pass anything if you want every application samples
    ///   - completionHandler: completion with success or failure of this operation and data
    public func readData(type: HealthType, interval: DateInterval, ascending: Bool = false, bundlePrefix: String = "", completionHandler: @escaping (HKSampleQuery?, [HKSample]?, Error?) -> Void) {
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

                        let samplesFiltered = samples?.filter {
                            (bundlePrefix != "" ? $0.sourceRevision.source.bundleIdentifier.hasPrefix(bundlePrefix) : true) &&
                            ($0 as? HKCategorySample)?.value == ((type == .asleep)
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

    /// Function to save samples into HealthKit storage
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

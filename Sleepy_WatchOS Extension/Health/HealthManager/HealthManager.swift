// Copyright (c) 2022 Sleepy.

import Foundation
import HealthKit

protocol HealthManagerDelegate: AnyObject {
    func lightPhaseDetected()
}

final class HealthManager {
    static var shared: HealthManager = {
        HealthManager()
    }()

    private let healthStore = HKHealthStore()
    private let heartDataManager = HeartDataManager()

    weak var delegate: HealthManagerDelegate?

    init() {
        self.heartDataManager.delegate = self
    }
}

// MARK: HeartDataManagerDelegate

extension HealthManager: HeartDataManagerDelegate {
    func lightPhaseDetected() {
        print("HeartDataManagerDelegate detected light phase")
        self.delegate?.lightPhaseDetected()
    }
}

// MARK: HealthKit

extension HealthManager {
    func subscribeToHeartBeatChanges() {
        // Creating the sample for the heart rate

        guard
            let sampleType: HKSampleType = HKObjectType.quantityType(forIdentifier: .heartRate)
        else {
            return
        }

        // Set up the immutable HKObserverQuery
        let heartRateQuery = HKObserverQuery(
            sampleType: sampleType,
            predicate: nil
        ) { _, completionHandler, error in
            // This is fired every time new samples are retrieved
            // This also seems to turn on active sensing to get heart rates every ~5 seconds

            guard error == nil
            else {
                print("error with observer query")
                return
            }

            // Get the actual query
            self.startHeartRateQuery(quantityTypeIdentifier: .heartRate)

            // Unclear if I actually need this, but it doesn't change anything
            completionHandler()
        }

        // Execute the actual query
        self.healthStore.execute(heartRateQuery)
    }

    private func startHeartRateQuery(quantityTypeIdentifier _: HKQuantityTypeIdentifier) {
        // Set the predicate to get only samples from the last hour
        // Could be last minute and should be just fine
        let predicate = HKQuery
            .predicateForSamples(
                withStart: Date().addingTimeInterval(-3600),
                end: Date(),
                options: []
            )

        // Sort most recent
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: false
        )

        let query = HKSampleQuery(
            sampleType: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
            predicate: predicate,
            limit: Int(1), // To get only one
            sortDescriptors: [sortDescriptor]
        ) { _, results, _ in
            // Fired when query completes
            guard
                let samples = results as? [HKQuantitySample],
                let unit = HealthType.heart.HUnit
            else {
                return
            }

            // Should only be one sample
            for s in samples {
                let heartRate = s.quantity.doubleValue(for: unit)

                // Log heart rate to my internal structure for processing
                DispatchQueue.main.async { [weak self] in
                    self?.heartDataManager.append(
                        sample: heartRate
                    )
                }
            }
        }

        self.healthStore.execute(query)
    }
}

// MARK: Permissions

extension HealthManager {
    func checkReadPermissions(
        type: HealthType,
        completionHandler: @escaping (Bool, Error?) -> Void
    ) {
        self.readDataLast(type: type, completionHandler: { _, samples, error in
            if error != nil || (samples ?? []).isEmpty {
                self.makeHealthKitRequest()
                self.checkReadPermissions(type: type, completionHandler: completionHandler)
            } else {
                completionHandler(true, error)
            }
        })
    }

    private func readDataLast(
        type: HealthType,
        completionHandler: @escaping (HKSampleQuery?, [HKSample]?, Error?) -> Void
    ) {
        guard let healthKitValue = type.HSample
        else {
            return
        }

        let sortDescriptor = [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date.distantFuture, options: [])
        let query = HKSampleQuery(
            sampleType: healthKitValue,
            predicate: predicate,
            limit: 1,
            sortDescriptors: sortDescriptor,
            resultsHandler: completionHandler
        )
        self.healthStore.execute(query)
    }

    private func makeHealthKitRequest() {
        guard
            let heartRate = HealthType.heart.HSample,
            let activeEnergyBurned = HealthType.activeBurnedEnergy.HSample
        else {
            return
        }

        let requiredHealthKitTypes: Set = [heartRate, activeEnergyBurned]
        self.healthStore.requestAuthorization(toShare: [], read: requiredHealthKitTypes) { _, _ in }
    }
}

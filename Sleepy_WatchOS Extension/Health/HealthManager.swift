//
//  HealthManager.swift
//  Sleepy_WatchOS Extension
//
//  Created by Анас Бен Мустафа on 10/6/21.
//

import Foundation
import HealthKit

enum HealthType {
    case heart
    case activeBurnedEnergy

    var healthKitValue: HKSampleType? {
        switch self {
        case .activeBurnedEnergy:
            return HKSampleType.quantityType(forIdentifier: .heartRate)
        case .heart:
            return HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)
        }
    }
}

final class HealthManager {

    private let healthStore = HKHealthStore()

    static var shared: HealthManager = {
        return HealthManager()
    }()

    func checkReadPermissions(
        type: HealthType,
        completionHandler: @escaping (Bool, Error?) -> Void
    ) {
        self.readDataLast(type: type, completionHandler: { query, samples, error in
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
        guard let healthKitValue = type.healthKitValue else {
            return
        }

        let sortDescriptor = [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date.distantFuture, options: [])
        let query = HKSampleQuery(sampleType: healthKitValue,
                                  predicate: predicate,
                                  limit: 1,
                                  sortDescriptors: sortDescriptor,
                                  resultsHandler: completionHandler)
        self.healthStore.execute(query)
    }

    private func makeHealthKitRequest() {
        guard
            let heartRate = HealthType.heart.healthKitValue,
            let activeEnergyBurned = HealthType.activeBurnedEnergy.healthKitValue
        else {
            return
        }

        let requiredHealthKitTypes: Set = [heartRate, activeEnergyBurned]
        healthStore.requestAuthorization(toShare: [], read: requiredHealthKitTypes) { _, _ in }
    }

}

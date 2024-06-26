// Copyright (c) 2022 Sleepy.

import Foundation
import HealthKit

enum HealthType {
    case heart
    case activeBurnedEnergy

    var HSample: HKSampleType? {
        switch self {
        case .activeBurnedEnergy:
            return HKSampleType.quantityType(forIdentifier: .heartRate)
        case .heart:
            return HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)
        }
    }

    var HUnit: HKUnit? {
        switch self {
        case .heart:
            return HKUnit(from: "count/min")
        case .activeBurnedEnergy:
            return HKUnit(from: .calorie)
        }
    }
}

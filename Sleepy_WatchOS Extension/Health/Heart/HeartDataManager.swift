//
//  HeartData.swift
//  Sleepy_WatchOS Extension
//
//  Created by Анас Бен Мустафа on 10/17/21.
//

import Foundation

typealias HeartRate = Double

// MARK: Enums

fileprivate enum LightPhaseDetectionStrategy {
    case withConfirmation
    case withoutConfirmation
}

fileprivate enum Constant {
    static let confirmativeLightPhaseFlagValue: Double = 1.05
    static let potentialLightPhaseFlagValue: Double = 1.08
    static let unconditionalLightPhaseDetectionValue: Double = 1.12
}

// MARK: HeartDataManager

final class HeartDataManager {

    // MARK: Properties

    weak var delegate: HeartDataManagerDelegate?

    private var heartRates = [HeartRate]()
    private var potentialLightPhaseDetectionFlag: Bool = false

    // MARK: Internal methods

    func append(sample: HeartRate) {
        heartRates.append(sample)
        detectLightPhase()
    }

    // MARK: Private methods

    private func detectLightPhase() {
        guard
            heartRates.count > 1,
            let last = heartRates.last,
            let preLast = heartRates.dropLast().last
        else {
            return
        }

        let differencePercentage = last / preLast
        if differencePercentage >= Constant.unconditionalLightPhaseDetectionValue {
            detectLightPhaseWithStrategy(.withoutConfirmation)
        } else {
            detectLightPhaseWithStrategy(.withConfirmation)
        }
    }

    private func detectLightPhaseWithStrategy(_ strategy: LightPhaseDetectionStrategy) {
        switch strategy {
        case .withConfirmation:
            if potentialLightPhaseDetectionFlag && isLightPhaseDetectionConfirmed() {
                delegate?.lightPhaseDetected()
            } else {
                detectPotentialLightPhase()
            }
        case .withoutConfirmation:
            delegate?.lightPhaseDetected()
        }
    }

    private func detectPotentialLightPhase() {
        guard
            let last = heartRates.last,
            let preLast = heartRates.dropLast().last,
            last / preLast >= Constant.potentialLightPhaseFlagValue
        else {
            return
        }
        potentialLightPhaseDetectionFlag = true
    }

    private func isLightPhaseDetectionConfirmed() -> Bool {
        guard
            heartRates.count > 2,
            let last = heartRates.last,
            let prePreLast = heartRates.dropLast().dropLast().last,
            last / prePreLast >= Constant.confirmativeLightPhaseFlagValue
        else {
            potentialLightPhaseDetectionFlag = false
            return false
        }
        return true
    }

}

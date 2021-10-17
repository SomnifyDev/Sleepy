//
//  HeartData.swift
//  Sleepy_WatchOS Extension
//
//  Created by Анас Бен Мустафа on 10/17/21.
//

import Foundation

final class HeartDataManager {

    private var heartRates = [HeartRateSample]()
    weak var delegate: HeartDataManagerDelegate?

    // MARK: Internal methods

    func append(sample: HeartRateSample) {
        self.heartRates.append(sample)
    }

    func isLightPhase(currentSample: HeartRateSample) {
        guard currentSample.heartRate / currentMeanValue() >= 1.2 else {
            return
        }
        delegate?.lightPhaseDetected()
    }

    // MARK: Private methods

    private func currentMeanValue() -> Double {
        return heartRates.reduce(0.0) { $0 + $1.heartRate } / Double(heartRates.count)
    }

}

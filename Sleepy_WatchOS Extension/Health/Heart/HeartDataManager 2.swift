// Copyright (c) 2021 Sleepy.

import Foundation

final class HeartDataManager {
    private var heartRates = [HeartRateSample]()
    weak var delegate: HeartDataManagerDelegate?

    // MARK: Internal methods

    func append(sample: HeartRateSample) {
        self.heartRates.append(sample)
        self.isLightPhase(currentSample: sample)
    }

    func isLightPhase(currentSample: HeartRateSample) {
        guard currentSample.heartRate / self.currentMeanValue() >= 1.2 else {
            return
        }
        self.delegate?.lightPhaseDetected()
    }

    // MARK: Private methods

    private func currentMeanValue() -> Double {
        return self.heartRates.reduce(0.0) { $0 + $1.heartRate } / Double(self.heartRates.count)
    }
}

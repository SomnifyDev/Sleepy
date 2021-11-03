// Copyright (c) 2021 Sleepy.

import Foundation

typealias HeartRate = Double

// MARK: Enums

private enum LightPhaseDetectionStrategy {
	case withConfirmation
	case withoutConfirmation
}

private enum Constant {
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
		self.heartRates.append(sample)
		self.detectLightPhase()
	}

	// MARK: Private methods

	private func detectLightPhase() {
		guard
			self.heartRates.count > 1,
			let last = heartRates.last,
			let preLast = heartRates.dropLast().last else
		{
			return
		}

		let differencePercentage = last / preLast
		if differencePercentage >= Constant.unconditionalLightPhaseDetectionValue {
			self.detectLightPhaseWithStrategy(.withoutConfirmation)
		} else {
			self.detectLightPhaseWithStrategy(.withConfirmation)
		}
	}

	private func detectLightPhaseWithStrategy(_ strategy: LightPhaseDetectionStrategy) {
		switch strategy {
		case .withConfirmation:
			if self.potentialLightPhaseDetectionFlag, self.isLightPhaseDetectionConfirmed() {
				self.delegate?.lightPhaseDetected()
			} else {
				self.detectPotentialLightPhase()
			}
		case .withoutConfirmation:
			self.delegate?.lightPhaseDetected()
		}
	}

	private func detectPotentialLightPhase() {
		guard
			let last = heartRates.last,
			let preLast = heartRates.dropLast().last,
			last / preLast >= Constant.potentialLightPhaseFlagValue else
		{
			return
		}
		self.potentialLightPhaseDetectionFlag = true
	}

	private func isLightPhaseDetectionConfirmed() -> Bool {
		guard
			self.heartRates.count > 2,
			let last = heartRates.last,
			let prePreLast = heartRates.dropLast().dropLast().last,
			last / prePreLast >= Constant.confirmativeLightPhaseFlagValue else
		{
			self.potentialLightPhaseDetectionFlag = false
			return false
		}
		return true
	}
}

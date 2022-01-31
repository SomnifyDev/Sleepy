// Copyright (c) 2022 Sleepy.

import Foundation
import SettingsKit
import SoundAnalysis
import UIKit

/// An observer that receives results from a classify sound request.
class AudioResultsObserver: NSObject, SNResultsObserving {
    private enum Constants {
        static let soundIndentSeconds = 10.0
        static let bannedTypes = ["coughing"]
    }

    var fileName = ""
    var date: Date?
    var array: [SoundAnalysisResult] = []

    /// Notifies the observer when a request generates a prediction.
    func request(_: SNRequest, didProduce result: SNResult) {
        // Downcast the result to a classification result.
        guard let result = result as? SNClassificationResult,
              let classification = result.classifications.first else { return }

        // Convert the confidence to a percentage string.
        let percent = classification.confidence * 100.0
        let confidence = UserDefaults.standard.integer(forKey: SleepySettingsKeys.soundRecognisionConfidence.rawValue)

        guard percent >= Double(confidence) else { return }
        let resultItem = SoundAnalysisResult(
            start: TimeInterval(result.timeRange.start.seconds),
            end: TimeInterval(result.timeRange.end.seconds),
            soundType: classification.identifier.replacingOccurrences(of: "_", with: " "),
            confidence: percent
        )

        guard !Constants.bannedTypes.contains(resultItem.soundType) else { return }
        let soundRange: Range = resultItem.start - Constants.soundIndentSeconds ..< resultItem.end + Constants.soundIndentSeconds
        if !self.array.contains(where: { soundRange.overlaps(($0.start - Constants.soundIndentSeconds) ..< ($0.end + Constants.soundIndentSeconds)) })
        {
            self.array.append(resultItem)
        }
    }

    /// Notifies the observer when a request generates an error.
    func request(_: SNRequest, didFailWithError error: Error) {
        print("The the analysis failed: \(error.localizedDescription)")
    }

    /// Notifies the observer when a request is complete.
    func requestDidComplete(_: SNRequest) {
        print("The request completed successfully!")
    }
}

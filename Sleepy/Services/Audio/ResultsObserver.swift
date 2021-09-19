//
//  ResultsObserver.swift
//  Sleepy
//
//  Created by Никита Казанцев on 14.08.2021.
//

import Foundation
import UIKit
import SoundAnalysis
import SettingsKit

/// An observer that receives results from a classify sound request.
class ResultsObserver: NSObject, SNResultsObserving {

    var fileName = ""
    var date: Date?
    var array: [SoundAnalysisResult] = []
    /// Notifies the observer when a request generates a prediction.
    func request(_ request: SNRequest, didProduce result: SNResult) {
        // Downcast the result to a classification result.
        guard let result = result as? SNClassificationResult else { return }

        // Get the prediction with the highest confidence.
        guard let classification = result.classifications.first else { return }

        // Get the starting time.
        let timeInSeconds = result.timeRange.start.seconds
        // Convert the time to a human-readable string.
        let formattedTime = String(format: "%.2f", timeInSeconds)
        print("Analysis result for audio at time: \(formattedTime)")

        // Convert the confidence to a percentage string.
        let percent = classification.confidence * 100.0
        let confidence = UserDefaults.standard.integer(forKey: SleepySettingsKeys.soundRecognisionConfidence.rawValue)
        guard percent >= Double(confidence) else { return }
        let resultItem = SoundAnalysisResult(start: TimeInterval(timeInSeconds),
                                             end: TimeInterval(result.timeRange.end.seconds),
                                             soundType: classification.identifier.replacingOccurrences(of: "_", with: " "),
                                             confidence: percent)
        // Print the classification's name (label) with its confidence.
        array.append(resultItem)
    }

    /// Notifies the observer when a request generates an error.
    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("The the analysis failed: \(error.localizedDescription)")
    }

    /// Notifies the observer when a request is complete.
    func requestDidComplete(_ request: SNRequest) {
        print("The request completed successfully!")
    }
}

extension CMTime {
    var stringValue: String {
        let totalSeconds = Int(self.seconds)
        let hours = totalSeconds / 3600
        let minutes = totalSeconds % 3600 / 60
        let seconds = totalSeconds % 3600 % 60
        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
}

//
//  ResultsObserver.swift
//  Sleepy
//
//  Created by Никита Казанцев on 14.08.2021.
//

import Foundation
import SettingsKit
import SoundAnalysis
import UIKit

/// An observer that receives results from a classify sound request.
class AudioResultsObserver: NSObject, SNResultsObserving {
    private enum Constants {
        static let soundIndentSeconds = 10.0
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
        let resultItem = SoundAnalysisResult(start: TimeInterval(result.timeRange.start.seconds),
                                             end: TimeInterval(result.timeRange.end.seconds),
                                             soundType: classification.identifier.replacingOccurrences(of: "_", with: " "),
                                             confidence: percent)
        if resultItem.soundType == "coughing" { return }
        // Print the classification's name (label) with its confidence.
        let soundRange: Range = resultItem.start - Constants.soundIndentSeconds..<resultItem.end + Constants.soundIndentSeconds
        if !array.contains(where: { soundRange.overlaps(($0.start - Constants.soundIndentSeconds) ..< ($0.end + Constants.soundIndentSeconds)) }) {
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

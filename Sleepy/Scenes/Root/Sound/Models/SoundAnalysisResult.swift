// Copyright (c) 2022 Sleepy.

import Foundation

struct SoundAnalysisResult: Hashable {
    let start: TimeInterval
    let end: TimeInterval
    let soundType: String
    let confidence: Double
}

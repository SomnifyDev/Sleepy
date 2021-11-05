// Copyright (c) 2021 Sleepy.

import Foundation

struct SoundAnalysisResult: Hashable {
	let start: TimeInterval
	let end: TimeInterval
	let soundType: String
	let confidence: Double
}

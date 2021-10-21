//
//  SoundAnalysisResult.swift
//  Sleepy
//
//  Created by Никита Казанцев on 14.08.2021.
//

import Foundation

struct SoundAnalysisResult: Hashable {
    let start: TimeInterval
    let end: TimeInterval
    let soundType: String
    let confidence: Double
}

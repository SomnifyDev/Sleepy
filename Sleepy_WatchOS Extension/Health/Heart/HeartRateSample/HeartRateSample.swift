//
//  HeartRateSample.swift
//  Sleepy_WatchOS Extension
//
//  Created by Анас Бен Мустафа on 10/17/21.
//

import Foundation

struct HeartRateSample {

    let heartRate: Double
    let timestamp: Date

    init(heartRate: Double, timestamp: Date) {
        self.heartRate = heartRate
        self.timestamp = timestamp
    }

}

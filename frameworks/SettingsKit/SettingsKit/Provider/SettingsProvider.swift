//
//  Settings.swift
//  SettingsKit
//
//  Created by Анас Бен Мустафа on 8/5/21.
//

import Foundation

public protocol SettingsProvider {

    func getSleepGoal() -> Int
    func saveSleepGoal(sleepGoal: Int)

}

public final class SettingsProviderImpl: SettingsProvider {

    public init() {}

    public func getSleepGoal() -> Int {
        return UserDefaults.standard.integer(forKey: "sleepGoal")
    }

    public func saveSleepGoal(sleepGoal: Int) {
        UserDefaults.standard.set(sleepGoal, forKey: "sleepGoal")
    }

}

//
//  Settings.swift
//  SettingsKit
//
//  Created by Анас Бен Мустафа on 8/5/21.
//

import Foundation

// MARK: Enums

public enum SettingType {

    case sleepGoal

}

public enum SettingsProviderErrors: Error {

    case invalidValue(message: String)
}

// MARK: Protocol

public protocol SettingsProvider {

    func getSetting(type: SettingType) -> Any
    func setSetting(type: SettingType, value: Any) throws

}

// MARK: Class

public final class SettingsProviderImpl: SettingsProvider {

    private let sleepGoalKey: String = "sleepGoal"

    public init() {}

    // MARK: Main getter

    public func getSetting(type: SettingType) -> Any {
        switch type {
        case .sleepGoal:
            return getSleepGoal()
        }
    }

    // MARK: Main setter

    public func setSetting(type: SettingType, value: Any) throws {
        switch type {
        case .sleepGoal:
            guard
                let value = value as? Int
            else {
                throw SettingsProviderErrors.invalidValue(message: "Could not cast sleepGoal to integer")
            }
            saveSleepGoal(sleepGoal: value)
        }
    }


    // MARK: Private getters

    private func getSleepGoal() -> Int {
        return UserDefaults.standard.integer(forKey: sleepGoalKey)
    }

    // MARK: Private setters

    private func saveSleepGoal(sleepGoal: Int) {
        UserDefaults.standard.set(sleepGoal, forKey: sleepGoalKey)
    }

}

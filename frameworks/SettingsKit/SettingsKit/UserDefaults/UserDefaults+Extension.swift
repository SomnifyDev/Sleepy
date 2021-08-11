//
//  Settings.swift
//  SettingsKit
//
//  Created by Анас Бен Мустафа on 8/5/21.
//

import Foundation

extension UserDefaults {

    public enum SleepySettingsKeys: String {
        case sleepGoal
    }

    public func get_integer(forKey key: SleepySettingsKeys) -> Int? {
        return integer(forKey: key.rawValue)
    }

    public func get_string(forKey key: SleepySettingsKeys) -> String? {
        return string(forKey: key.rawValue)
    }

    public func get_bool(forKey key: SleepySettingsKeys) -> Bool? {
        return bool(forKey: key.rawValue)
    }

    public func get_double(forKey key: SleepySettingsKeys) -> Double? {
        return double(forKey: key.rawValue)
    }

    public func set_setting(_ integer: Int, forKey key: SleepySettingsKeys) {
        set(integer, forKey: key.rawValue)
    }

    public func set_setting(_ string: String, forKey key: SleepySettingsKeys) {
        set(integer, forKey: key.rawValue)
    }

    public func set_setting(_ bool: Bool, forKey key: SleepySettingsKeys) {
        set(bool, forKey: key.rawValue)
    }

    public func set_setting(_ double: Double, forKey key: SleepySettingsKeys) {
        set(double, forKey: key.rawValue)
    }

}

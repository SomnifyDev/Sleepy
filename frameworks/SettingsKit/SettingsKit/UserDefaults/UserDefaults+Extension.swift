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
        case soundBitrate
        case soundRecognisionConfidence
    }

    public func getInt(forKey key: SleepySettingsKeys) -> Int? {
        // TODO: If the specified key doesn‘t exist, this method returns 0.
        // добавить проверку наличия ключа здесь и мб ниже
        // в идеале уже здесь возвращать дефолтные значения при первом обращении когда значения нет + его же и сохранять
        return integer(forKey: key.rawValue)
    }

    public func getStr(forKey key: SleepySettingsKeys) -> String? {
        return string(forKey: key.rawValue)
    }

    public func getBool(forKey key: SleepySettingsKeys) -> Bool? {
        return bool(forKey: key.rawValue)
    }

    public func getDouble(forKey key: SleepySettingsKeys) -> Double? {
        return double(forKey: key.rawValue)
    }

    public func setInt(_ integer: Int, forKey key: SleepySettingsKeys) {
        set(integer, forKey: key.rawValue)
    }

    public func setStr(_ string: String, forKey key: SleepySettingsKeys) {
        set(string, forKey: key.rawValue)
    }

    public func setBool(_ bool: Bool, forKey key: SleepySettingsKeys) {
        set(bool, forKey: key.rawValue)
    }

    public func setDouble(_ double: Double, forKey key: SleepySettingsKeys) {
        set(double, forKey: key.rawValue)
    }

}

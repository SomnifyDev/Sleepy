//
//  UserDefaults.swift
//  Sleepy_WatchOS Extension
//
//  Created by Анас Бен Мустафа on 10/8/21.
//

import Foundation

@propertyWrapper
struct UserDefault<T> {

    let key: String
    let defaultValue: T
    let defaults = UserDefaults(suiteName: "group.com.sleepy.userdefault")

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            defaults?.synchronize()
            return defaults?.object(forKey: key) as? T ?? defaultValue
        }
        set {
            defaults?.set(newValue, forKey: key)
            defaults?.synchronize()
        }
    }

}

struct UserSettings {

    @UserDefault("isAlarmSet", defaultValue: false)
    static var isAlarmSet: Bool

    @UserDefault("settedAlarmHours", defaultValue: -1)
    static var settedAlarmHours: Int

    @UserDefault("settedAlarmMinutes", defaultValue: -1)
    static var settedAlarmMinutes: Int

}

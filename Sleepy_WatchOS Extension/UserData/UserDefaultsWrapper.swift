// Copyright (c) 2022 Sleepy.

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
            self.defaults?.synchronize()
            return self.defaults?.object(forKey: self.key) as? T ?? self.defaultValue
        }
        set {
            self.defaults?.set(newValue, forKey: self.key)
            self.defaults?.synchronize()
        }
    }
}

enum UserSettings {
    @UserDefault("isAlarmSet", defaultValue: false)
    static var isAlarmSet: Bool

    @UserDefault("settedAlarmHours", defaultValue: -1)
    static var settedAlarmHours: Int

    @UserDefault("settedAlarmMinutes", defaultValue: -1)
    static var settedAlarmMinutes: Int
}

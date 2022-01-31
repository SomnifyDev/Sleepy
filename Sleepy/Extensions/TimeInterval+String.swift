// Copyright (c) 2022 Sleepy.

import Foundation

extension TimeInterval {
    private var milliseconds: Int {
        return Int(truncatingRemainder(dividingBy: 1) * 1000)
    }

    private var seconds: Int {
        return Int(self) % 60
    }

    private var minutes: Int {
        return (Int(self) / 60) % 60
    }

    private var hours: Int {
        return Int(self) / 3600
    }

    public var stringTime: String {
        if self.hours != 0 {
            return "\(self.hours)h \(self.minutes)m \(self.seconds)s"
        } else if self.minutes != 0 {
            return "\(self.minutes)m \(self.seconds)s"
        } else {
            return "\(self.seconds)s"
        }
    }
}

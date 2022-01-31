// Copyright (c) 2022 Sleepy.

import Foundation

public enum SleepySettingsKeys: String, CaseIterable {
    case sleepGoal
    case soundBitrate
    case soundRecognisionConfidence

    public var settingKeyIntegerValue: Int {
        switch self {
        case .sleepGoal:
            return 480
        case .soundBitrate:
            return 10000
        case .soundRecognisionConfidence:
            return 85
        }
    }
}

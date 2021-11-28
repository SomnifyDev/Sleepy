// Copyright (c) 2021 Sleepy.

import FirebaseAnalytics
import Foundation
import SettingsKit
import XUI

class SettingsCoordinator: ObservableObject, ViewModel {
    private unowned let parent: RootCoordinator

    @Published var openedURL: URL?

    @Published var sleepGoalValue = 480
    @Published var bitrateValue = 12000
    @Published var recognisionConfidenceValue: Int = 30
    @Published var isSharePresented: Bool = false

    init(parent: RootCoordinator) {
        self.parent = parent
    }

    func open(_ url: URL) {
        self.openedURL = url
    }
}

extension SettingsCoordinator {
    func saveSetting(with value: Int, forKey key: String) {
        FirebaseAnalytics.Analytics.logEvent("Settings_saved", parameters: [
            "key": key,
            "value": value,
        ])
        UserDefaults.standard.set(value, forKey: key)
    }

    func getAllValuesFromUserDefaults() {
        self.sleepGoalValue = UserDefaults.standard.integer(forKey: SleepySettingsKeys.sleepGoal.rawValue)
        self.bitrateValue = UserDefaults.standard.integer(forKey: SleepySettingsKeys.soundBitrate.rawValue)
        self.recognisionConfidenceValue = UserDefaults.standard.integer(forKey: SleepySettingsKeys.soundRecognisionConfidence.rawValue)
    }
}

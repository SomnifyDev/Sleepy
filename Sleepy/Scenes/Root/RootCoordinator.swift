// Copyright (c) 2022 Sleepy.

import FirebaseAnalytics
import Foundation
import HKCoreSleep
import HKStatistics
import SettingsKit
import SwiftUI
import UIComponents
import XUI

enum TabType: String {
    case summary
    case history
    case alarm
    case soundRecognision
    case settings
}

class RootCoordinator: ObservableObject, ViewModel {
    // MARK: - Properties

    @Published var tab = TabType.summary
    @Published var openedURL: URL?
    @Published private(set) var summaryCoordinator: SummaryNavigationCoordinator!
    @Published private(set) var historyCoordinator: HistoryCoordinator!
    @Published private(set) var alarmCoordinator: AlarmCoordinator!
    @Published private(set) var settingsCoordinator: SettingsCoordinator!
    @Published private(set) var soundsCoordinator: SoundsCoordinator!

    var statisticsProvider: HKStatisticsProvider
    var hkStoreService: HKService

    // MARK: - Init

    init(
        statisticsProvider: HKStatisticsProvider,
        hkStoreService: HKService
    ) {
        self.statisticsProvider = statisticsProvider
        self.hkStoreService = hkStoreService
        self.alarmCoordinator = AlarmCoordinator(parent: self)
        self.soundsCoordinator = SoundsCoordinator(parent: self)
        self.settingsCoordinator = SettingsCoordinator(parent: self)
        self.summaryCoordinator = SummaryNavigationCoordinator(
            statisticsProvider: statisticsProvider,
            hkStoreService: hkStoreService,
            parent: self
        )
        self.historyCoordinator = HistoryCoordinator(
            statisticsProvider: statisticsProvider,
            parent: self
        )
    }

    // MARK: - Methods

    func open(_ url: URL) {
        self.openedURL = url
    }

    func startDeepLink(from url: URL) {
        if let tabToOpen = TabType(rawValue: url.scheme ?? ""),
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        {
            self.openTabView(of: tabToOpen, components: components)
        } else {
            assertionFailure("Trying to open app with illegal url \(url).")
        }
    }

    func openTabView(of type: TabType, components: URLComponents?) {
        self.tab = type
        switch type {
        case .summary:
            self.tab = .summary
            let summaryCoordinator = firstReceiver(as: SummaryNavigationCoordinator.self)
            summaryCoordinator!.open(components: components)
        case .alarm:
            self.tab = .alarm
        case .settings:
            self.tab = .settings
        case .history:
            self.tab = .history
        case .soundRecognision:
            self.tab = .soundRecognision
        }
    }
}

// MARK: - Metrics

extension RootCoordinator {
    func sendAnalytics() {
        FirebaseAnalytics.Analytics.logEvent("RootView_viewed", parameters: [
            "tabOpened": self.tab.rawValue,
        ])
    }
}

// MARK: - Deeplinking

extension RootCoordinator {
    @DeepLinkableBuilder
    var children: [DeepLinkable] {
        self.summaryCoordinator
        self.historyCoordinator
        self.alarmCoordinator
        self.soundsCoordinator
        self.settingsCoordinator
    }
}

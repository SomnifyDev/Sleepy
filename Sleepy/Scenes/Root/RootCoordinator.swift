// Copyright (c) 2021 Sleepy.

import FirebaseAnalytics
import Foundation
import HKCoreSleep
import HKStatistics
import HKVisualKit
import SettingsKit
import SwiftUI
import XUI

enum TabType: String {
	case summary
	case history
	case alarm
	case soundRecognision
	case settings
}

extension RootCoordinator {
	@DeepLinkableBuilder
	var children: [DeepLinkable] {
		summaryCoordinator
		historyCoordinator
		alarmCoordinator
		soundsCoordinator
		settingsCoordinator
	}
}

class RootCoordinator: ObservableObject, ViewModel {
	@Published var tab = TabType.summary
	@Published var openedURL: URL?

	@Published private(set) var summaryCoordinator: SummaryNavigationCoordinator!
	@Published private(set) var historyCoordinator: HistoryCoordinator!
	@Published private(set) var alarmCoordinator: AlarmCoordinator!
	@Published private(set) var settingsCoordinator: SettingsCoordinator!
	@Published private(set) var soundsCoordinator: SoundsCoordinator!

	var colorSchemeProvider: ColorSchemeProvider
	var statisticsProvider: HKStatisticsProvider
	var hkStoreService: HKService

	init(colorSchemeProvider: ColorSchemeProvider,
	     statisticsProvider: HKStatisticsProvider,
	     hkStoreService: HKService)
	{
		self.colorSchemeProvider = colorSchemeProvider
		self.statisticsProvider = statisticsProvider
		self.hkStoreService = hkStoreService

		self.summaryCoordinator = SummaryNavigationCoordinator(colorProvider: colorSchemeProvider,
		                                                       statisticsProvider: statisticsProvider,
		                                                       hkStoreService: hkStoreService,
		                                                       parent: self)
		self.historyCoordinator = HistoryCoordinator(colorSchemeProvider: colorSchemeProvider,
		                                             statisticsProvider: statisticsProvider,
		                                             parent: self)
		self.alarmCoordinator = AlarmCoordinator(colorSchemeProvider: colorSchemeProvider,
		                                         parent: self)
		self.soundsCoordinator = SoundsCoordinator(colorSchemeProvider: colorSchemeProvider,
		                                           parent: self)
		self.settingsCoordinator = SettingsCoordinator(parent: self, colorSchemeProvider: colorSchemeProvider)
	}

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

extension RootCoordinator {
	func sendAnalytics() {
		FirebaseAnalytics.Analytics.logEvent("RootView_viewed", parameters: [
			"tabOpened": self.tab.rawValue,
		])
	}
}

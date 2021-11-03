// Copyright (c) 2021 Sleepy.

import HKStatistics
import HKVisualKit
import SettingsKit
import SwiftUI
import XUI

class SummaryCardsListCoordinator: ObservableObject, ViewModel {
	@Published private(set) var cards: [SummaryViewCardType]?

	private unowned let parent: SummaryNavigationCoordinator

	let colorProvider: ColorSchemeProvider
	let statisticsProvider: HKStatisticsProvider

	init(
		colorProvider: ColorSchemeProvider,
		statisticsProvider: HKStatisticsProvider,
		parent _: SummaryNavigationCoordinator
	) {
		self.colorProvider = colorProvider
		self.statisticsProvider = statisticsProvider
		self.parent = coordinator
	}

	func open(_ card: SummaryViewCardType) {
		coordinator.open(card)
	}
}

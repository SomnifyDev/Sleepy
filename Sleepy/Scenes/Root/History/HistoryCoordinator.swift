// Copyright (c) 2021 Sleepy.

import Foundation
import HKStatistics
import HKVisualKit
import XUI

class HistoryCoordinator: ObservableObject, ViewModel {
	@Published var openedURL: URL?
	@Published private(set) var viewModel: HistoryCoordinatorView!

	let colorSchemeProvider: ColorSchemeProvider
	let statisticsProvider: HKStatisticsProvider
	private unowned let parent: RootCoordinator

	init(
		colorSchemeProvider: ColorSchemeProvider,
		statisticsProvider: HKStatisticsProvider,
		parent: RootCoordinator
	) {
		self.parent = parent

		self.colorSchemeProvider = colorSchemeProvider
		self.statisticsProvider = statisticsProvider

		self.viewModel = HistoryCoordinatorView(
			viewModel: self
		)
	}

	func open(_ url: URL) {
		self.openedURL = url
	}
}

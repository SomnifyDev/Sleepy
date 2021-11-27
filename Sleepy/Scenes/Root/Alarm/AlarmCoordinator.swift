// Copyright (c) 2021 Sleepy.

import Foundation
import HKVisualKit
import XUI

class AlarmCoordinator: ObservableObject, ViewModel {
	@Published var openedURL: URL?
	@Published private(set) var viewModel: AlarmCoordinatorView!
	private unowned let parent: RootCoordinator

	let colorProvider: ColorSchemeProvider

	init(colorSchemeProvider: ColorSchemeProvider,
	     parent: RootCoordinator)
	{
		self.parent = parent
		self.colorProvider = colorSchemeProvider
		self.viewModel = AlarmCoordinatorView(
			viewModel: self
		)
	}

	func open(_ url: URL) {
		self.openedURL = url
	}
}

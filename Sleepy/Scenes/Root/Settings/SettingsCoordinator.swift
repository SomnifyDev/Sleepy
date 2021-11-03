// Copyright (c) 2021 Sleepy.

import Foundation
import SettingsKit
import XUI

class SettingsCoordinator: ObservableObject, ViewModel {
	@Published var openedURL: URL?
	@Published private(set) var viewModel: SettingsCoordinatorView!

	private unowned let parent: RootCoordinator

	init(
		parent: RootCoordinator
	) {
		self.parent = parent

		self.viewModel = SettingsCoordinatorView(
			viewModel: self
		)
	}

	func open(_ url: URL) {
		self.openedURL = url
	}
}

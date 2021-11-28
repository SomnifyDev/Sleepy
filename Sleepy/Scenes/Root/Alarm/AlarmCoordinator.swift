// Copyright (c) 2021 Sleepy.

import Foundation
import UIComponents
import XUI

class AlarmCoordinator: ObservableObject, ViewModel {
	@Published var openedURL: URL?
	private unowned let parent: RootCoordinator

	let colorProvider: ColorSchemeProvider

	init(colorSchemeProvider: ColorSchemeProvider,
	     parent: RootCoordinator)
	{
		self.parent = parent
		self.colorProvider = colorSchemeProvider
	}

	func open(_ url: URL) {
		self.openedURL = url
	}
}

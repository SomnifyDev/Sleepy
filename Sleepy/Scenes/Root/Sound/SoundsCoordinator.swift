// Copyright (c) 2021 Sleepy.

//
//  SoundCoordinator.swift
//  Sleepy
//
//  Created by Никита Казанцев on 14.08.2021.
//
import Foundation
import HKVisualKit
import SettingsKit
import XUI

class SoundsCoordinator: ObservableObject, ViewModel {
	@Published var openedURL: URL?
	@Published private(set) var viewModel: SoundsCoordinatorView!

	let colorProvider: ColorSchemeProvider

	private unowned let parent: RootCoordinator

	init(
		colorSchemeProvider: ColorSchemeProvider,
		parent: RootCoordinator
	) {
		self.parent = parent
		self.colorProvider = colorSchemeProvider

		self.viewModel = SoundsCoordinatorView(
			viewModel: self
		)
	}

	func openSettings() {
		self.parent.openTabView(of: .settings, components: nil)
	}

	func open(_ url: URL) {
		self.openedURL = url
	}
}

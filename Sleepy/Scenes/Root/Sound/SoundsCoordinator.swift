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

    init(title _: String,
         colorSchemeProvider: ColorSchemeProvider,
         parent: RootCoordinator)
    {
        self.parent = parent
        colorProvider = colorSchemeProvider

        viewModel = SoundsCoordinatorView(
            viewModel: self
        )
    }

    func open(_ url: URL) {
        openedURL = url
    }
}

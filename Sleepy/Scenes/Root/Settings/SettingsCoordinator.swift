//
//  AlarmCoordinator.swift
//  Sleepy
//
//  Created by Анас Бен Мустафа on 6/14/21.
//

import Foundation
import SettingsKit
import XUI

class SettingsCoordinator: ObservableObject, ViewModel {
    @Published var openedURL: URL?
    @Published private(set) var viewModel: SettingsCoordinatorView!

    private unowned let parent: RootCoordinator

    init(title _: String,
         parent: RootCoordinator)
    {
        self.parent = parent

        viewModel = SettingsCoordinatorView(
            viewModel: self
        )
    }

    func open(_ url: URL) {
        openedURL = url
    }
}

//
//  SoundCoordinator.swift
//  Sleepy
//
//  Created by Никита Казанцев on 14.08.2021.
//
import Foundation
import XUI
import SettingsKit
import HKVisualKit



class SoundsCoordinator: ObservableObject, ViewModel {

    @Published var openedURL: URL?
    @Published private(set) var viewModel: SoundsCoordinatorView!

    let colorProvider: ColorSchemeProvider

    private unowned let parent: RootCoordinator

    

    init(title: String,
         colorSchemeProvider: ColorSchemeProvider,
         parent: RootCoordinator) {
        self.parent = parent
        self.colorProvider = colorSchemeProvider

        self.viewModel = SoundsCoordinatorView(
            viewModel: self
        )
    }

    func open(_ url: URL) {
        self.openedURL = url
    }

}

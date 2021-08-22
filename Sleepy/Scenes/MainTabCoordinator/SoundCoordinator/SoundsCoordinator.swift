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
// MARK: Protocol

protocol SoundsCoordinator: ViewModel {

    var colorProvider: ColorSchemeProvider { get }
    var openedURL: URL? { get set }
    
    func open(_ url: URL)

}

// MARK: - Implementation

class SoundsCoordinatorImpl: ObservableObject, SoundsCoordinator {

    // MARK: Stored Properties

    @Published var openedURL: URL?
    @Published private(set) var viewModel: SoundsCoordinatorView!

    let colorProvider: ColorSchemeProvider

    private unowned let parent: RootCoordinator

    // MARK: Initialization

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

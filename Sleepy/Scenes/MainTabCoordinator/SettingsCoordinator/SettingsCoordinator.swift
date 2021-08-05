//
//  AlarmCoordinator.swift
//  Sleepy
//
//  Created by Анас Бен Мустафа on 6/14/21.
//

import Foundation
import XUI
import SettingsKit

// MARK: Protocol

protocol SettingsCoordinator: ViewModel {

    var settingsProvider: SettingsProvider { get }
    var openedURL: URL? { get set }
    func open(_ url: URL)
    
}

// MARK: - Implementation

class SettingsCoordinatorImpl: ObservableObject, SettingsCoordinator {
    
    // MARK: Stored Properties
    
    @Published var openedURL: URL?
    @Published private(set) var viewModel: SettingsCoordinatorView!

    private unowned let parent: RootCoordinator
    var settingsProvider: SettingsProvider
    
    // MARK: Initialization
    
    init(title: String,
         parent: RootCoordinator, settingsProvider: SettingsProvider) {
        self.parent = parent
        self.settingsProvider = settingsProvider
        
        self.viewModel = SettingsCoordinatorView(
            viewModel: self
        )
    }
    
    func open(_ url: URL) {
        self.openedURL = url
    }
    
}

//
//  AlarmCoordinator.swift
//  Sleepy
//
//  Created by Анас Бен Мустафа on 6/14/21.
//

import Foundation
import XUI
import HKVisualKit

class AlarmCoordinator: ObservableObject, ViewModel {
    
    @Published var openedURL: URL?
    @Published private(set) var viewModel: AlarmCoordinatorView!
    private unowned let parent: RootCoordinator

    let colorProvider: ColorSchemeProvider

    init(title: String,
         colorSchemeProvider: ColorSchemeProvider,
         parent: RootCoordinator
    ) {
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

//
//  AlarmCoordinator.swift
//  Sleepy
//
//  Created by Анас Бен Мустафа on 6/14/21.
//

import Foundation
import XUI

class AlarmCoordinator: ObservableObject, ViewModel {
    
    @Published var openedURL: URL?
    @Published private(set) var viewModel: AlarmCoordinatorView!
    private unowned let parent: RootCoordinator

    init(title: String,
         parent: RootCoordinator) {
        self.parent = parent
        
        self.viewModel = AlarmCoordinatorView(
//            viewModel: self
        )
    }
    
    func open(_ url: URL) {
        self.openedURL = url
    }
    
}

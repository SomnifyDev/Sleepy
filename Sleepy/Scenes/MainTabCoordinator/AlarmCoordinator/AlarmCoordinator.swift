//
//  AlarmCoordinator.swift
//  Sleepy
//
//  Created by Анас Бен Мустафа on 6/14/21.
//

import Foundation
import XUI

// MARK: Protocol

protocol AlarmCoordinator: ViewModel {
    
    var openedURL: URL? { get set }
    func open(_ url: URL)
    
}

// MARK: - Implementation

class AlarmCoordinatorImpl: ObservableObject, AlarmCoordinator {
    
    // MARK: Stored Properties
    
    @Published var openedURL: URL?
    @Published private(set) var viewModel: AlarmCoordinatorView!
    private unowned let parent: RootCoordinator
    
    // MARK: Initialization
    
    init(title: String,
         parent: RootCoordinator) {
        self.parent = parent
        
        self.viewModel = AlarmCoordinatorView(
            coordinator: self
        )
    }
    
    func open(_ url: URL) {
        self.openedURL = url
    }
    
}

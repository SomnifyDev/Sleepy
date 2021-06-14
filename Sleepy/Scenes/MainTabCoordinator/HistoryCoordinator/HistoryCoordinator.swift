//
//  HistoryCoordinator.swift
//  Sleepy
//
//  Created by Анас Бен Мустафа on 6/14/21.
//

import Foundation
import XUI

// MARK: Protocol

protocol HistoryCoordinator: ViewModel {
    
    var openedURL: URL? { get set }
    func open(_ url: URL)
    
}

// MARK: - Implementation

class HistoryCoordinatorImpl: ObservableObject, HistoryCoordinator {
    
    // MARK: Stored Properties
    
    @Published var openedURL: URL?
    @Published private(set) var viewModel: HistoryCoordinatorView!
    private unowned let parent: RootCoordinator
    
    // MARK: Initialization
    
    init(title: String,
         parent: RootCoordinator) {
        self.parent = parent
        
        self.viewModel = HistoryCoordinatorView(
            coordinator: self
        )
    }
    
    func open(_ url: URL) {
        self.openedURL = url
    }
    
}

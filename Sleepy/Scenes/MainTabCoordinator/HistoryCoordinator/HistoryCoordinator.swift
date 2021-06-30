//
//  HistoryCoordinator.swift
//  Sleepy
//
//  Created by Анас Бен Мустафа on 6/14/21.
//

import Foundation
import XUI
import HKVisualKit
import HKStatistics

// MARK: Protocol

protocol HistoryCoordinator: ViewModel {

    var colorSchemeProvider: ColorSchemeProvider { get }
    var statisticsProvider: HKStatisticsProvider { get }

    var openedURL: URL? { get set }
    func open(_ url: URL)
    
}

// MARK: - Implementation

class HistoryCoordinatorImpl: ObservableObject, HistoryCoordinator {
    
    // MARK: Stored Properties
    
    @Published var openedURL: URL?
    @Published private(set) var viewModel: HistoryCoordinatorView!

    let colorSchemeProvider: ColorSchemeProvider
    let statisticsProvider: HKStatisticsProvider

    private unowned let parent: RootCoordinator
    
    // MARK: Initialization
    
    init(title: String,
         colorSchemeProvider: ColorSchemeProvider,
         statisticsProvider: HKStatisticsProvider,
         parent: RootCoordinator) {
        self.parent = parent

        self.colorSchemeProvider = colorSchemeProvider
        self.statisticsProvider = statisticsProvider
        
        self.viewModel = HistoryCoordinatorView(
            coordinator: self
        )
    }
    
    func open(_ url: URL) {
        self.openedURL = url
    }
    
}

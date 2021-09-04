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

class HistoryCoordinator: ObservableObject, ViewModel {
    
    @Published var openedURL: URL?
    @Published private(set) var viewModel: HistoryCoordinatorView!

    let colorSchemeProvider: ColorSchemeProvider
    let statisticsProvider: HKStatisticsProvider

    private unowned let parent: RootCoordinator
    
    
    
    init(title: String,
         colorSchemeProvider: ColorSchemeProvider,
         statisticsProvider: HKStatisticsProvider,
         parent: RootCoordinator) {
        self.parent = parent

        self.colorSchemeProvider = colorSchemeProvider
        self.statisticsProvider = statisticsProvider
        
        self.viewModel = HistoryCoordinatorView(
            viewModel: self
        )
    }
    
    func open(_ url: URL) {
        self.openedURL = url
    }
    
}

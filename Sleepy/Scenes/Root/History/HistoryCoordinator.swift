//
//  HistoryCoordinator.swift
//  Sleepy
//
//  Created by Анас Бен Мустафа on 6/14/21.
//

import Foundation
import HKStatistics
import HKVisualKit
import XUI

class HistoryCoordinator: ObservableObject, ViewModel {
    @Published var openedURL: URL?
    @Published private(set) var viewModel: HistoryCoordinatorView!

    let colorSchemeProvider: ColorSchemeProvider
    let statisticsProvider: HKStatisticsProvider
    private unowned let parent: RootCoordinator

    init(title _: String,
         colorSchemeProvider: ColorSchemeProvider,
         statisticsProvider: HKStatisticsProvider,
         parent: RootCoordinator)
    {
        self.parent = parent

        self.colorSchemeProvider = colorSchemeProvider
        self.statisticsProvider = statisticsProvider

        viewModel = HistoryCoordinatorView(
            viewModel: self
        )
    }

    func open(_ url: URL) {
        openedURL = url
    }
}

// Copyright (c) 2021 Sleepy.

import FirebaseAnalytics
import HKStatistics
import HKVisualKit
import SettingsKit
import SwiftUI
import XUI

class SummaryCardsListCoordinator: ObservableObject, ViewModel {
    private unowned let parent: SummaryNavigationCoordinator

    @Published private(set) var cards: [SummaryViewCardType]?
    @Published var somethingBroken = false

    let colorProvider: ColorSchemeProvider
    let statisticsProvider: HKStatisticsProvider

    init(colorProvider: ColorSchemeProvider,
         statisticsProvider: HKStatisticsProvider,
         parent: SummaryNavigationCoordinator)
    {
        self.colorProvider = colorProvider
        self.statisticsProvider = statisticsProvider
        self.parent = parent
    }

    func open(_ card: SummaryViewCardType) {
        self.parent.open(card)
    }
}

extension SummaryCardsListCoordinator {
    func sendAnalytics(cardService: CardService) {
        FirebaseAnalytics.Analytics.logEvent("SummaryCardsList_viewed", parameters: [
            "somethingBroken": self.somethingBroken,
            "generalCardShown": cardService.generalViewModel != nil,
            "phasesCardShown": cardService.phasesViewModel != nil && cardService.generalViewModel != nil,
            "heartCardShown": cardService.heartViewModel != nil && cardService.generalViewModel != nil,
        ])
    }
}

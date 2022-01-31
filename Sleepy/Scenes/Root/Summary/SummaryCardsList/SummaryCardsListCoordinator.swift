// Copyright (c) 2022 Sleepy.

import FirebaseAnalytics
import HKStatistics
import UIComponents
import XUI

class SummaryCardsListCoordinator: ObservableObject, ViewModel {
    // MARK: - Properties

    private unowned let parent: SummaryNavigationCoordinator

    @Published private(set) var cards: [SummaryViewCardType]?

    let statisticsProvider: HKStatisticsProvider
    let factory = SummaryListFactory()
    let somethingBrokenBannerViewModel: BannerViewModel<CardBottomSimpleDescriptionView>
    let phasesCardTitleViewModel: CardTitleViewModel
    let heartCardTitleViewModel: CardTitleViewModel
    let respiratoryCardTitleViewModel: CardTitleViewModel

    // MARK: - Init

    init(
        statisticsProvider: HKStatisticsProvider,
        parent: SummaryNavigationCoordinator
    ) {
        self.statisticsProvider = statisticsProvider
        self.parent = parent
        self.somethingBrokenBannerViewModel = self.factory.makeSomethingBrokenBannerViewModel()
        self.phasesCardTitleViewModel = self.factory.makePhasesCardTitleViewModel()
        self.heartCardTitleViewModel = self.factory.makeHeartCardTitleViewModel()
        self.respiratoryCardTitleViewModel = self.factory.makeRespiratoryCardTitleViewModel()
    }

    // MARK: - Methods

    func open(_ card: SummaryViewCardType) {
        self.parent.open(card)
    }
}

// MARK: - Metrics

extension SummaryCardsListCoordinator {
    func sendAnalytics(cardService: CardService) {
        FirebaseAnalytics.Analytics.logEvent("SummaryCardsList_viewed", parameters: [
            "generalCardShown": cardService.generalViewModel != nil,
            "phasesCardShown": cardService.phasesViewModel != nil && cardService.generalViewModel != nil,
            "heartCardShown": cardService.heartViewModel != nil && cardService.generalViewModel != nil,
        ])
    }
}

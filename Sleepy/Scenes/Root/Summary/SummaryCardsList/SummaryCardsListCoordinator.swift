// Copyright (c) 2021 Sleepy.

import FirebaseAnalytics
import HKStatistics
import UIComponents
import XUI

class SummaryCardsListCoordinator: ObservableObject, ViewModel {

    // MARK: - Properties

	private unowned let parent: SummaryNavigationCoordinator

	@Published private(set) var cards: [SummaryViewCardType]?
	@Published var somethingBroken = false

	let statisticsProvider: HKStatisticsProvider
    let factory: SummaryListFactory = SummaryListFactory()
    let somethingBrokenBannerViewModel: BannerViewModel<CardTitleView>
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
        self.somethingBrokenBannerViewModel = factory.makeSomethingBrokenBannerViewModel()
        self.phasesCardTitleViewModel = factory.makePhasesCardTitleViewModel()
        self.heartCardTitleViewModel = factory.makeHeartCardTitleViewModel()
        self.respiratoryCardTitleViewModel = factory.makeRespiratoryCardTitleViewModel()
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
			"somethingBroken": self.somethingBroken,
			"generalCardShown": cardService.generalViewModel != nil,
			"phasesCardShown": cardService.phasesViewModel != nil && cardService.generalViewModel != nil,
			"heartCardShown": cardService.heartViewModel != nil && cardService.generalViewModel != nil,
		])
	}

}

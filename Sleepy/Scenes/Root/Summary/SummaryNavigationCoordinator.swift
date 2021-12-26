// Copyright (c) 2021 Sleepy.

import Foundation
import HKStatistics
import HKCoreSleep
import XUI

class SummaryNavigationCoordinator: ObservableObject, ViewModel, Identifiable {

    // MARK: - Properties

	@Published private(set) var summaryListCoordinator: SummaryCardsListCoordinator!
	@Published var cardDetailViewCoordinator: CardDetailsViewCoordinator?

    let hkStoreService: HKService
	let statisticsProvider: HKStatisticsProvider

    private unowned let parent: RootCoordinator

    // MARK: - Init

	init(statisticsProvider: HKStatisticsProvider,
	     hkStoreService: HKService,
	     parent: RootCoordinator
    ) {
		self.statisticsProvider = statisticsProvider
		self.parent = parent
		self.hkStoreService = hkStoreService
		self.summaryListCoordinator = SummaryCardsListCoordinator(
            statisticsProvider: statisticsProvider,
            parent: self
        )
	}

    // MARK: - Methods

	func open(_ url: URL) {
		self.parent.open(url)
	}

	func open(components: URLComponents?) {
		guard
            let components = components,
            let cardType = SummaryViewCardType(rawValue: components.host ?? "")
        else {
			return
		}
		self.cardDetailViewCoordinator = CardDetailsViewCoordinator(card: cardType, parent: self)
	}

	func open(_ card: SummaryViewCardType) {
		self.cardDetailViewCoordinator = CardDetailsViewCoordinator(card: card, parent: self)
	}
}

// MARK: - Deeplinking

extension SummaryNavigationCoordinator {

    @DeepLinkableBuilder
    var children: [DeepLinkable] {
        summaryListCoordinator
        cardDetailViewCoordinator
    }

}

// Copyright (c) 2021 Sleepy.

import Foundation
import HKCoreSleep
import HKStatistics
import SettingsKit
import SwiftUI
import UIComponents
import XUI

extension SummaryNavigationCoordinator {
	@DeepLinkableBuilder
	var children: [DeepLinkable] {
		summaryListCoordinator
		cardDetailViewCoordinator
	}
}

class SummaryNavigationCoordinator: ObservableObject, ViewModel, Identifiable {
	private unowned let parent: RootCoordinator

	@Published private(set) var summaryListCoordinator: SummaryCardsListCoordinator!
	@Published var cardDetailViewCoordinator: CardDetailsViewCoordinator?

	let colorProvider: ColorSchemeProvider
	let hkStoreService: HKService
	let statisticsProvider: HKStatisticsProvider

	init(colorProvider: ColorSchemeProvider,
	     statisticsProvider: HKStatisticsProvider,
	     hkStoreService: HKService,
	     parent: RootCoordinator)
	{
		self.colorProvider = colorProvider
		self.statisticsProvider = statisticsProvider
		self.parent = parent

		self.hkStoreService = hkStoreService
		self.summaryListCoordinator = SummaryCardsListCoordinator(colorProvider: colorProvider,
		                                                          statisticsProvider: statisticsProvider,
		                                                          parent: self)
	}

	func open(_ url: URL) {
		self.parent.open(url)
	}

	func open(components: URLComponents?) {
		guard let components = components,
		      let cardType = SummaryViewCardType(rawValue: components.host ?? "") else
		{
			return
		}

		self.cardDetailViewCoordinator = CardDetailsViewCoordinator(card: cardType, parent: self)
	}

	func open(_ card: SummaryViewCardType) {
		// пришла команда открыть карту - инициализируем координатор карточки
		// а переменная-то @Published - поэтому она затриггерит к срабатыванию
		// модификатор .navigation(model: у своего view
		self.cardDetailViewCoordinator = CardDetailsViewCoordinator(card: card, parent: self)
	}
}

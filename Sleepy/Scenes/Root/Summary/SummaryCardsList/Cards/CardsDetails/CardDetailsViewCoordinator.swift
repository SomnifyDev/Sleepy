// Copyright (c) 2021 Sleepy.

import FirebaseAnalytics
import Foundation
import HKCoreSleep
import HKStatistics
import HKVisualKit
import SettingsKit
import XUI

class CardDetailsViewCoordinator: ViewModel, ObservableObject, Identifiable
{
    @Published private(set) var card: SummaryViewCardType

    private unowned let parent: SummaryNavigationCoordinator

    var colorProvider: ColorSchemeProvider
    var statisticsProvider: HKStatisticsProvider

    init(card: SummaryViewCardType, parent: SummaryNavigationCoordinator)
    {
        self.parent = parent
        self.card = card
        self.colorProvider = parent.colorProvider
        self.statisticsProvider = parent.statisticsProvider
    }

    func open(_ url: URL)
    {
        self.parent.open(url)
    }
}

extension CardDetailsViewCoordinator
{
    func sendAnalytics()
    {
        FirebaseAnalytics.Analytics.logEvent("CardDetails_viewed", parameters: ["cardType": self.card.rawValue])
    }
}

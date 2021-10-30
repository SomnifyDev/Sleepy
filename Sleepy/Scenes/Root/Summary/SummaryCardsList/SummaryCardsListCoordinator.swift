import HKStatistics
import HKVisualKit
import SettingsKit
import SwiftUI
import XUI

class SummaryCardsListCoordinator: ObservableObject, ViewModel {
    @Published private(set) var title: String
    @Published private(set) var cards: [SummaryViewCardType]?

    private unowned let coordinator: SummaryNavigationCoordinator

    let colorProvider: ColorSchemeProvider
    let statisticsProvider: HKStatisticsProvider

    init(
        colorProvider: ColorSchemeProvider,
        statisticsProvider: HKStatisticsProvider,
        title: String,
        coordinator: SummaryNavigationCoordinator
    ) {
        self.colorProvider = colorProvider
        self.statisticsProvider = statisticsProvider
        self.title = title
        self.coordinator = coordinator
    }

    func open(_ card: SummaryViewCardType) {
        coordinator.open(card)
    }
}

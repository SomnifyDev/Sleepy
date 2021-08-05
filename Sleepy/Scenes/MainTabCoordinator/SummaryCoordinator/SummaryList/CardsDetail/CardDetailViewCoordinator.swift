import Foundation
import HKCoreSleep
import HKStatistics
import HKVisualKit
import SettingsKit
import XUI

protocol CardDetailViewCoordinator: ViewModel {

    var colorProvider: ColorSchemeProvider { get }
    var statisticsProvider: HKStatisticsProvider { get }
    var settingsProvider: SettingsProvider { get }

    var card: SummaryViewCardType { get }
    func open(_ url: URL)

}

class CardDetailViewCoordinatorImpl: CardDetailViewCoordinator, ObservableObject, Identifiable {

    // MARK: Stored Properties
    
    @Published private(set) var card: SummaryViewCardType
    private unowned let coordinator: SummaryNavigationCoordinator

    // MARK: Properties

    var colorProvider: ColorSchemeProvider
    var statisticsProvider: HKStatisticsProvider
    var settingsProvider: SettingsProvider

    // MARK: Initialization

    init(card: SummaryViewCardType, coordinator: SummaryNavigationCoordinator) {
        self.coordinator = coordinator
        self.card = card
        self.colorProvider = coordinator.colorProvider
        self.statisticsProvider = coordinator.statisticsProvider
        self.settingsProvider = coordinator.settingsProvider
    }

    // MARK: Methods

    func open(_ url: URL) {
        self.coordinator.open(url)
    }

}

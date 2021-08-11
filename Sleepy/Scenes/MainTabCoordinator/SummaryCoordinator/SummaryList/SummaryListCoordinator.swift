import SwiftUI
import XUI
import HKVisualKit
import HKStatistics
import SettingsKit

// MARK: - Protocol

protocol SummaryListCoordinator: ViewModel {

    var colorProvider: ColorSchemeProvider { get }
    var statisticsProvider: HKStatisticsProvider { get }

    var title: String { get }
    var cards: [SummaryViewCardType]? { get }

    func open(_ card: SummaryViewCardType)

}

// MARK: - Implementation

class SummaryListCoordinatorImpl: ObservableObject, SummaryListCoordinator {

    // MARK: Stored Properties

    @Published private(set) var title: String
    @Published private(set) var cards: [SummaryViewCardType]?

    private let cardService: CardService
    private unowned let coordinator: SummaryNavigationCoordinator
    let colorProvider: ColorSchemeProvider
    let statisticsProvider: HKStatisticsProvider

    // MARK: Initialization

    init(colorProvider: ColorSchemeProvider,
         statisticsProvider: HKStatisticsProvider,
         title: String,
         cardService: CardService,
         coordinator: SummaryNavigationCoordinator,
         filter: @escaping (SummaryViewCardType) -> Bool) {

        self.colorProvider = colorProvider
        self.statisticsProvider = statisticsProvider
        self.title = title
        self.coordinator = coordinator
        self.cardService = cardService

        cardService.fetchCards {
            self.cards = $0.filter(filter)
        }

    }

    // MARK: Methods

    func open(_ card: SummaryViewCardType) {
        coordinator.open(card)
    }

}

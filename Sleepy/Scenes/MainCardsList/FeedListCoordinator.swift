import SwiftUI
import XUI
import HKVisualKit

// MARK: - Protocol

protocol FeedListCoordinator: ViewModel {

    var title: String { get }
    var cards: [Card] { get }

    func open(_ card: Card)

}

// MARK: - Implementation

class FeedListCoordinatorImpl: ObservableObject, FeedListCoordinator {

    // MARK: Stored Properties

    @Published private(set) var title: String
    @Published private(set) var cards = [Card(type: .general, title: "gen card"), Card(type: .phases, title: "phases card"), Card(type: .heart, title: "heart card")]

    private let cardService: CardService
    private unowned let coordinator: FeedNavigationCoordinator

    // MARK: Initialization

    init(title: String,
         cardService: CardService,
         coordinator: FeedNavigationCoordinator,
         filter: @escaping (Card) -> Bool) {

        self.title = title
        self.coordinator = coordinator
        self.cardService = cardService

        cardService.fetchCards {
            self.cards = $0.filter(filter)
        }

    }

    // MARK: Methods

    func open(_ card: Card) {
        coordinator.open(card)
    }

}

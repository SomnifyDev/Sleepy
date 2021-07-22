import Foundation
import XUI

protocol CardDetailViewRouter: ViewModel {

    var card: CardType { get }

    func open(_ url: URL)

}

class CardDetailViewCoordinatorImpl: CardDetailViewRouter, ObservableObject, Identifiable {

    // MARK: Stored Properties

    @Published private(set) var card: CardType

    private unowned let coordinator: SummaryNavigationCoordinator

    // MARK: Initialization

    init(card: CardType, coordinator: SummaryNavigationCoordinator) {
        self.coordinator = coordinator
        self.card = card
    }

    // MARK: Methods

    func open(_ url: URL) {
        self.coordinator.open(url)
    }

}

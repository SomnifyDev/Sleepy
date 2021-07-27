import Foundation
import XUI

protocol CardDetailViewCoordinator: ViewModel {

    var card: SummaryViewCardType { get }
    func open(_ url: URL)

}

class CardDetailViewCoordinatorImpl: CardDetailViewCoordinator, ObservableObject, Identifiable {

    // MARK: Stored Properties
    
    @Published private(set) var card: SummaryViewCardType
    private unowned let coordinator: SummaryNavigationCoordinator

    // MARK: Initialization

    init(card: SummaryViewCardType, coordinator: SummaryNavigationCoordinator) {
        self.coordinator = coordinator
        self.card = card
    }

    // MARK: Methods

    func open(_ url: URL) {
        self.coordinator.open(url)
    }

}

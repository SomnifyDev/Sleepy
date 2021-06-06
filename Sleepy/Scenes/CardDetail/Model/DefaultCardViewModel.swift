import Foundation

class DefaultCardViewModel: CardViewModel, ObservableObject, Identifiable {

    // MARK: Stored Properties

    @Published private(set) var card: Card

    private unowned let coordinator: MainListCoordinator

    // MARK: Initialization

    init(card: Card, coordinator: MainListCoordinator) {
        self.coordinator = coordinator
        self.card = card
    }

    // MARK: Methods

    func open(_ url: URL) {
        self.coordinator.open(url)
    }

}

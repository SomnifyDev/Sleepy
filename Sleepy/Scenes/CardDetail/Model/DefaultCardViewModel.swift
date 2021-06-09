import Foundation

class DefaultCardViewModel: CardViewModel, ObservableObject, Identifiable {

    // MARK: Stored Properties

    @Published private(set) var card: Card

    private unowned let coordinator: FeedNavigationCoordinator

    // MARK: Initialization

    init(card: Card, coordinator: FeedNavigationCoordinator) {
        self.coordinator = coordinator
        self.card = card
    }

    // MARK: Methods

    func open(_ url: URL) {
        self.coordinator.open(url)
    }

}

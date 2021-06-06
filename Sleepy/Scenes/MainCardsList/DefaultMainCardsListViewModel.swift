import Foundation

class DefaultMainCardsListViewModel: ObservableObject, MainCardsListViewModel {

    // MARK: Stored Properties

    @Published private(set) var title: String
    @Published private(set) var cards = [Card(title: "gen card"), Card(title: "phases card"), Card(title: "heart card")]

    private let cardService: CardService
    private unowned let coordinator: MainListCoordinator

    // MARK: Initialization

    init(title: String,
         cardService: CardService,
         coordinator: MainListCoordinator,
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

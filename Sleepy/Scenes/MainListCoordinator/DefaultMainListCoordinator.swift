import Foundation
import XUI

class DefaultMainListCoordinator: ObservableObject, MainListCoordinator, Identifiable {

    // MARK: Stored Properties

    @Published private(set) var viewModel: MainCardsListViewModel!
    @Published var detailViewModel: CardViewModel?

    private let _filter: (Card) -> Bool

    private let cardService: CardService
    private unowned let parent: GeneralCoordinator

    // MARK: Initialization

    init(title: String,
         cardService: CardService,
         parent: GeneralCoordinator,
         filter: @escaping (Card) -> Bool) {
        self.parent = parent
        self.cardService = cardService
        self._filter = filter

        self.viewModel = DefaultMainCardsListViewModel(
            title: title,
            cardService: cardService,
            coordinator: self,
            filter: filter
        )
    }

    // MARK: Methods

    func filter(_ card: Card) -> Bool {
        _filter(card)
    }

    func open(_ card: Card) {
        detailViewModel = DefaultCardViewModel(card: card, coordinator: self)
    }

    func open(_ url: URL) {
        parent.open(url)
    }

}

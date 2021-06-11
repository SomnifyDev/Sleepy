import Foundation
import XUI

// MARK: - Protocol

protocol FeedNavigationCoordinator: ViewModel {

    var viewModel: FeedListCoordinator! { get }
    var detailViewModel: CardViewModel? { get set }

    func filter(_ card: Card) -> Bool

    func open(_ card: Card)
    func open(_ url: URL)
}

extension FeedNavigationCoordinator {

    @DeepLinkableBuilder
    var children: [DeepLinkable] {
        viewModel
        detailViewModel
    }

}

// MARK: - Implementation

class FeedNavigationCoordinatorImpl: ObservableObject, FeedNavigationCoordinator, Identifiable {

    // MARK: Stored Properties

    @Published private(set) var viewModel: FeedListCoordinator!
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

        self.viewModel =
        FeedListCoordinatorImpl(title: title,
                                cardService: cardService,
                                coordinator: self,
                                filter: filter)
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

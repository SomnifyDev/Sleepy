import Foundation
import XUI

// MARK: - Protocol

protocol FeedNavigationCoordinator: ViewModel {

    var viewModel: FeedListCoordinator! { get }
    var detailViewModel: CardDetailViewRouter? { get set }

    func filter(_ card: CardType) -> Bool

    func open(_ card: CardType)
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
    @Published var detailViewModel: CardDetailViewRouter?

    private let _filter: (CardType) -> Bool

    private let hkStoreService: HKStoreService
    private let cardService: CardService
    private unowned let parent: RootCoordinator

    // MARK: Initialization

    init(title: String,
         hkStoreService: HKStoreService,
         cardService: CardService,
         parent: RootCoordinator,
         filter: @escaping (CardType) -> Bool) {

        self.parent = parent
        // координатор экрана получил сервисы которые мб понадобятся ему или дочерним роутерам
        // обрати внимание на View данного координатора
        // Это еще не view со списком карточек 1 таба. Это обертка списка карточек NavigationView'ром
        self.hkStoreService = hkStoreService
        self.cardService = cardService
        self._filter = filter

        // создаем дочерний координатор списка карточек
        self.viewModel =
        FeedListCoordinatorImpl(title: title,
                                cardService: cardService,
                                coordinator: self,
                                filter: filter)
        
    }

    // MARK: Internal Methods

    func filter(_ card: CardType) -> Bool {
        _filter(card)
    }

    func open(_ url: URL) {
        parent.open(url)
    }

    func open(_ card: CardType) {
        // пришла команда открыть карту - инициализируем координатор карточки
        // а переменная-то @Published - поэтому она затриггерит к срабатыванию
        // модификатор .navigation(model: у своего view
        detailViewModel = CardDetailViewCoordinatorImpl(card: card, coordinator: self)
    }

}

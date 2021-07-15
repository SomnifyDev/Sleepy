import Foundation
import XUI
import HKCoreSleep
import HKVisualKit
import HKStatistics

// MARK: - Protocol

protocol FeedNavigationCoordinator: ViewModel {

    var viewModel: FeedListCoordinator! { get }
    var detailViewModel: CardDetailViewRouter? { get set }

    var colorProvider: ColorSchemeProvider { get }
    var statisticsProvider: HKStatisticsProvider { get }

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

    private let hkStoreService: HKService
    private let cardService: CardService
    private unowned let parent: RootCoordinator
    let colorProvider: ColorSchemeProvider
    let statisticsProvider: HKStatisticsProvider

    // MARK: Initialization

    init(colorProvider: ColorSchemeProvider,
         statisticsProvider: HKStatisticsProvider,
         title: String,
         hkStoreService: HKService,
         cardService: CardService,
         parent: RootCoordinator,
         filter: @escaping (CardType) -> Bool) {

        self.colorProvider = colorProvider
        self.statisticsProvider = statisticsProvider
        self.parent = parent
        // координатор экрана получил сервисы которые мб понадобятся ему или дочерним роутерам
        // обрати внимание на View данного координатора
        // Это еще не view со списком карточек 1 таба. Это обертка списка карточек NavigationView'ром
        self.hkStoreService = hkStoreService
        self.cardService = cardService
        self._filter = filter

        // создаем дочерний координатор списка карточек
        self.viewModel =
        FeedListCoordinatorImpl(colorProvider: colorProvider,
                                statisticsProvider: statisticsProvider,
                                title: title,
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

import Foundation
import XUI
import HKCoreSleep
import HKVisualKit
import HKStatistics

// MARK: - Protocol

protocol SummaryNavigationCoordinator: ViewModel {

    var summaryListCoordinator: SummaryListCoordinator! { get }
    var cardDetailViewCoordinator: CardDetailViewCoordinator? { get set }

    var colorProvider: ColorSchemeProvider { get }
    var statisticsProvider: HKStatisticsProvider { get }

    func filter(_ card: SummaryViewCardType) -> Bool

    func open(_ card: SummaryViewCardType)
    func open(_ url: URL)

}

extension SummaryNavigationCoordinator {

    @DeepLinkableBuilder
    var children: [DeepLinkable] {
        summaryListCoordinator
        cardDetailViewCoordinator
    }

}

// MARK: - Implementation

class SummaryNavigationCoordinatorImpl: ObservableObject, SummaryNavigationCoordinator, Identifiable {

    // MARK: Stored Properties

    @Published private(set) var summaryListCoordinator: SummaryListCoordinator!
    @Published var cardDetailViewCoordinator: CardDetailViewCoordinator?

    private let _filter: (SummaryViewCardType) -> Bool

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
         filter: @escaping (SummaryViewCardType) -> Bool) {

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
        self.summaryListCoordinator =
        SummaryListCoordinatorImpl(colorProvider: colorProvider,
                                statisticsProvider: statisticsProvider,
                                title: title,
                                cardService: cardService,
                                coordinator: self,
                                filter: filter)
        
    }

    // MARK: Internal Methods

    func filter(_ card: SummaryViewCardType) -> Bool {
        _filter(card)
    }

    func open(_ url: URL) {
        parent.open(url)
    }

    func open(_ card: SummaryViewCardType) {
        // пришла команда открыть карту - инициализируем координатор карточки
        // а переменная-то @Published - поэтому она затриггерит к срабатыванию
        // модификатор .navigation(model: у своего view
        cardDetailViewCoordinator = CardDetailViewCoordinatorImpl(card: card, coordinator: self)
    }

}

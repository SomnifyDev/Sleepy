import Foundation
import XUI
import HKCoreSleep
import HKVisualKit
import HKStatistics
import SettingsKit
import SwiftUI

extension SummaryNavigationCoordinator {

    @DeepLinkableBuilder
    var children: [DeepLinkable] {
        summaryListCoordinator
        cardDetailViewCoordinator
    }

}

class SummaryNavigationCoordinator: ObservableObject, ViewModel, Identifiable {

    private unowned let parent: RootCoordinator

    @Published private(set) var summaryListCoordinator: SummaryListCoordinator!
    @Published var cardDetailViewCoordinator: CardDetailViewCoordinator?

    let colorProvider: ColorSchemeProvider
    let hkStoreService: HKService
    let statisticsProvider: HKStatisticsProvider

    

    init(colorProvider: ColorSchemeProvider,
         statisticsProvider: HKStatisticsProvider,
         title: String,
         hkStoreService: HKService,
         parent: RootCoordinator) {

        self.colorProvider = colorProvider
        self.statisticsProvider = statisticsProvider
        self.parent = parent
        // координатор экрана получил сервисы которые мб понадобятся ему или дочерним роутерам
        // обрати внимание на View данного координатора
        // Это еще не view со списком карточек 1 таба. Это обертка списка карточек NavigationView'ром
        self.hkStoreService = hkStoreService

        // создаем дочерний координатор списка карточек
        self.summaryListCoordinator = SummaryListCoordinator(colorProvider: colorProvider,
                                                             statisticsProvider: statisticsProvider,
                                                             title: title,
                                                             coordinator: self)
    }

    func open(_ url: URL) {
        parent.open(url)
    }

    func open(_ card: SummaryViewCardType) {
        // пришла команда открыть карту - инициализируем координатор карточки
        // а переменная-то @Published - поэтому она затриггерит к срабатыванию
        // модификатор .navigation(model: у своего view
        cardDetailViewCoordinator = CardDetailViewCoordinator(card: card, coordinator: self)
    }

}

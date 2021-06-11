import Foundation
import SwiftUI
import XUI

// all types of main tab bar windows
enum TabBarTab: String {
    case feed
    case history
    case alarm
    case settings
}

// MARK: - Protocol

protocol RootCoordinator: ViewModel {

    var tab: TabBarTab { get set }

    var feedCoordinator: FeedNavigationCoordinator! { get }

    var openedURL: URL? { get set }

    func startDeepLink(from url: URL)

    func open(_ url: URL)

}

extension RootCoordinator {

    @DeepLinkableBuilder
    var children: [DeepLinkable] {
        feedCoordinator
        //historyCoordinator
    }

}

// MARK: - Implementation

class RootCoordinatorImpl: ObservableObject, RootCoordinator {

    // MARK: Stored Properties

    @Published var tab = TabBarTab.feed

    @Published private(set) var feedCoordinator: FeedNavigationCoordinator!
    //@Published private(set) var historyCoordinator: HistoryCoordinator!

    @Published var openedURL: URL?

    private let hkStoreService: HKStoreService
    private let cardService: CardService

    // MARK: Initialization

    init(hkStoreService: HKStoreService, cardService: CardService) {
        // наш главный координатор таббара получил сервисы
        self.hkStoreService = hkStoreService
        self.cardService = cardService

        // думаем, а какие сервисы понадобятся для экрана 1 страницы таббара (со списком карточек)
        // пока давай передадим и сервис здоровья, и сервис карточек (хотя насчет надобности второго я думаю)
        self.feedCoordinator = FeedNavigationCoordinatorImpl(
            title: "main list",
            hkStoreService: hkStoreService,
            cardService: cardService,
            parent: self,
            filter: { _ in true }
        )

        // self.historyCoordinatator = DefaultHistoryCoordinator(...
    }

    // MARK: Methods

    func startDeepLink(from url: URL) {
        // по сути тут надо анализировать пришедшую url
        // Наш RootCoordinator в котором мы находимся по сути является таким "регулировщиком"
        // который получает ссылку при старте приложения и начинает прокладывать путь из цепочек
        // открытий экранов

        // делаем небольшие проверочки, "разрезая" полученную ссылку.
        // "под разрезая" имею ввиду, что получая ссылку вида feed://card?type=heart
        // мы сначала смотрим на scheme (feed) чтоб понять в какую часть tab bar направить пользователя
        // потом на сопутствующий параметр. в нашем случае мы получаем card, по ?type читаем параметр,
        // чтоб понять какую карточку открыть
        guard url.scheme == "feed",
              url.host == "card",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let cardTypeRaw = components.queryItems?.first(where: { $0.name == "type" })?.value else {
                  assertionFailure("Trying to open app with illegal url \(url).")
                  return
              }

        // TODO: make it better by code-style
        // ну вот, нам пришла ссылка, координатор "озонал", что хотим открыть детальную карточку
        // теперь нужно понять какую
        let cardType: CardType = cardTypeRaw == "heart" ? .heart : cardTypeRaw == "phases" ? .phases : .general

        // поручаем открытие карточки
        openCard(for: cardType)
    }

    private func openCard(for cardType: CardType) {
        // этот момент (строчку 111) я пока детально не зашарил, но давай просто осознаем общую логику:
        // тут мы делегируем открытие карточки дальше по цепочке
        // теперь это задача для роутера экрана со списком карточек

        let feedListCoordinator = firstReceiver(as: FeedNavigationCoordinator.self,
                                                where: { $0.filter(cardType) })
        feedListCoordinator!.open(cardType)
    }

    private func openCalendar() {
        // logic
    }

    func open(_ url: URL) {
        self.openedURL = url
    }
}

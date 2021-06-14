import Foundation
import SwiftUI
import XUI

// all types of main tab bar windows
enum TabBarTab: String {
    case summary
    case history
    case alarm
    case settings
}

// MARK: - Protocol

protocol RootCoordinator: ViewModel {
    
    var tab: TabBarTab { get set }
    
    var feedCoordinator: FeedNavigationCoordinator! { get }
    var historyCoordinator: HistoryCoordinator! { get }
    var alarmCoordinator: AlarmCoordinator! { get }
    var settingsCoordinator: SettingsCoordinator! { get }
    
    var openedURL: URL? { get set }
    
    func startDeepLink(from url: URL)
    
    func open(_ url: URL)
    
}

extension RootCoordinator {
    
    @DeepLinkableBuilder
    var children: [DeepLinkable] {
        feedCoordinator
        historyCoordinator
        alarmCoordinator
        settingsCoordinator
    }
    
}

// MARK: - Implementation

class RootCoordinatorImpl: ObservableObject, RootCoordinator {
    
    // MARK: Stored Properties
    
    @Published var tab = TabBarTab.summary
    @Published var openedURL: URL?
    
    @Published private(set) var feedCoordinator: FeedNavigationCoordinator!
    @Published private(set) var historyCoordinator: HistoryCoordinator!
    @Published private(set) var alarmCoordinator: AlarmCoordinator!
    @Published private(set) var settingsCoordinator: SettingsCoordinator!
    
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
        
        self.historyCoordinator = HistoryCoordinatorImpl(
            title: "history",
            parent: self)
        
        self.alarmCoordinator = AlarmCoordinatorImpl(
            title: "alarm",
            parent: self)
        
        self.settingsCoordinator = SettingsCoordinatorImpl(
            title: "settings",
            parent: self)
    }
    
    // MARK: Internal Methods
    
    func open(_ url: URL) {
        self.openedURL = url
    }
    
    func startDeepLink(from url: URL) {
        if let scheme = url.scheme {
            switch scheme {
            case "summary":
                guard url.host == "card",
                      let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                      let cardTypeRaw = components.queryItems?.first(where: { $0.name == "type" })?.value else {
                          assertionFailure("Trying to open app with illegal url \(url).")
                          return
                      }
                let cardType: CardType = cardTypeRaw == "heart" ? .heart : cardTypeRaw == "phases" ? .phases : .general
                openCard(for: cardType)
            case "history":
                openTabView(of: .history)
            case "alarm":
                openTabView(of: .alarm)
            case "settings":
                openTabView(of: .settings)
            default:
                assertionFailure("Trying to open app with illegal url \(url).")
            }
        } else { assertionFailure("Trying to open app with illegal url \(url).") }
    }
    
    // MARK: Private Methods
    
    private func openCard(for cardType: CardType) {
        // этот момент (строчку 111) я пока детально не зашарил, но давай просто осознаем общую логику:
        // тут мы делегируем открытие карточки дальше по цепочке
        // теперь это задача для роутера экрана со списком карточек
        
        let feedListCoordinator = firstReceiver(as: FeedNavigationCoordinator.self,
                                                where: { $0.filter(cardType) })
        feedListCoordinator!.open(cardType)
    }
    
    private func openTabView(of type: TabBarTab) {
        switch type {
        case .history:
            tab = .history
        case .alarm:
            tab = .alarm
        case .settings:
            tab = .settings
        case .summary:
            break
        }
    }
    
}

import Foundation
import SwiftUI
import XUI
import HKCoreSleep
import HKStatistics
import HKVisualKit
import SettingsKit

// all types of main tab bar windows
enum TabBarTab: String {

    case summary
    case history
    case alarm
    case soundRecognision
    case settings
}

extension RootCoordinator {
    
    @DeepLinkableBuilder
    var children: [DeepLinkable] {
        summaryCoordinator
        historyCoordinator
        alarmCoordinator
        soundsCoordinator
        settingsCoordinator
    }
    
}

class RootCoordinator: ObservableObject, ViewModel {
    
    @Published var tab = TabBarTab.summary
    @Published var openedURL: URL?
    
    @Published private(set) var summaryCoordinator: SummaryNavigationCoordinator!
    @Published private(set) var historyCoordinator: HistoryCoordinator!
    @Published private(set) var alarmCoordinator: AlarmCoordinator!
    @Published private(set) var settingsCoordinator: SettingsCoordinator!
    @Published private(set) var soundsCoordinator: SoundsCoordinator!

    var colorSchemeProvider: ColorSchemeProvider
    var statisticsProvider: HKStatisticsProvider
    var hkStoreService: HKService
    
    init(colorSchemeProvider: ColorSchemeProvider,
         statisticsProvider: HKStatisticsProvider,
         hkStoreService: HKService) {
        // наш главный координатор таббара получил сервисы
        self.colorSchemeProvider = colorSchemeProvider
        self.statisticsProvider = statisticsProvider
        self.hkStoreService = hkStoreService
        
        // думаем, а какие сервисы понадобятся для экрана 1 страницы таббара (со списком карточек)
        // пока давай передадим и сервис здоровья, и сервис карточек (хотя насчет надобности второго я думаю)
        self.summaryCoordinator = SummaryNavigationCoordinator(
            colorProvider: colorSchemeProvider,
            statisticsProvider: statisticsProvider,
            title: "main list",
            hkStoreService: hkStoreService,
            parent: self
        )
        
        self.historyCoordinator = HistoryCoordinator(
            title: "history",
            colorSchemeProvider: colorSchemeProvider,
            statisticsProvider: statisticsProvider,
            parent: self)
        
        self.alarmCoordinator = AlarmCoordinator(
            title: "alarm",
            colorSchemeProvider: colorSchemeProvider,
            parent: self)

        self.soundsCoordinator = SoundsCoordinator(
            title: "sounds",
            colorSchemeProvider: colorSchemeProvider,
            parent: self)
        
        self.settingsCoordinator = SettingsCoordinator(
            title: "settings",
            parent: self)

    }
    
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
                let cardType: SummaryViewCardType = cardTypeRaw == "heart" ? .heart : cardTypeRaw == "phases" ? .phases : .general
//                openCard(for: cardType, with: <#AdvicesViewType#>)

            case "history":
                openTabView(of: .history)

            case "alarm":
                openTabView(of: .alarm)

            case "settings":
                openTabView(of: .settings)

            case "sounds":
                openTabView(of: .soundRecognision)

            default:
                assertionFailure("Trying to open app with illegal url \(url).")

            }
        } else {
            assertionFailure("Trying to open app with illegal url \(url).")
        }
    }
    
    func openCard(for cardType: SummaryViewCardType) {
        // этот момент (строчку 111) я пока детально не зашарил, но давай просто осознаем общую логику:
        // тут мы делегируем открытие карточки дальше по цепочке
        // теперь это задача для роутера экрана со списком карточек
        
        let feedListCoordinator = firstReceiver(as: SummaryNavigationCoordinator.self)
        feedListCoordinator!.open(cardType)
    }
    
    func openTabView(of type: TabBarTab) {
        switch type {
        case .history:
            tab = .history
        case .alarm:
            tab = .alarm
        case .settings:
            tab = .settings
        case .summary:
            break
        case .soundRecognision:
            tab = .soundRecognision
        }
    }
    
}

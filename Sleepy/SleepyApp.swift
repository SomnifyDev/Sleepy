import SwiftUI
import HKCoreSleep
import HKStatistics
import HKVisualKit
import SettingsKit

@main
struct SleepyApp: App {

    // MARK: Stored Properties
    @State var hkService: HKService?
    @State var cardService: CardService?
    @State var colorSchemeProvider: ColorSchemeProvider?
    @State var sleepDetectionProvider: HKSleepAppleDetectionProvider?
    @State var settingsProvider: SettingsProvider?

    @State var statisticsProvider: HKStatisticsProvider?
    @State var coordinator: RootCoordinatorImpl?

    @State var hasOpenedURL = false
    @State var canShowApp: Bool = false

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // MARK: Scenes
    var body: some Scene {
        WindowGroup {
            if canShowApp {
                RootCoordinatorView(viewModel: coordinator!)
                    .accentColor(colorSchemeProvider?.sleepyColorScheme.getColor(of: .general(.mainSleepyColor)))
                //.onOpenURL { coordinator!.startDeepLink(from: $0) }
                //.onAppear { simulateURLOpening() }
            } else {
                Text("Loading")
                    .onAppear {
                        
                        if !UserDefaults.standard.bool(forKey: "launchedBefore") {
                            UserDefaults.standard.set(true, forKey: "launchedBefore")
                            self.settingsProvider = SettingsProviderImpl()
                            self.settingsProvider?.saveSleepGoal(sleepGoal: 480) // в дальнейшем будем устанавливать значение, которое пользователь выбрал на старте, пока так
                        } else {
                            self.settingsProvider = SettingsProviderImpl()
                        }

                        self.hkService = self.appDelegate.hkService
                        self.sleepDetectionProvider = self.appDelegate.sleepDetectionProvider
                        self.colorSchemeProvider = ColorSchemeProvider()
                        self.cardService = CardService()

                        sleepDetectionProvider?.retrieveData { sleep in
                            if let sleep = sleep {
                                showDebugSleepDuration(sleep)

                                statisticsProvider = HKStatisticsProvider(sleep: sleep, healthService: hkService!)

                                coordinator = RootCoordinatorImpl(colorSchemeProvider: colorSchemeProvider!, statisticsProvider: statisticsProvider!, hkStoreService: hkService!, cardService: cardService!, settingsProvider: settingsProvider!)

                                // сон получен, сервисы, зависящие от ассинхронно-приходящего сна инициализированы, можно показывать прилу
                                canShowApp = true
                            }
                        }
                    }
            }
        }
    }

    // MARK: Private functions
    private func simulateURLOpening() {
#if DEBUG
        guard !hasOpenedURL else {
            return
        }
        hasOpenedURL = true

        self.cardService?.fetchCards { cards in
            // summary:// - открывает экран карточек
            // summary://card?type=heart - открывает детальную карточку сердца
            // summary://card?type=phases - открывает детальную карточку фаз
            // calendar:// - открывает календарь
            // alarm:// - открывает будильник
            // alarm://creation
            guard let cardType = cards.randomElement(),
                  // [tab name]://[element inside name]?[parameter]=value
                  let url = URL(string: "summary://card?type=" + cardType.rawValue) else {
                      assertionFailure("Could not find card or illegal url format.")
                      return
                  }

            coordinator!.startDeepLink(from: url)
        }
#endif
    }

    fileprivate func showDebugSleepDuration(_ sleep: Sleep) {
        print(sleep.sleepInterval.duration)
        print(sleep.inBedInterval.duration)
    }
    
}

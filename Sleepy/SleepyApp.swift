import SwiftUI
import HKCoreSleep
import HKStatistics
import HKVisualKit

@main
struct SleepyApp: App {

    // MARK: Stored Properties
    @State var hkService: HKService?
    @State var cardService: CardService?
    @State var colorSchemeProvider: ColorSchemeProvider?
    @State var sleepDetectionProvider: HKSleepAppleDetectionProvider?

    @State var statisticsProvider: HKStatisticsProvider?
    @State var coordinator: RootCoordinatorImpl?

    @State var hasOpenedURL = false
    @State var canShowApp: Bool = false

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    private let productURL = URL(string: "https://itunes.apple.com/app/id958625272")!

    // MARK: Scenes
    var body: some Scene {
        WindowGroup {
            if canShowApp {

                // TODO: перенести это в настройки когда они появятся. Это кнопка "поделиться приложением"
//                Button("Share app") {
//                    self.isSharePresented = true
//                }
//                .sheet(isPresented: $isSharePresented, onDismiss: {
//                    print("Dismiss")
//                }, content: {
//                    ActivityViewController(activityItems: [URL(string: "https://www.apple.com")!])
//                })


                RootCoordinatorView(viewModel: coordinator!)
                    .accentColor(colorSchemeProvider?.sleepyColorScheme.getColor(of: .general(.mainSleepyColor)))
                //.onOpenURL { coordinator!.startDeepLink(from: $0) }
                //.onAppear { simulateURLOpening() }
            } else {
                Text("Loading")
                    .onAppear {
                        // показывает плашку "оцените прилу" если выполняются условия к показу
                        AppStoreReviewManager.requestReviewIfAppropriate()

                        self.hkService = self.appDelegate.hkService
                        self.sleepDetectionProvider = self.appDelegate.sleepDetectionProvider
                        self.colorSchemeProvider = ColorSchemeProvider()
                        self.cardService = CardService()

                        // TODO: перенести тоже в настройки. Это мануальный вызов "написать отзыв", перекидывающий в апстор
//                        self.requestReviewManually()

                        sleepDetectionProvider?.retrieveData { sleep in
                            if let sleep = sleep {
                                showDebugSleepDuration(sleep)

                                statisticsProvider = HKStatisticsProvider(sleep: sleep, healthService: hkService!)

                                coordinator = RootCoordinatorImpl(colorSchemeProvider: colorSchemeProvider!, statisticsProvider: statisticsProvider!, hkStoreService: hkService!, cardService: cardService!)

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

    private func requestReviewManually() {
        // Note: Replace the XXXXXXXXXX below with the App Store ID for your app
        //       You can find the App Store ID in your app's product URL
        guard let writeReviewURL = URL(string: "https://apps.apple.com/app/id1540353726?action=write-review")
            else { fatalError("Expected a valid URL") }
        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
    }

    fileprivate func showDebugSleepDuration(_ sleep: Sleep) {
        print(sleep.sleepInterval.duration)
        print(sleep.inBedInterval.duration)
    }
    
}

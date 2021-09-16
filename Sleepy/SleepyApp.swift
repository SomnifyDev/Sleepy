import SwiftUI
import HKCoreSleep
import HKStatistics
import HKVisualKit
import SettingsKit
import Armchair

@main
struct SleepyApp: App {

    @State var hkService: HKService?
    @State var cardService: CardService!
    @State var colorSchemeProvider: ColorSchemeProvider?
    @State var sleepDetectionProvider: HKSleepAppleDetectionProvider?
    @State var statisticsProvider: HKStatisticsProvider?

    @State var viewModel: RootCoordinator?

    @State var hasOpenedURL = false
    @State var canShowApp: Bool = false

    @State var sleep: Sleep?

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {

            if canShowApp {
                RootCoordinatorView(viewModel: viewModel!)
                    .environmentObject(cardService)
                    .accentColor(colorSchemeProvider?.sleepyColorScheme.getColor(of: .general(.mainSleepyColor)))
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                        let interval = DateInterval(start: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, end: Date())
                        self.hkService?.readData(type: .asleep, interval: interval, ascending: false, bundlePrefixes: ["com.apple"], completionHandler: { _, samples, error in
                            guard error == nil,
                                  let sample = samples?.first,
                                  let sleep = self.sleep  else { return }
                            if abs(sample.endDate.minutes(from: sleep.sleepInterval.end)) >= 60 {
                                self.canShowApp = false
                            }
                        })
                    }
                //.onOpenURL { coordinator!.startDeepLink(from: $0) }
                //.onAppear { simulateURLOpening() }
            } else {
                Text("Loading".localized)
                    .onAppear {
                        if !UserDefaults.standard.bool(forKey: "launchedBefore") {
                            UserDefaults.standard.set(true, forKey: "launchedBefore")
                            UserDefaults.standard.setInt(480, forKey: .sleepGoal)
                        }
                        self.hkService = self.appDelegate.hkService
                        self.sleepDetectionProvider = self.appDelegate.sleepDetectionProvider
                        self.colorSchemeProvider = ColorSchemeProvider()
                        sleepDetectionProvider?.retrieveData { sleep in
                            if let sleep = sleep {
                                self.sleep = sleep
                                self.showDebugSleepDuration(sleep)

                                self.statisticsProvider = HKStatisticsProvider(sleep: sleep, healthService: hkService!)

                                self.cardService = CardService(statisticsProvider: self.statisticsProvider!)

                                self.viewModel = RootCoordinator(colorSchemeProvider: colorSchemeProvider!,
                                                                  statisticsProvider: statisticsProvider!,
                                                                  hkStoreService: hkService!)

                                // сон получен, сервисы, зависящие от ассинхронно-приходящего сна инициализированы, можно показывать прилу
                                self.canShowApp = true

                                DispatchQueue.main.asyncAfter(deadline: .now() + 7.5) {
                                    Armchair.userDidSignificantEvent(true)
                                }
                            } else {
                                // сон не был прочитан успешно
                                self.statisticsProvider = HKStatisticsProvider(sleep: nil,
                                                                          healthService: hkService!)
                                self.viewModel = RootCoordinator(colorSchemeProvider: colorSchemeProvider!, statisticsProvider: statisticsProvider!, hkStoreService: hkService!)

                                self.canShowApp = true
                            }
                        }
                    }
            }
        }
    }

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

            viewModel!.startDeepLink(from: url)
        }
#endif
    }

    fileprivate func showDebugSleepDuration(_ sleep: Sleep) {
        print(sleep.sleepInterval.duration)
        print(sleep.inBedInterval.duration)
    }
    
}

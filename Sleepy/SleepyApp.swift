import Armchair
import Firebase
import HKCoreSleep
import HKStatistics
import HKVisualKit
import SettingsKit
import SwiftUI

@main
struct SleepyApp: App {
    // MARK: Properties

    @State var hkService: HKService?
    @State var cardService: CardService!

    let colorSchemeProvider: ColorSchemeProvider
    @State var sleepDetectionProvider: HKSleepAppleDetectionProvider?
    @State var statisticsProvider: HKStatisticsProvider?

    @State var rootViewModel: RootCoordinator?
    @State var introViewModel: IntroCoordinator?

    @State var hasOpenedURL = false
    @State var canShowMain: Bool = false
    @State var shouldShowIntro: Bool = false
    @State var sleep: Sleep?

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        FirebaseApp.configure()

        colorSchemeProvider = ColorSchemeProvider()

        if !UserDefaults.standard.bool(forKey: "launchedBefore") {
            _shouldShowIntro = State(initialValue: true)
            _introViewModel = State(initialValue: IntroCoordinator(colorSchemeProvider: colorSchemeProvider))
        }
    }

    var body: some Scene {
        WindowGroup {
            if canShowMain {
                RootCoordinatorView(viewModel: rootViewModel!)
                    .environmentObject(cardService)
                    .accentColor(colorSchemeProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor)))
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                        UIApplication.shared.applicationIconBadgeNumber = 0

                        let interval = DateInterval(start: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, end: Date())
                        self.hkService?.readData(type: .asleep,
                                                 interval: interval,
                                                 ascending: false,
                                                 bundlePrefixes: ["com.apple"],
                                                 completionHandler: { _, samples, error in
                                                     guard error == nil,
                                                           let sample = samples?.first,
                                                           let sleep = self.sleep else { return }
                                                     if abs(sample.endDate.minutes(from: sleep.sleepInterval.end)) >= 60 {
                                                         self.canShowMain = false
                                                     }
                                                 })
                    }
                // .onOpenURL { coordinator!.startDeepLink(from: $0) }
                // .onAppear { simulateURLOpening() }
            } else if shouldShowIntro {
                IntroCoordinatorView(viewModel: introViewModel!, shouldShowIntro: self.$shouldShowIntro)
                    .accentColor(self.colorSchemeProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor)))
            } else {
                Text("Loading".localized)
                    .onAppear {
                        if !UserDefaults.standard.bool(forKey: "launchedBefore") {
                            UserDefaults.standard.set(true, forKey: "launchedBefore")
                            self.setAllUserDefaults()
                        }

                        self.hkService = self.appDelegate.hkService
                        self.sleepDetectionProvider = self.appDelegate.sleepDetectionProvider

                        self.retrieveSleep()
                    }
            }
        }
    }

    // MARK: Private methods

    private func retrieveSleep() {
        sleepDetectionProvider?.retrieveData { sleep in
            guard let sleep = sleep else {
                // сон не был прочитан
                self.statisticsProvider = HKStatisticsProvider(sleep: nil,
                                                               healthService: hkService!)
                self.cardService = CardService(statisticsProvider: self.statisticsProvider!)
                self.rootViewModel = RootCoordinator(colorSchemeProvider: colorSchemeProvider, statisticsProvider: statisticsProvider!, hkStoreService: hkService!)

                self.canShowMain = true
                return
            }
            // сон прочитался
            self.showDebugSleepDuration(sleep)

            self.statisticsProvider = HKStatisticsProvider(sleep: sleep, healthService: hkService!)
            self.cardService = CardService(statisticsProvider: self.statisticsProvider!)
            self.rootViewModel = RootCoordinator(colorSchemeProvider: colorSchemeProvider,
                                                 statisticsProvider: statisticsProvider!,
                                                 hkStoreService: hkService!)

            DispatchQueue.main.asyncAfter(deadline: .now() + 7.5) {
                Armchair.userDidSignificantEvent(true)
            }
            self.canShowMain = true
        }
    }

    /// Установка дефолтных значений настроек
    private func setAllUserDefaults() {
        SleepySettingsKeys.allCases.forEach {
            switch $0 {
            case .sleepGoal:
                let defaultSleepGoal = SleepySettingsKeys.sleepGoal.settingKeyIntegerValue
                UserDefaults.standard.set(defaultSleepGoal, forKey: SleepySettingsKeys.sleepGoal.rawValue)
            case .soundBitrate:
                let defaultSoundBitrate = SleepySettingsKeys.soundBitrate.settingKeyIntegerValue
                UserDefaults.standard.set(defaultSoundBitrate, forKey: SleepySettingsKeys.soundBitrate.rawValue)
            case .soundRecognisionConfidence:
                let defaultSoundRecognisionConfidence = SleepySettingsKeys.soundRecognisionConfidence.settingKeyIntegerValue
                UserDefaults.standard.set(defaultSoundRecognisionConfidence, forKey: SleepySettingsKeys.soundRecognisionConfidence.rawValue)
            }
        }
    }

    private func simulateURLOpening() {
        #if DEBUG
            guard !hasOpenedURL else {
                return
            }
            hasOpenedURL = true

            cardService?.fetchCards { cards in
                // summary:// - открывает экран карточек
                // summary://card?type=heart - открывает детальную карточку сердца
                // summary://card?type=phases - открывает детальную карточку фаз
                // calendar:// - открывает календарь
                // alarm:// - открывает будильник
                // alarm://creation
                guard let cardType = cards.randomElement(),
                      // [tab name]://[element inside name]?[parameter]=value
                      let url = URL(string: "summary://card?type=" + cardType.rawValue)
                else {
                    assertionFailure("Could not find card or illegal url format.")
                    return
                }

                rootViewModel!.startDeepLink(from: url)
            }
        #endif
    }

    private func showDebugSleepDuration(_ sleep: Sleep) {
        print(sleep.sleepInterval.duration)
        print(sleep.inBedInterval.duration)
    }
}

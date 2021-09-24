import SwiftUI
import HKCoreSleep
import HKStatistics
import HKVisualKit
import SettingsKit
import Armchair
import Firebase

@main
struct SleepyApp: App {

    // MARK: Properties

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

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if canShowApp {
                RootCoordinatorView(viewModel: viewModel!)
                    .environmentObject(cardService)
                    .accentColor(colorSchemeProvider?.sleepyColorScheme.getColor(of: .general(.mainSleepyColor)))
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
                            self.setAllUserDefaults()
                        }

                        self.hkService = self.appDelegate.hkService
                        self.sleepDetectionProvider = self.appDelegate.sleepDetectionProvider
                        self.colorSchemeProvider = ColorSchemeProvider()

                        self.retrieveSleep()
                    }
            }
        }
    }

    // MARK: Private methods

    private func retrieveSleep() {
            self.sleepDetectionProvider?.retrieveData { sleep in
                guard let sleep = sleep else {
                    // сон не был прочитан
                    self.statisticsProvider = HKStatisticsProvider(sleep: nil,
                                                                   healthService: hkService!)
                    self.viewModel = RootCoordinator(colorSchemeProvider: colorSchemeProvider!, statisticsProvider: statisticsProvider!, hkStoreService: hkService!)

                    self.canShowApp = true
                    return
                }
                // сон прочитался
                self.showDebugSleepDuration(sleep)

                self.statisticsProvider = HKStatisticsProvider(sleep: sleep, healthService: hkService!)
                self.cardService = CardService(statisticsProvider: self.statisticsProvider!)
                self.viewModel = RootCoordinator(colorSchemeProvider: colorSchemeProvider!,
                                                 statisticsProvider: statisticsProvider!,
                                                 hkStoreService: hkService!)

                DispatchQueue.main.asyncAfter(deadline: .now() + 7.5) {
                    Armchair.userDidSignificantEvent(true)
                }
                self.canShowApp = true
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

    private func showDebugSleepDuration(_ sleep: Sleep) {
        print(sleep.sleepInterval.duration)
        print(sleep.inBedInterval.duration)
    }
    
}

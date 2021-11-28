// Copyright (c) 2021 Sleepy.

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

        self.colorSchemeProvider = ColorSchemeProvider()

        if !UserDefaults.standard.bool(forKey: "launchedBefore") {
            _shouldShowIntro = State(initialValue: true)
            _introViewModel = State(initialValue: IntroCoordinator(colorSchemeProvider: self.colorSchemeProvider))
        }
    }

    var body: some Scene {
        WindowGroup {
            if canShowMain {
                RootCoordinatorView(viewModel: rootViewModel!)
                    .environmentObject(cardService)
                    .accentColor(colorSchemeProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor)))
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification))
                    { _ in
                        UIApplication.shared.applicationIconBadgeNumber = 0
                        guard let sleep = self.sleep else { return }

                        let interval = DateInterval(start: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, end: Date())
                        self.hkService?.readData(
                            type: .asleep,
                            interval: interval,
                            ascending: false,
                            bundlePrefixes: ["com.apple"],
                            completionHandler: { _, samples, error in
                                guard error == nil,
                                      let sample = samples?.first else { return }
                                if abs(sample.startDate.minutes(from: sleep.sleepInterval.end)) >= 60
                                {
                                    // сбрасываем до экрана loading чтоб пересчитался сон
                                    self.canShowMain = false
                                }
                            }
                        )
                    }
                    // .onOpenURL { coordinator!.startDeepLink(from: $0) }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            setupAppIcon()
                        }
                        //                     simulateURLOpening()
                    }
            } else if shouldShowIntro {
                IntroCoordinatorView(viewModel: introViewModel!, shouldShowIntro: self.$shouldShowIntro)
                    .accentColor(self.colorSchemeProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor)))
            } else {
                Text("Loading")
                    .onAppear {
                        self.setAllUserDefaultsIfNeeded()

                        self.hkService = self.appDelegate.hkService
                        self.sleepDetectionProvider = self.appDelegate.sleepDetectionProvider

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
                self.statisticsProvider = HKStatisticsProvider(
                    sleep: nil,
                    healthService: hkService!
                )
                self.cardService = CardService(statisticsProvider: self.statisticsProvider!)
                self.rootViewModel = RootCoordinator(colorSchemeProvider: colorSchemeProvider, statisticsProvider: statisticsProvider!, hkStoreService: hkService!)

                self.canShowMain = true
                return
            }
            // сон прочитался
            self.showDebugSleepDuration(sleep)

            self.statisticsProvider = HKStatisticsProvider(sleep: sleep, healthService: hkService!)
            self.cardService = CardService(statisticsProvider: self.statisticsProvider!)
            self.rootViewModel = RootCoordinator(
                colorSchemeProvider: colorSchemeProvider,
                statisticsProvider: statisticsProvider!,
                hkStoreService: hkService!
            )

            DispatchQueue.main.asyncAfter(deadline: .now() + 7.5) {
                Armchair.userDidSignificantEvent(true)
            }
            self.canShowMain = true
        }
    }

    /// Установка дефолтных значений настроек
    private func setAllUserDefaultsIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: "launchedBefore") else { return }

        UserDefaults.standard.set(true, forKey: "launchedBefore")
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

    private func setupAppIcon() {
        let application = UIApplication.shared
        let currentSystemScheme = UITraitCollection.current.userInterfaceStyle

        if application.supportsAlternateIcons {
            if application.alternateIconName == nil, currentSystemScheme == .dark {
                application.setAlternateIconName("darkIcon")
            } else if application.alternateIconName == "darkIcon", currentSystemScheme == .light {
                application.setAlternateIconName(nil)
            }
        }
    }

    private func simulateURLOpening() {
        #if DEBUG
            guard !self.hasOpenedURL else {
                return
            }
            self.hasOpenedURL = true

            self.cardService?.fetchCards { cards in
                // summary:// - открывает экран карточек
                // summary://card?type=heart - открывает детальную карточку сердца
                // summary://card?type=phases - открывает детальную карточку фаз
                // calendar:// - открывает календарь
                // alarm:// - открывает будильник
                // alarm://creation
                guard let cardType = cards.randomElement(),
                      // [tab name]://[element inside name]?[parameter]=value
                      let url = URL(string: "summary://card?type=" + cardType.rawValue) else
                {
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

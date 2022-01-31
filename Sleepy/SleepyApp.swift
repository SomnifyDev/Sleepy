// Copyright (c) 2022 Sleepy.

import Armchair
import Firebase
import HKCoreSleep
import HKStatistics
import SettingsKit
import SwiftUI
import UIComponents

@main
struct SleepyApp: App {
    // MARK: - Properties

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @State var hkService: HKService?
    @State var cardService: CardService!
    @State var sleepDetectionProvider: HKSleepAppleDetectionProvider?
    @State var statisticsProvider: HKStatisticsProvider?
    @State var rootViewModel: RootCoordinator?
    @State var introViewModel: IntroCoordinator?
    @State var hasOpenedURL = false
    @State var canShowMain: Bool = false
    @State var shouldShowIntro: Bool = false
    @State var sleep: Sleep?

    var body: some Scene {
        WindowGroup {
            if canShowMain {
                RootCoordinatorView(viewModel: rootViewModel!)
                    .environmentObject(cardService)
                    .accentColor(ColorsRepository.General.mainSleepy)
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
                                      let newSample = samples?.first,
                                      let previousSleep = self.sleep?.sleepInterval else { return }
                                // если есть сон новее
                                // сбрасываем до экрана loading чтоб пересчитался сон
                                if abs(newSample.startDate.minutes(from: previousSleep.end)) >= HKCoreSleep.HKSleepAppleDetectionProvider.Constants.maximalSleepDifference
                                {
                                    self.canShowMain = false
                                }
                            }
                        )
                    }
            } else if shouldShowIntro {
                IntroCoordinatorView(viewModel: introViewModel!, shouldShowIntro: self.$shouldShowIntro)
                    .accentColor(ColorsRepository.General.mainSleepy)
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

    // MARK: - Init

    init() {
        FirebaseApp.configure()
        if !UserDefaults.standard.bool(forKey: "launchedBefore") {
            _shouldShowIntro = State(initialValue: true)
            _introViewModel = State(initialValue: IntroCoordinator())
        }
    }

    // MARK: Private methods

    private func retrieveSleep() {
        self.sleepDetectionProvider?.retrieveData { sleep in
            guard let sleep = sleep
            else {
                // сон не был прочитан
                self.sleep = sleep
                self.statisticsProvider = HKStatisticsProvider(
                    sleep: nil,
                    healthService: hkService!
                )
                self.cardService = CardService(statisticsProvider: self.statisticsProvider!)
                self.rootViewModel = RootCoordinator(statisticsProvider: statisticsProvider!, hkStoreService: hkService!)

                self.canShowMain = true
                return
            }
            // сон прочитался
            self.showDebugSleepDuration(sleep: sleep)

            self.statisticsProvider = HKStatisticsProvider(sleep: sleep, healthService: hkService!)
            self.cardService = CardService(statisticsProvider: self.statisticsProvider!)
            self.rootViewModel = RootCoordinator(
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

    private func simulateURLOpening() {
        #if DEBUG
            guard !self.hasOpenedURL
            else {
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
                      let url = URL(string: "summary://card?type=" + cardType.rawValue)
                else {
                    assertionFailure("Could not find card or illegal url format.")
                    return
                }

                rootViewModel!.startDeepLink(from: url)
            }
        #endif
    }

    private func showDebugSleepDuration(sleep: Sleep) {
        sleep.samples.forEach { sample in
            print(sample.sleepInterval.stringFromDateInterval(type: .time))
        }
    }
}

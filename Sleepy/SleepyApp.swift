import SwiftUI
import HKCoreSleep
import HKStatistics
import HKVisualKit
import HealthKit

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

    let notificationCenter = UNUserNotificationCenter.current()

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

                        self.hkService = self.appDelegate.hkService
                        self.sleepDetectionProvider = self.appDelegate.sleepDetectionProvider
                        self.colorSchemeProvider = ColorSchemeProvider()
                        self.cardService = CardService()

                        sleepDetectionProvider?.retrieveData { sleep in
                            if let sleep = sleep {
                                showDebugSleepDuration(sleep)

                                statisticsProvider = HKStatisticsProvider(sleep: sleep, healthService: hkService!)

                                saveSleep(sleep: sleep, completionHandler: { result, error in
                                    print("new sleep saved")
                                    // TODO: handle error if so
                                })

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

    /// Saves sleep analysis as inBed & Asleep samples in HealthStore
    /// - Parameters:
    ///   - sleep: sleep object to be saved
    ///   - completionHandler: completion with success or failure of this operation
    func saveSleep(sleep: Sleep, completionHandler: @escaping (Bool, Error?) -> Void) {
        // checking sleep analysis existence
        self.hkService?.readData(type: .asleep, interval: sleep.sleepInterval, bundlePrefixes: ["com.benmustafa", "com.sinapsis"], completionHandler: { _, samples, _ in
            guard let samples = samples, samples.isEmpty else {
                return
            }

            scheduleNotification(title: "ACTUALLY SAVING", body: "saving sleep")

            if let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
                var metadata: [String: Any] = [:]

                if let value = statisticsProvider?.getData(dataType: .heart, indicatorType: .mean) {
                    metadata["Heart rate mean"] = value
                }
                if let value = statisticsProvider?.getData(dataType: .energy, indicatorType: .sum) {
                    metadata["Energy consumption"] = value
                }

                let asleepSample = HKCategorySample(type: sleepType,
                                                    value: HKCategoryValueSleepAnalysis.asleep.rawValue,
                                                    start: sleep.sleepInterval.start,
                                                    end: sleep.sleepInterval.end)

                let inBedSample = HKCategorySample(type: sleepType,
                                                   value: HKCategoryValueSleepAnalysis.inBed.rawValue,
                                                   start: sleep.inBedInterval.start,
                                                   end: sleep.inBedInterval.end,
                                                   metadata: metadata)

                self.hkService?.writeData(objects: [asleepSample, inBedSample], type: .asleep, completionHandler: completionHandler)
            }
        })
    }

    func scheduleNotification(title: String, body: String) {
        // TODO: вынести в отдельную сущность
        let content = UNMutableNotificationContent()
        let categoryIdentifier = "Deleteeeew Notification Type"

        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.badge = 1
        content.categoryIdentifier = categoryIdentifier

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let identifier = "Localle Notification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }

        let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
        let deleteAction = UNNotificationAction(identifier: "DeleteAction", title: "Delete", options: [.destructive])
        let category = UNNotificationCategory(identifier: categoryIdentifier,
                                              actions: [snoozeAction, deleteAction],
                                              intentIdentifiers: [],
                                              options: [])

        notificationCenter.setNotificationCategories([category])
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

            coordinator!.startDeepLink(from: url)
        }
#endif
    }

    fileprivate func showDebugSleepDuration(_ sleep: Sleep) {
        print("asleep")
        print(sleep.sleepInterval.start.getFormattedDate(format: "dd.MM.yyyy HH:mm"))
        print(sleep.sleepInterval.end.getFormattedDate(format: "dd.MM.yyyy HH:mm"))

        print("inbed")
        print(sleep.inBedInterval.start.getFormattedDate(format: "dd.MM.yyyy HH:mm"))
        print(sleep.inBedInterval.end.getFormattedDate(format: "dd.MM.yyyy HH:mm"))
    }

}

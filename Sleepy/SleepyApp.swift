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

    // MARK: Scenes

    var body: some Scene {
        WindowGroup {
            if canShowApp {
                RootCoordinatorView(coordinator: coordinator!)
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

    // TODO: - move to extension later
    private func getFormattedDate(date: Date, _ format: String = "dd.MM", dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        dateformat.dateStyle = dateStyle
        dateformat.timeStyle = timeStyle
        dateformat.timeZone = TimeZone.current
        dateformat.locale = Locale.init(identifier: Locale.preferredLanguages.first!)

        return dateformat.string(from: date)
    }

    fileprivate func showDebugSleepDuration(_ sleep: Sleep) {
        print(UTCToLocal(currentDate: sleep.sleepInterval.start))
        print(UTCToLocal(currentDate: sleep.sleepInterval.end))

        print("inbed")
        print(UTCToLocal(currentDate: sleep.inBedInterval.start))
        print(UTCToLocal(currentDate: sleep.inBedInterval.end))
    }

    private func UTCToLocal(currentDate: Date, format: String = "dd.MM.yyyy HH:mm") -> String {

        // 4) Set the current date, altered by timezone.
        let dateString = getFormattedDate(date: currentDate, dateStyle: .medium, timeStyle: .medium)
        return dateString
    }

}

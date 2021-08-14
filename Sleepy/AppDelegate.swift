import UIKit
import UserNotifications
import HKCoreSleep
import Armchair

class AppDelegate: NSObject, UIApplicationDelegate {

    let appID = "361309726" // Pages iOS for armchair. TODO: replace with ours
    let notificationCenter = UNUserNotificationCenter.current()

    var hkService: HKService
    var sleepDetectionProvider: HKSleepAppleDetectionProvider

    override init() {
        hkService = HKService()
        sleepDetectionProvider = HKSleepAppleDetectionProvider(hkService: hkService)

        super.init()
    }

    func application(_ application: UIApplication,
                     willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        self.setupArmchair()
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        print("Application did finished launching with options")

        notificationCenter.delegate = self
        self.registerForPushNotifications { [weak self] result, error in
            guard error == nil else {
                return
            }
            self?.setupBackground()
        }

        return true
    }

    func setupBackground() {
        // Setup HK observers to monitor changes
        self.hkService.enableBackgroundDelivery { [weak self] result, error in
            guard error == nil else {
                return
            }

            self?.sleepDetectionProvider.observeData()
        }
    }

    func registerForPushNotifications(completionHandler: @escaping (Bool, Error?) -> Void) {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]

        self.notificationCenter.requestAuthorization(options: options, completionHandler: completionHandler)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        if response.notification.request.identifier == "Local Notification" {
            print("Handling notifications with the Local Notification Identifier")
        }

        completionHandler()
    }
}

extension AppDelegate {

    func setupArmchair() {
        // Normally, all the setup would be here.
        // It is always best to load Armchair as early as possible
        // because it needs to receive application life-cycle notifications
        //
        // NOTE: The appID call always has to go before any other Armchair calls
        Armchair.appID(appID)

        // This overrides the default value, read from your localized bundle plist
        Armchair.appName("Sleepy")

        // Debug means that it will popup on the next available change
        Armchair.debugEnabled(true)

        // This overrides the default value of 30, but it doesn't matter here because of Debug mode enabled
        Armchair.daysUntilPrompt(1)

        // This overrides the default value of 1, but it doesn't matter here because of Debug mode enabled
        Armchair.daysBeforeReminding(3)

        // This means that the popup won't show if you have already rated any version of the app, but it doesn't matter here because of Debug mode enabled
        Armchair.shouldPromptIfRated(true)

        // This overrides the default value of 20, but it doesn't matter here because of Debug mode enabled
        Armchair.significantEventsUntilPrompt(4)

        // This means that UAAppReviewManager won't track this version if it hasn't already, but it doesn't matter here because of Debug mode enabled
        Armchair.tracksNewVersions(true) // TODO: is it important?

        Armchair.opensInStoreKit(false) // TODO: если ставлю true, оно открывает внутри прилы, как бы поверх, но не открывается экран отзыва. Баг?

        // UAAppReviewManager comes with standard translations for dozens of Languages. If you want to provide your own translations instead,
        //  or you change the default title, message or button titles, set this to YES.
        Armchair.useMainAppBundleForLocalizations(false)

        // This sets a custom tint color  (applies only to UIAlertController).
        Armchair.tintColor(tintColor: UIColor(named: "lightSleepColor"))
    }
}

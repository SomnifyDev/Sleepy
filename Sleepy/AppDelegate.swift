import UIKit
import UserNotifications
import HKCoreSleep

class AppDelegate: NSObject, UIApplicationDelegate {

    let notificationCenter = UNUserNotificationCenter.current()
    var hkService: HKService
    var sleepDetectionProvider: HKSleepAppleDetectionProvider

    override init() {
        hkService = HKService()
        sleepDetectionProvider = HKSleepAppleDetectionProvider(hkService: hkService)

        super.init()
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

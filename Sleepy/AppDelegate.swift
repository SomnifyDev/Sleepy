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
                self?.scheduleNotification(title: "error", body: "error while registering For PushNotifications")
                return
            }

            self?.scheduleNotification(title: "success", body: "now push notifications are working")
            self?.setupBackground()

        }

        return true
    }

    func setupBackground() {
        // Setup HK observers to monitor changes
        self.hkService.enableBackgroundDelivery { [weak self] result, error in
            self?.scheduleNotification(title: "background enabled: \(result)",
                                       body: "\(error?.localizedDescription)")
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

    func scheduleNotification(title: String, body: String) {
        // TODO: вынести в отдельную сущность
        let content = UNMutableNotificationContent()
        let categoryIdentifier = "Deletee Notification Type"

        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.badge = 1
        content.categoryIdentifier = categoryIdentifier

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let identifier = "Locall Notification"
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
}

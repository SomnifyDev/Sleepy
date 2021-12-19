// Copyright (c) 2021 Sleepy.

import Armchair
import HKCoreSleep
import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate
{
    let appID = "361309726" // Pages iOS for armchair. TODO: replace with ours
    let notificationCenter = UNUserNotificationCenter.current()

    var hkService: HKService
    var sleepDetectionProvider: HKSleepAppleDetectionProvider

    override init()
    {
        self.hkService = HKService()
        self.sleepDetectionProvider = HKSleepAppleDetectionProvider(hkService: self.hkService)

        super.init()
    }

    func application(_: UIApplication,
                     willFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool
    {
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
        setupArmchair()
        return true
    }

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool
    {
        print("Application did finished launching with options")

        self.notificationCenter.delegate = self
        self.notificationCenter.removePendingNotificationRequests(withIdentifiers: ["Sleepy Notification"])
        // настраиваем сесcию, которая будет в дальнейшем реагировать на появление сэмплов от эпла
        self.setupBackground()

        return true
    }

    func setupBackground()
    {
        // Setup HK observers to monitor changes
        self.hkService.enableBackgroundDelivery
        { [weak self] _, error in
            guard error == nil else
            {
                return
            }

            self?.sleepDetectionProvider.observeData()
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate
{
    func userNotificationCenter(_: UNUserNotificationCenter,
                                willPresent _: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        if #available(iOS 14.0.0, *)
        {
            completionHandler([.sound])
        }
        else
        {
            completionHandler([.alert, .sound])
        }
    }

    func userNotificationCenter(_: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void)
    {
        if response.notification.request.identifier == "Sleepy Notification"
        {
            print("Handling notifications with the Sleepy Notification Identifier")
        }

        completionHandler()
    }
}

extension AppDelegate
{
    func setupArmchair()
    {
        // Normally, all the setup would be here.
        // It is always best to load Armchair as early as possible
        // because it needs to receive application life-cycle notifications
        //
        // NOTE: The appID call always has to go before any other Armchair calls
        Armchair.appID(self.appID)

        // This overrides the default value, read from your localized bundle plist
        Armchair.appName("Sleepy")

        // Debug means that it will popup on the next available change
        //        Armchair.debugEnabled(true)

        // This overrides the default value of 30, but it doesn't matter here because of Debug mode enabled
        Armchair.daysUntilPrompt(3)

        // This overrides the default value of 1, but it doesn't matter here because of Debug mode enabled
        Armchair.daysBeforeReminding(3)

        // The usesUntilPrompt configuration determines how many times the user will need to have 'used' the same version of you App before they will be prompted to rate it. Its default is 20 uses.
        Armchair.usesUntilPrompt(6)

        // This means that the popup won't show if you have already rated any version of the app, but it doesn't matter here because of Debug mode enabled
        Armchair.shouldPromptIfRated(true)

        // This overrides the default value of 20, but it doesn't matter here because of Debug mode enabled
        Armchair.significantEventsUntilPrompt(6)

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

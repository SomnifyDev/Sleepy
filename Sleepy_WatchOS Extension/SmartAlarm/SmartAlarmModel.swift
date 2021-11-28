// Copyright (c) 2021 Sleepy.

import Foundation
import HealthKit
import WatchKit

final class SmartAlarmModel: NSObject {
    private var session = WKExtendedRuntimeSession()
    private var healthStore = HKHealthStore()
    private let healthManager = HealthManager()
    private var didDetectedLightPhase: Bool = false
    private var seconds: Int = 1560 // Equals to 26 mins
    private var timer: Timer?

    override required init() {
        super.init()
        self.healthManager.delegate = self
    }

    // MARK: Methods

    func deactivateAlarm() {
        guard
            self.session.state == .scheduled || self.session.state == .running else
        {
            return
        }
        self.session.invalidate()
        print("Session was successfully deactivated")
    }

    func activateAlarm(alarmEnd: Date) -> Bool {
        guard
            alarmEnd.minutes(from: Date()) >= 29,
            let scheduledTime = Calendar.current.date(byAdding: .minute, value: -28, to: alarmEnd) else
        {
            return false
        }
        self.setSessionStartDate(at: scheduledTime)
        return true
    }

    // MARK: Private methods

    private func setSessionStartDate(at scheduledTime: Date) {
        self.session = WKExtendedRuntimeSession()
        self.session.delegate = self
        self.session.start(at: scheduledTime)
        print("Session was succesfully set to run at \(scheduledTime)")
    }

    private func runVibration() {
        UserSettings.isAlarmSet = false
        self.session.notifyUser(hapticType: .notification) { _ -> TimeInterval in
            2.5
        }
    }

    private func startTimer() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.timer = Timer.scheduledTimer(
                timeInterval: 1,
                target: self,
                selector: #selector(self.updateTimer),
                userInfo: nil,
                repeats: true
            )
            self.timer?.fire()
        }
    }

    @objc
    private func updateTimer() {
        guard self.seconds != 0 else {
            self.timer?.invalidate()
            self.runVibration()
            return
        }
        self.seconds -= 1
    }
}

// MARK: HealthManagerDelegate

extension SmartAlarmModel: HealthManagerDelegate {
    func lightPhaseDetected() {
        print("HealthManagerDelegate detected light phase")
        self.didDetectedLightPhase = true
        self.runVibration()
    }
}

// MARK: WKExtendedRuntimeSessionDelegate

extension SmartAlarmModel: WKExtendedRuntimeSessionDelegate {
    func extendedRuntimeSessionDidStart(_: WKExtendedRuntimeSession) {
        print("RuntimeSession did start")
        self.healthManager.subscribeToHeartBeatChanges()
        self.startTimer()
    }

    func extendedRuntimeSessionWillExpire(_: WKExtendedRuntimeSession) {
        print("extendedRuntimeSession will expire")
        UserSettings.isAlarmSet = false
    }

    func extendedRuntimeSession(_: WKExtendedRuntimeSession,
                                didInvalidateWith _: WKExtendedRuntimeSessionInvalidationReason,
                                error _: Error?)
    {
        UserSettings.isAlarmSet = false
    }
}

// MARK: WKExtensionDelegate

extension SmartAlarmModel: WKExtensionDelegate {
    // The system calls this method after launching your app in response to a scheduled extended runtime session.
    // This occurs if your app terminates after scheduling a session but before that session’s start date.
    // The system may also call this method if your app crashes during an extended runtime session, letting you resume that session.
    // When implementing this method, set the session’s delegate to resume the session.
    // If you do not set the session’s delegate, the system ends the session.
    func handle(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        extendedRuntimeSession.delegate = self
        self.session = extendedRuntimeSession
    }

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }
}

//
//  AlarmModel.swift
//  Sleepy_WatchOS Extension
//
//  Created by Анас Бен Мустафа on 9/27/21.
//

import Foundation
import WatchKit
import HealthKit

final class SmartAlarmModel: NSObject {

    private var session: WKExtendedRuntimeSession = WKExtendedRuntimeSession()
    private var healthStore: HKHealthStore = HKHealthStore()
    private let healthManager: HealthManager = HealthManager()
    private var didDetectedLightPhase: Bool = false

    override required init() {
        super.init()
        healthManager.delegate = self
    }

    // MARK: Methods

    func deactivateAlarm() {
        guard session.state == .running else {
            return
        }
        session.invalidate()
        print("session was deactivated")
    }

    func activateAlarm(alarmEnd: Date) {
        if session.state == .running || session.state == .scheduled {
            session.invalidate()
        }
        guard
            alarmEnd.minutes(from: Date()) >= 28,
            let scheduledTime = Calendar.current.date(byAdding: .minute, value: 25, to: alarmEnd)
        else {
            return
        }
        setSessionStartDate(at: scheduledTime)
        print("session was set")
    }

    // MARK: Private methods

    private func setSessionStartDate(at date: Date) {
        session = WKExtendedRuntimeSession()
        guard session.state == .notStarted else {
            return
        }
        session.delegate = self
        session.start(at: date)
    }

    private func runVibration() {
        guard session.state == .running else {
            return
        }
        session.notifyUser(hapticType: .notification) { (_) -> TimeInterval in
            return 3.5
        }
        UserSettings.isAlarmSet = false
    }
}

// MARK: HealthManagerDelegate

extension SmartAlarmModel: HealthManagerDelegate {

    func lightPhaseDetected() {
        print("HealthManagerDelegate detected light phase")
        didDetectedLightPhase = true
        self.runVibration()
    }

}

// MARK: WKExtendedRuntimeSessionDelegate

extension SmartAlarmModel: WKExtendedRuntimeSessionDelegate {

    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("RuntimeSession did start")
        healthManager.subscribeToHeartBeatChanges()
    }

    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("extendedRuntimeSession will expire")
        guard !didDetectedLightPhase else { return }
        UserSettings.isAlarmSet = false
        self.runVibration()
    }

    func extendedRuntimeSession(
        _ extendedRuntimeSession: WKExtendedRuntimeSession,
        didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason,
        error: Error?
    ) {
        // Track when your session ends.
        // Also handle errors here.
    }

}

// MARK: WKExtensionDelegate

extension SmartAlarmModel: WKExtensionDelegate {

    func handle(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("handled extendedRuntimeSession")
        session = extendedRuntimeSession
        session.delegate = self
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

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

}

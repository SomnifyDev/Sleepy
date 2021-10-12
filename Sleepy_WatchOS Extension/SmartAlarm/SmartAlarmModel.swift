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

    override init() {
        super.init()
        session.delegate = self
    }

    // MARK: Methods

    func deactivateAlarm() {
        guard session.state == .running else {
            return
        }
        session.invalidate()
    }

    func activateAlarm(alarmEnd: Date) {
        guard
            alarmEnd.minutes(from: Date()) >= 25,
            let scheduledTime = Calendar.current.date(byAdding: .minute, value: -25, to: alarmEnd)
        else {
            return
        }
        setSessionStartDate(at: scheduledTime)
    }

    // MARK: Private methods

    private func setSessionStartDate(at date: Date) {
        guard session.state == .notStarted else {
            return
        }
        session.start(at: date)
    }

    private func runVibration() {
        guard session.state == .running else {
            return
        }
        session.notifyUser(hapticType: .notification) { (_) -> TimeInterval in
            return 3.5
        }
    }
}

// MARK: WKExtendedRuntimeSessionDelegate

extension SmartAlarmModel: WKExtendedRuntimeSessionDelegate {

    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("RuntimeSession did start")
        // Вот здесь в теории надо запустить таймер на 25 минут и начать тречить сердце.
        // Если время таймера закончилось или отловилась лёгкая фаза - вызов runVibration()
    }

    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
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

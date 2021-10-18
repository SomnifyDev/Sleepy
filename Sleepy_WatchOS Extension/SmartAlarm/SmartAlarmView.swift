//
//  AlarmView.swift
//  Sleepy_WatchOS Extension
//
//  Created by Анас Бен Мустафа on 9/27/21.
//

import SwiftUI

struct AlarmView: View {
    @State private var selectedHour = Date().getHourInt()
    @State private var selectedMinute = Date().getMinuteInt()
    @State private var isAlarmActive = false
    private let smartAlarmModel: SmartAlarmModel = SmartAlarmModel()
    private let healthManager: HealthManager = HealthManager()
    private let hours = [Int](0...23)
    private let minutes = [Int](0...59)

    var body: some View {
        VStack {
            HStack {
                Picker("Hours".localized, selection: $selectedHour) {
                    ForEach(hours, id: \.self) {
                        Text(String($0))
                    }
                }

                Picker("Minutes".localized, selection: $selectedMinute) {
                    ForEach(minutes, id: \.self) {
                        Text(String($0))
                    }
                }
            }
            .frame(height: 70, alignment: .center)

            ScrollView {
                Button {
                    isAlarmActive ? deactivateAlarm() : activateAlarm()
                } label: {
                    Text(isAlarmActive ? "Cancel".localized : "Setup".localized)
                }
                .padding(.top, 8)

                Text("Smart alarm requires at least 30 minutes interval to be activated.".localized)
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }
        }
        .onAppear {
            setUpView()
        }
    }

    // MARK: Alarm methods

    private func activateAlarm() {
        setUserSettingsForActivatedAlarm()
        isAlarmActive = true
        let alarmEnd = Date().nextTimeMatchingComponents(components: DateComponents(hour: selectedHour, minute: selectedMinute))
        smartAlarmModel.activateAlarm(alarmEnd: alarmEnd)
    }
    
    private func deactivateAlarm() {
        isAlarmActive = false
        UserSettings.isAlarmSet = false
        smartAlarmModel.deactivateAlarm()
    }

    private func setUserSettingsForActivatedAlarm() {
        UserSettings.isAlarmSet = true
        UserSettings.settedAlarmMinutes = selectedMinute
        UserSettings.settedAlarmHours = selectedHour
    }

    // MARK: View setup

    private func setUpView() {
        setUpActivateButton()
        setUpPickers()
    }

    private func setUpActivateButton() {
        isAlarmActive = UserSettings.isAlarmSet
    }

    private func setUpPickers() {
        guard
            UserSettings.isAlarmSet,
            UserSettings.settedAlarmHours != -1,
            UserSettings.settedAlarmMinutes != -1
        else {
            return
        }

        selectedMinute = UserSettings.settedAlarmMinutes
        selectedHour = UserSettings.settedAlarmHours
    }
}

// Copyright (c) 2021 Sleepy.

import SwiftUI

struct AlarmView: View {
	@State private var selectedHour = Date().getHourInt()
	@State private var selectedMinute = Date().getMinuteInt()
	@State private var isAlarmActive = false
	private let smartAlarmModel = SmartAlarmModel()
	private let healthManager = HealthManager()
	private let hours = [Int](0 ... 23)
	private let minutes = [Int](0 ... 59)

	var body: some View {
		VStack {
			HStack {
				Picker("Hours".localized, selection: $selectedHour) {
					ForEach(hours, id: \.self) {
						Text(integerToString($0))
					}
				}

				Picker("Minutes".localized, selection: $selectedMinute) {
					ForEach(minutes, id: \.self) {
						Text(integerToString($0))
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
		let alarmEnd = Date().nextTimeMatchingComponents(components: DateComponents(hour: self.selectedHour, minute: self.selectedMinute))
		if self.smartAlarmModel.activateAlarm(alarmEnd: alarmEnd) {
			self.setUserSettingsForActivatedAlarm()
			self.isAlarmActive = true
		}
	}

	private func deactivateAlarm() {
		self.isAlarmActive = false
		UserSettings.isAlarmSet = false
		self.smartAlarmModel.deactivateAlarm()
	}

	private func setUserSettingsForActivatedAlarm() {
		UserSettings.isAlarmSet = true
		UserSettings.settedAlarmMinutes = self.selectedMinute
		UserSettings.settedAlarmHours = self.selectedHour
	}

	// MARK: View setup

	private func setUpView() {
		self.setUpActivateButton()
		self.setUpPickers()
	}

	private func setUpActivateButton() {
		self.isAlarmActive = UserSettings.isAlarmSet
	}

	private func setUpPickers() {
		guard
			UserSettings.isAlarmSet,
			UserSettings.settedAlarmHours != -1,
			UserSettings.settedAlarmMinutes != -1 else
		{
			return
		}

		self.selectedMinute = UserSettings.settedAlarmMinutes
		self.selectedHour = UserSettings.settedAlarmHours
	}

	// MARK: Private methods

	private func integerToString(_ integer: Int) -> String {
		let minutesStr = integer > 9 ? String(integer) : "0" + String(integer)
		return minutesStr
	}
}

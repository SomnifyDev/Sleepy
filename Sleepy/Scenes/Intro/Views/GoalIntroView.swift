// Copyright (c) 2021 Sleepy.

import FirebaseAnalytics
import SettingsKit
import SwiftUI
import UIComponents

struct GoalIntroView: View {
	@Binding var shouldShowIntro: Bool

	@State private var sleepGoal: Float = 420
	@State private var shouldShownNextTab = false

	let colorScheme: SleepyColorScheme

	var body: some View {
		ZStack {
			colorScheme.getColor(of: .general(.appBackgroundColor))
				.edgesIgnoringSafeArea(.all)
			VStack {
				ScrollView(.vertical, showsIndicators: false) {
					VStack(alignment: .leading) {
						WelcomeScreenLineView(title: "Set the desired sleep goal",
						                      subTitle: "Set a sleep goal to help you with your wellness.",
						                      imageName: "sleep",
						                      color: colorScheme.getColor(of: .general(.mainSleepyColor)))
					}.padding(.top, 16)

					VStack {
						Text("\(Date.minutesToClearString(minutes: Int(sleepGoal)))")
							.font(.title)
							.foregroundColor(.primary)
							.padding([.leading, .trailing])

						Slider(value: $sleepGoal, in: 360 ... 720, step: 15)
							.padding([.leading, .trailing])
					}
					.roundedCardBackground(color: colorScheme.getColor(of: .card(.cardBackgroundColor)).opacity(0.5))
					.padding(.top, 32)

				}.padding([.leading, .trailing], 16)

				if !self.shouldShownNextTab {
					Text("Save goal")
						.customButton(color: colorScheme.getColor(of: .general(.mainSleepyColor)))
						.onTapGesture {
							self.saveSetting(with: Int(sleepGoal), forKey: SleepySettingsKeys.sleepGoal.rawValue)
							self.shouldShownNextTab = true
						}
				}

				if self.shouldShownNextTab {
					NavigationLink(destination: HowToUseIntroView(shouldShowIntro: $shouldShowIntro, colorScheme: self.colorScheme), isActive: $shouldShownNextTab) {
						Text("Continue")
							.customButton(color: colorScheme.getColor(of: .general(.mainSleepyColor)))
					}
				}
			}
		}
		.navigationTitle("Sleep goal")
		.onAppear(perform: self.sendAnalytics)
	}

	private func saveSetting(with value: Int, forKey key: String) {
		FirebaseAnalytics.Analytics.logEvent("Settings_saved", parameters: [
			"key": key,
			"value": value,
		])
		UserDefaults.standard.set(value, forKey: key)
	}

	private func sendAnalytics() {
		FirebaseAnalytics.Analytics.logEvent("GoalIntroView_viewed", parameters: nil)
	}
}

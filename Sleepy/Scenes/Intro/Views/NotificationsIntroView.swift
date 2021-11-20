// Copyright (c) 2021 Sleepy.

import FirebaseAnalytics
import HKVisualKit
import SwiftUI

struct NotificationsIntroView: View {
	@Binding var shouldShowIntro: Bool
	@State private var shouldShowNextTab = false

	let colorScheme: SleepyColorScheme

	var body: some View {
		ZStack {
			colorScheme.getColor(of: .general(.appBackgroundColor))
				.edgesIgnoringSafeArea(.all)
			VStack {
				ScrollView(.vertical, showsIndicators: false) {
					VStack(alignment: .leading) {
						WelcomeScreenLineView(title: "Allow Sleepy to send notifications",
						                      subTitle: "This is so Sleepy can send you a summary of your past sleep.",
						                      imageName: "sleep",
						                      color: colorScheme.getColor(of: .general(.mainSleepyColor)))
					}.padding(.top, 16)
				}.padding([.leading, .trailing], 16)

				if !shouldShowNextTab {
					Text("Grant access")
						.customButton(color: colorScheme.getColor(of: .general(.mainSleepyColor)))
						.onTapGesture {
							self.registerForPushNotifications { _, _ in
								shouldShowNextTab = true
							}
						}
				}

				if shouldShowNextTab {
					NavigationLink(destination: GoalIntroView(shouldShowIntro: $shouldShowIntro, colorScheme: self.colorScheme), isActive: $shouldShowNextTab) {
						Text("Continue")
							.customButton(color: colorScheme.getColor(of: .general(.mainSleepyColor)))
					}
				}
			}
		}
		.navigationTitle("Notifications")
		.onAppear(perform: self.sendAnalytics)
	}

	private func registerForPushNotifications(completionHandler: @escaping (Bool, Error?) -> Void) {
		let options: UNAuthorizationOptions = [.alert, .sound, .badge]

		UNUserNotificationCenter.current().requestAuthorization(options: options, completionHandler: completionHandler)
	}

	private func sendAnalytics() {
		FirebaseAnalytics.Analytics.logEvent("NotificationsIntroView_viewed", parameters: nil)
	}
}

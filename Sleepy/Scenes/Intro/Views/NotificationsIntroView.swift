// Copyright (c) 2021 Sleepy.

import FirebaseAnalytics
import SwiftUI
import UIComponents

struct NotificationsIntroView: View {
	@Binding var shouldShowIntro: Bool
	@State private var shouldShowNextTab = false

	var body: some View {
		ZStack {
			ColorsRepository.General.appBackground
				.edgesIgnoringSafeArea(.all)
			VStack {
				ScrollView(.vertical, showsIndicators: false) {
					VStack(alignment: .leading) {
						WelcomeScreenLineView(title: "Allow Sleepy to send notifications",
						                      subTitle: "This is so Sleepy can send you a summary of your past sleep.",
						                      imageName: "bubble.left",
                                              color: ColorsRepository.General.mainSleepy)
					}.padding(.top, 16)
				}.padding([.leading, .trailing], 16)

				if !shouldShowNextTab {
					Text("Grant access")
						.customButton(color: ColorsRepository.General.mainSleepy)
						.onTapGesture {
							self.registerForPushNotifications { _, _ in
								shouldShowNextTab = true
							}
						}
				}

				if shouldShowNextTab {
					NavigationLink(destination: GoalIntroView(shouldShowIntro: $shouldShowIntro),
                                   isActive: $shouldShowNextTab) {
						Text("Continue")
							.customButton(color: ColorsRepository.General.mainSleepy)
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

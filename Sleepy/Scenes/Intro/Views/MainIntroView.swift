// Copyright (c) 2021 Sleepy.

import FirebaseAnalytics
import HKVisualKit
import SwiftUI

struct MainIntroView: View {
	let colorScheme: SleepyColorScheme
	@Binding var shouldShowIntro: Bool

	var body: some View {
		NavigationView {
			ZStack {
				colorScheme.getColor(of: .general(.appBackgroundColor))
					.edgesIgnoringSafeArea(.all)
				VStack {
					ScrollView(.vertical, showsIndicators: false) {
						VStack(alignment: .center) {
							VStack(alignment: .leading) {
								WelcomeScreenLineView(title: "Sleep summary",
								                      subTitle: "Sleepy analyzes sleep by collecting your data and provides an overall summary of your sleep.",
								                      imageName: "bed.double",
								                      color: colorScheme.getColor(of: .general(.mainSleepyColor)))

								WelcomeScreenLineView(title: "Smart alarm",
								                      subTitle: "Thanks to algorithms that monitor sleep phases, Sleepy will find the most optimal moment for your awakening.",
								                      imageName: "alarm",
								                      color: Color(.systemOrange))

								WelcomeScreenLineView(title: "Sounds of sleep analysis",
								                      subTitle: "Sleepy allows you to record ambient sounds during sleep and analyzes them using machine learning.",
								                      imageName: "waveform",
								                      color: Color(.systemRed))
							}.padding(.top, 16)
						}.padding([.leading, .trailing], 16)
					}

					NavigationLink(
						destination: HealthKitIntroView(colorScheme: self.colorScheme, shouldShowIntro: $shouldShowIntro)) {
							Text("Continue")
								.customButton(color: colorScheme.getColor(of: .general(.mainSleepyColor)))
					}
				}
			}
			.navigationTitle("Features")
			.onAppear(perform: self.sendAnalytics)
		}
	}

	private func sendAnalytics() {
		FirebaseAnalytics.Analytics.logEvent("MainIntroView_viewed", parameters: nil)
	}
}

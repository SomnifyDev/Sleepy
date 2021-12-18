// Copyright (c) 2021 Sleepy.

import FirebaseAnalytics
import HKCoreSleep
import SwiftUI
import UIComponents

struct HealthKitIntroView: View {
	@Binding var shouldShowIntro: Bool
	@State private var index = 0
	@State private var shouldShowNextTab = false

	private let images = ["tutorial3", "tutorial4"]
	let colorScheme: SleepyColorScheme

	var body: some View {
		ZStack {
			colorScheme.getColor(of: .general(.appBackgroundColor))
				.edgesIgnoringSafeArea(.all)
			VStack {
				ScrollView(.vertical, showsIndicators: false) {
					VStack(alignment: .leading) {
						PagingView(index: $index.animation(), maxIndex: images.count - 1) {
							ForEach(self.images, id: \.self) { imageName in
								Image(imageName)
									.resizable()
									.aspectRatio(1.21, contentMode: .fit)
									.cornerRadius(12)
							}
						}
						.aspectRatio(1.21, contentMode: .fit)
						.clipShape(RoundedRectangle(cornerRadius: 15))

						WelcomeScreenLineView(title: "Access required",
						                      subTitle: "Health data is used for analysis.",
						                      imageName: "heart.text.square.fill",
						                      color: colorScheme.getColor(of: .general(.mainSleepyColor)))

						WelcomeScreenLineView(title: "We don't keep your data",
						                      subTitle: "It is processed locally and is not uploaded to servers.",
						                      imageName: "wifi.slash",
						                      color: colorScheme.getColor(of: .general(.mainSleepyColor)))

					}.padding(.top, 16)
				}.padding([.leading, .trailing], 16)

				if !shouldShowNextTab {
					Text("Grant access")
						.customButton(color: colorScheme.getColor(of: .general(.mainSleepyColor)))
						.onTapGesture {
							HKService.requestPermissions { result, error in
								guard error == nil, result else {
									return
								}
								shouldShowNextTab = true
							}
						}
				}

				if shouldShowNextTab {
					NavigationLink(destination: NotificationsIntroView(shouldShowIntro: $shouldShowIntro, colorScheme: self.colorScheme), isActive: $shouldShowNextTab) {
						Text("Continue")
							.customButton(color: colorScheme.getColor(of: .general(.mainSleepyColor)))
					}
				}
			}
		}
		.navigationTitle("Access to Health")
		.onAppear(perform: self.sendAnalytics)
	}

	private func sendAnalytics() {
		FirebaseAnalytics.Analytics.logEvent("HealthKitIntroView_viewed", parameters: nil)
	}
}

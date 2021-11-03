// Copyright (c) 2021 Sleepy.

import FirebaseAnalytics
import HKCoreSleep
import HKVisualKit
import SwiftUI

struct HealthKitIntroView: View {
	let colorScheme: SleepyColorScheme
	@Binding var shouldShowIntro: Bool

	private let images = ["tutorial3", "tutorial4"]
	@State private var index = 0
	@State private var shouldShowNextTab = false

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
									.scaledToFill()
							}
						}
						.aspectRatio(4 / 3, contentMode: .fit)
						.clipShape(RoundedRectangle(cornerRadius: 15))

						WelcomeScreenLineView(title: "Access required".localized,
						                      subTitle: "Health data is used for analysis.".localized,
						                      imageName: "heart.text.square.fill",
						                      color: colorScheme.getColor(of: .general(.mainSleepyColor)))

						WelcomeScreenLineView(title: "We don't keep your data".localized,
						                      subTitle: "It is processed locally and is not uploaded to servers.".localized,
						                      imageName: "wifi.slash",
						                      color: colorScheme.getColor(of: .general(.mainSleepyColor)))

					}.padding(.top, 16)
				}.padding([.leading, .trailing], 16)

				if !shouldShowNextTab {
					Text("Grant access".localized)
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
					NavigationLink(
						destination: NotificationsIntroView(colorScheme: self.colorScheme, shouldShowIntro: $shouldShowIntro), isActive: $shouldShowNextTab
					) {
						Text("Continue".localized)
							.customButton(color: colorScheme.getColor(of: .general(.mainSleepyColor)))
					}
				}
			}
		}
		.navigationTitle("Access to Health".localized)
		.onAppear(perform: self.sendAnalytics)
	}

	private func sendAnalytics() {
		FirebaseAnalytics.Analytics.logEvent("HealthKitIntroView_viewed", parameters: nil)
	}
}

// Copyright (c) 2021 Sleepy.

import FirebaseAnalytics
import HKVisualKit
import SwiftUI

struct HowToUseIntroView: View {
    let colorScheme: SleepyColorScheme
    @Binding var shouldShowIntro: Bool

    private let images = ["tutorial1", "tutorial2"]
    @State private var index = 0
    @State private var shouldShownNextTab = false

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

                        WelcomeScreenLineView(
                            title: "1. You need to enable the 'Sleep' for Apple Watch",
                            subTitle: "Thanks to this Sleepy will be able to receive sleep data and analyze it.",
                            imageName: "sleep",
                            color: colorScheme.getColor(of: .general(.mainSleepyColor))
                        )

                        WelcomeScreenLineView(
                            title: "2. Wear Apple Watch before going to bed and keep it on while you sleep",
                            subTitle: "Apple Watch sensors continuously measure your heart rate and energy waste so Sleepy can analyze it.",
                            imageName: "sleep",
                            color: colorScheme.getColor(of: .general(.mainSleepyColor))
                        )

                    }.padding(.top, 16)
                }.padding([.leading, .trailing], 16)

                if !self.shouldShownNextTab {
                    Text("Go to settings")
                        .customButton(color: colorScheme.getColor(of: .general(.mainSleepyColor)))
                        .onTapGesture {
                            self.openUrl(urlString: "x-apple-Health://SleepHealthAppPlugin.healthplugin/manageSchedule")
                            self.shouldShownNextTab = true
                        }
                }

                if self.shouldShownNextTab {
                    Text("Got it!")
                        .customButton(color: colorScheme.getColor(of: .general(.mainSleepyColor)))
                        .onTapGesture {
                            self.shouldShowIntro = false
                        }
                }
            }
        }
        .navigationTitle("How to use")
        .onAppear(perform: self.sendAnalytics)
    }

    private func openUrl(urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        }
    }

    private func sendAnalytics() {
        FirebaseAnalytics.Analytics.logEvent("HowToUseIntroView_viewed", parameters: nil)
    }
}

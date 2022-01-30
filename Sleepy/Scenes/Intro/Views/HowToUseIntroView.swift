// Copyright (c) 2021 Sleepy.

import FirebaseAnalytics
import SwiftUI
import UIComponents

struct HowToUseIntroView: View {
    @Binding var shouldShowIntro: Bool

    @State private var index = 0
    @State private var shouldShownNextTab = false

    private let images = ["tutorial1", "tutorial2"]

    var body: some View {
        ZStack {
            ColorsRepository.General.appBackground
                .edgesIgnoringSafeArea(.all)
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading) {
                        PaginationView(index: $index.animation(), maxIndex: images.count - 1) {
                            ForEach(self.images, id: \.self) { imageName in
                                Image(imageName)
                                    .resizable()
                                    .aspectRatio(1.21, contentMode: .fit)
                                    .cornerRadius(12)
                            }
                        }
                        .aspectRatio(1.21, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 15))

                        WelcomeScreenLineView(title: "1. You need to enable the 'Sleep' for Apple Watch",
                                              subTitle: "Thanks to this Sleepy will be able to receive sleep data and analyze it.",
                                              imageName: "1.circle",
                                              color: ColorsRepository.General.mainSleepy)

                        WelcomeScreenLineView(title: "2. Wear Apple Watch before going to bed and keep it on while you sleep",
                                              subTitle: "Apple Watch sensors continuously measure your heart rate and energy waste so Sleepy can analyze it.",
                                              imageName: "2.circle",
                                              color: ColorsRepository.General.mainSleepy)

                    }.padding(.top, 16)
                }.padding(.horizontal, 16)

                if !self.shouldShownNextTab {
                    Text("Go to settings")
                        .customButton(color: ColorsRepository.General.mainSleepy)
                        .onTapGesture {
                            self.openUrl(urlString: "x-apple-Health://SleepHealthAppPlugin.healthplugin/manageSchedule")
                            self.shouldShownNextTab = true
                        }
                }

                if self.shouldShownNextTab {
                    Text("Got it!")
                        .customButton(color: ColorsRepository.General.mainSleepy)
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

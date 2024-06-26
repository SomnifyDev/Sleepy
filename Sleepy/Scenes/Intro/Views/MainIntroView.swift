// Copyright (c) 2022 Sleepy.

import FirebaseAnalytics
import SwiftUI
import UIComponents

struct MainIntroView: View {
    @Binding var shouldShowIntro: Bool

    var body: some View {
        NavigationView {
            ZStack {
                ColorsRepository.General.appBackground
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .center) {
                            VStack(alignment: .leading) {
                                WelcomeScreenLineView(
                                    title: "Sleep summary",
                                    subTitle: "Sleepy analyzes sleep by collecting your data and provides an overall summary of your sleep.",
                                    imageName: "bed.double",
                                    color: ColorsRepository.General.mainSleepy
                                )

                                WelcomeScreenLineView(
                                    title: "Smart alarm",
                                    subTitle: "Thanks to algorithms that monitor sleep phases, Sleepy will find the most optimal moment for your awakening.",
                                    imageName: "alarm",
                                    color: Color(.systemOrange)
                                )

                                WelcomeScreenLineView(
                                    title: "Sounds of sleep analysis",
                                    subTitle: "Sleepy allows you to record ambient sounds during sleep and analyzes them using machine learning.",
                                    imageName: "waveform",
                                    color: Color(.systemRed)
                                )
                            }.padding(.top, 16)
                        }.padding([.leading, .trailing], 16)
                    }

                    NavigationLink(
                        destination: HealthKitIntroView(shouldShowIntro: $shouldShowIntro)) {
                            Text("Continue")
                                .customButton(color: ColorsRepository.General.mainSleepy)
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

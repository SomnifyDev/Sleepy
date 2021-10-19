//
//  HowToUseIntroView.swift
//  Sleepy
//
//  Created by Никита Казанцев on 02.10.2021.
//

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

                        WelcomeScreenLineView(title: "1. Необходимо включить функцию 'Сон' для часов.",
                                              subTitle: "Благодаря этому Sleepy сможет получать данные сна и анализировать их.",
                                              imageName: "sleep",
                                              color: colorScheme.getColor(of: .general(.mainSleepyColor)))

                        WelcomeScreenLineView(title: "2. Надевайте часы перед сном и не снимайте пока спите.",
                                              subTitle: "Датчики часов непрерывно замеряют ваш пульс и движения, чтобы Sleepy мог анализировать их.",
                                              imageName: "sleep",
                                              color: colorScheme.getColor(of: .general(.mainSleepyColor)))

                    }.padding(.top, 16)
                }.padding([.leading, .trailing], 16)

                if !self.shouldShownNextTab {
                    Text("Перейти в настройки".localized)
                        .customButton(color: colorScheme.getColor(of: .general(.mainSleepyColor)))
                        .onTapGesture {
                            self.openUrl(urlString: "x-apple-Health://SleepHealthAppPlugin.healthplugin/manageSchedule")
                            self.shouldShownNextTab = true
                        }
                }

                if self.shouldShownNextTab {
                    Text("Понял!".localized)
                        .customButton(color: colorScheme.getColor(of: .general(.mainSleepyColor)))
                        .onTapGesture {
                            self.shouldShowIntro = false
                        }
                }
            }
        }
        .navigationTitle("Как пользоваться")
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

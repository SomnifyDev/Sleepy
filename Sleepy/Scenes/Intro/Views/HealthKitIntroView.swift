//
//  FeaturesIntro.swift
//  FeaturesIntro
//
//  Created by Никита Казанцев on 25.09.2021.
//

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

                        WelcomeScreenLineView(title: "Необходим доступ.",
                                              subTitle: "Показатели здоровья используются для анализа.",
                                              imageName: "heart.text.square.fill",
                                              color: colorScheme.getColor(of: .general(.mainSleepyColor)))

                        WelcomeScreenLineView(title: "Мы не храним ваши данные.",
                                              subTitle: "Информация обрабатывается локально и не загружается на сервера.",
                                              imageName: "wifi.slash",
                                              color: colorScheme.getColor(of: .general(.mainSleepyColor)))

                    }.padding(.top, 16)
                }.padding([.leading, .trailing], 16)

                if !shouldShowNextTab {
                    Text("Разрешить".localized)
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
                        Text("Продолжить")
                            .customButton(color: colorScheme.getColor(of: .general(.mainSleepyColor)))
                    }
                }
            }
        }
        .navigationTitle("Доступ к Здоровье")
        .onAppear(perform: self.sendAnalytics)
    }

    private func sendAnalytics() {
        FirebaseAnalytics.Analytics.logEvent("HealthKitIntroView_viewed", parameters: nil)
    }
}

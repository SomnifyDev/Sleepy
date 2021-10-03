//
//  MainIntroView.swift
//  MainIntroView
//
//  Created by Никита Казанцев on 25.09.2021.
//

import SwiftUI
import HKVisualKit
import FirebaseAnalytics

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
                                WelcomeScreenLineView(title: "Сводка сна",
                                                      subTitle: "Sleepy анализирует сон, агрегируя ваши данные, и предоставляет общую сводку по нему.",
                                                      imageName: "bed.double",
                                                      color: colorScheme.getColor(of: .general(.mainSleepyColor)))

                                WelcomeScreenLineView(title: "Умный будильник",
                                                      subTitle: "Благодаря алгоритмам, анализирующим фазы сна, Sleepy найдёт наиболее благоприятный момент для вашего пробуждения.",
                                                      imageName: "alarm",
                                                      color: Color(.systemOrange))

                                WelcomeScreenLineView(title: "Анализ звуков сна",
                                                      subTitle: "Sleepy позволяет записывать окружающие звуки в течение сна и анализирует их с помощью машинного обучения.",
                                                      imageName: "waveform",
                                                      color: Color(.systemRed))
                            }.padding(.top, 16)
                        }.padding([.leading, .trailing], 16)

                    }

                    NavigationLink(
                        destination: HealthKitIntroView(colorScheme: self.colorScheme, shouldShowIntro: $shouldShowIntro)) {
                            Text("Продолжить")
                                .customButton(color: colorScheme.getColor(of: .general(.mainSleepyColor)))
                        }
                }
            }
            .navigationTitle("Что умеет Sleepy")
            .onAppear(perform: self.sendAnalytics)
        }
    }

    private func sendAnalytics() {
        FirebaseAnalytics.Analytics.logEvent("MainIntroView_viewed", parameters: nil)
    }
}

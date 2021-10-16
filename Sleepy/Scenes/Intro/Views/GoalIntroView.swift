//
//  GoalIntroView.swift
//  Sleepy
//
//  Created by Никита Казанцев on 26.09.2021.
//

import SwiftUI
import HKVisualKit
import FirebaseAnalytics
import SettingsKit

struct GoalIntroView: View {
    let colorScheme: SleepyColorScheme
    @Binding var shouldShowIntro: Bool

    @State private var sleepGoal: Float = 420
    @State private var showShownNext = false

    var body: some View {
        ZStack {
            colorScheme.getColor(of: .general(.appBackgroundColor))
                .edgesIgnoringSafeArea(.all)
            VStack {
                ScrollView(.vertical, showsIndicators: false) {

                    VStack(alignment: .leading) {

                        WelcomeScreenLineView(title: "Задайте желаемую цель сна.",
                                              subTitle: "Установите цель сна, чтобы приложение помогло вам с оздоровлением.",
                                              imageName: "sleep",
                                              color: colorScheme.getColor(of: .general(.mainSleepyColor)))          
                    }.padding(.top, 16)

                    VStack {
                        Text("\(Date.minutesToClearString(minutes: Int(sleepGoal)))")
                            .font(.title)
                            .foregroundColor(.primary)
                            .padding([.leading, .trailing])

                        Slider(value: $sleepGoal, in: 360...720, step: 30)
                            .padding([.leading, .trailing])
                    }
                    .roundedCardBackground(color: colorScheme.getColor(of: .card(.cardBackgroundColor)).opacity(0.5))
                    .padding(.top, 32)

                }.padding([.leading, .trailing], 16)

                if !self.showShownNext {
                    Text("Сохранить цель".localized)
                        .customButton(color: colorScheme.getColor(of: .general(.mainSleepyColor)))
                        .onTapGesture {
                            self.saveSetting(with: Int(sleepGoal), forKey: SleepySettingsKeys.sleepGoal.rawValue)
                            self.showShownNext = true

                        }
                }

                if self.showShownNext {
                    NavigationLink(
                        destination: HowToUseIntroView(colorScheme: self.colorScheme, shouldShowIntro: $shouldShowIntro), isActive: $showShownNext) {
                            Text("Продолжить")
                                .customButton(color: colorScheme.getColor(of: .general(.mainSleepyColor)))
                        }
                }
            }
        }
        .navigationTitle("Цель сна")
        .onAppear(perform: self.sendAnalytics)
    }

    private func saveSetting(with value: Int, forKey key: String) {
        FirebaseAnalytics.Analytics.logEvent("Settings_saved", parameters: [
            "key": key,
            "value": value
        ])
        UserDefaults.standard.set(value, forKey: key)
    }

    private func sendAnalytics() {
        FirebaseAnalytics.Analytics.logEvent("GoalIntroView_viewed", parameters: nil)
    }
}

//
//  NotificationsIntroView.swift
//  Sleepy
//
//  Created by Никита Казанцев on 26.09.2021.
//

import SwiftUI
import HKVisualKit
import FirebaseAnalytics

struct NotificationsIntroView: View {
    let colorScheme: SleepyColorScheme
    @Binding var shouldShowIntro: Bool
    
    @State private var showShownNext = false
    
    var body: some View {
        ZStack {
            colorScheme.getColor(of: .general(.appBackgroundColor))
                .edgesIgnoringSafeArea(.all)
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    
                    VStack(alignment: .leading) {
                        
                        WelcomeScreenLineView(title: "Разрешите Sleepy присылать уведомления.",
                                              subTitle: "Это нужно для того, чтобы Sleepy мог присылать вам сводку за прошедший сон.",
                                              imageName: "sleep",
                                              color: colorScheme.getColor(of: .general(.mainSleepyColor)))
                    }.padding(.top, 16)
                }.padding([.leading, .trailing], 16)

                if !showShownNext {
                    Text("Разрешить".localized)
                        .customButton(color: colorScheme.getColor(of: .general(.mainSleepyColor)))
                        .onTapGesture {
                            self.registerForPushNotifications { result, error in
                                showShownNext = true
                            }

                        }
                }

                if showShownNext {
                    NavigationLink(
                        destination: GoalIntroView(colorScheme: self.colorScheme, shouldShowIntro: $shouldShowIntro), isActive: $showShownNext) {
                            Text("Продолжить")
                                .customButton(color: colorScheme.getColor(of: .general(.mainSleepyColor)))
                        }
                }
            }
        }
        .navigationTitle("Уведомления")
        .onAppear(perform: self.sendAnalytics)
    }

    private func registerForPushNotifications(completionHandler: @escaping (Bool, Error?) -> Void) {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]

        UNUserNotificationCenter.current().requestAuthorization(options: options, completionHandler: completionHandler)
    }

    private func sendAnalytics() {
        FirebaseAnalytics.Analytics.logEvent("NotificationsIntroView_viewed", parameters: nil)
    }
}

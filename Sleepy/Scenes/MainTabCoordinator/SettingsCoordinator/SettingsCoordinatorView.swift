//
//  SettingsCoordinatorView.swift
//  Sleepy
//
//  Created by Анас Бен Мустафа on 6/14/21.
//

import Foundation
import SwiftUI
import XUI
import SettingsKit
import HKVisualKit
import Armchair

struct SettingsCoordinatorView: View {
    
    // MARK: Stored Properties
    
    @Store var viewModel: SettingsCoordinator

    @State private var sleepGoalValue: Int = 300
    @State private var isSharePresented: Bool = false
    // MARK: Views
    
    var body: some View {
        NavigationView {
            List {
                Section(header: HFView(text: "Health", imageName: "heart.circle")) {
                    Stepper("Sleep goal – \(Date.minutesToClearString(minutes: sleepGoalValue))",
                            value: $sleepGoalValue,
                            in: 200...720,
                            step: 15) { _ in

                        UserDefaults.standard.set_setting(sleepGoalValue, forKey: .sleepGoal)
                    }
                }
                
                Section(header: HFView(text: "Feedback", imageName: "person.2")) {
                    LabeledButton(text: "Rate us",
                                  showChevron: true,
                                  action: { Armchair.rateApp() })

                    LabeledButton(text: "Share about us",
                                  showChevron: true,
                                  action: { isSharePresented = true })
                        .sheet(isPresented: $isSharePresented,
                               content: {
                            // TODO: replace with ours website
                            ActivityViewController(activityItems: [URL(string: "https://www.apple.com")!])
                        })
                }

            }
            .listStyle(.insetGrouped)
            .navigationBarTitle("Settings", displayMode: .large)
        }
        .onAppear {
            self.sleepGoalValue = UserDefaults.standard.get_integer(forKey: .sleepGoal) ?? 0
        }
    }

}

struct LabeledButton: View {
    let text: String
    let showChevron: Bool
    let action: () -> Void

    var body: some View {
        HStack {
            Button(action: {
                action()
            }) {
                HStack {
                    Text(text)

                    if showChevron {
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

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

    @State private var sleepGoalValue = 480
    @State private var bitrateValue = 12000
    @State private var recognisionConfidenceValue: Int = 30
    @State private var isSharePresented: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: HFView(text: "Health", imageName: "heart.circle")) {
                    Stepper("Sleep goal – \(Date.minutesToClearString(minutes: sleepGoalValue))",
                            value: $sleepGoalValue,
                            in: 200...720,
                            step: 15) { _ in

                        UserDefaults.standard.setInt(sleepGoalValue, forKey: .sleepGoal)
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

                Section(header: HFView(text: "Sound Recording", imageName: "mic.circle")) {
                    Stepper("Bitrate – \(bitrateValue)",
                            value: $bitrateValue,
                            in: 1000...44000,
                            step: 1000) { _ in

                        UserDefaults.standard.setInt(sleepGoalValue, forKey: .soundBitrate)
                    }

                    Stepper("Min. confidence – \(recognisionConfidenceValue)",
                            value: $recognisionConfidenceValue,
                            in: 10...100,
                            step: 10) { _ in

                        UserDefaults.standard.setInt(recognisionConfidenceValue, forKey: .soundRecognisionConfidence)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationBarTitle("Settings", displayMode: .large)
            .onAppear {
                // TODO: если значения нет, то дефолтное не сохраняется в хранилище
                // см TODO внутри get_integer
                self.sleepGoalValue = UserDefaults.standard.getInt(forKey: .sleepGoal) ?? 480
                self.bitrateValue = UserDefaults.standard.getInt(forKey: .soundBitrate) ?? 12000

                self.recognisionConfidenceValue = UserDefaults.standard.getInt(forKey: .soundRecognisionConfidence) ?? 30
            }
        }
    }
}

private struct LabeledButton: View {
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

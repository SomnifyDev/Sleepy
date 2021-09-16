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

    // MARK: Properties
    
    @Store var viewModel: SettingsCoordinator

    @State private var sleepGoalValue = 480
    @State private var bitrateValue = 12000
    @State private var recognisionConfidenceValue: Int = 30
    @State private var isSharePresented: Bool = false

    // MARK: Body
    
    var body: some View {
        NavigationView {
            List {
                Section(header: HFView(text: "Health".localized, imageName: "heart.circle")) {
                    Stepper(String(format: "Sleep goal %@".localized, Date.minutesToClearString(minutes: sleepGoalValue)),
                            value: $sleepGoalValue,
                            in: 200...720,
                            step: 15) { _ in
                        saveSleepGoal(sleepGoal: sleepGoalValue)
                    }
                }
                
                Section(header: HFView(text: "Feedback".localized, imageName: "person.2")) {
                    LabeledButton(text: "Rate us".localized,
                                  showChevron: true,
                                  action: { Armchair.rateApp() })
                    LabeledButton(text: "Share about us".localized,
                                  showChevron: true,
                                  action: { isSharePresented = true })
                        .sheet(isPresented: $isSharePresented,
                               content: {
                            // TODO: replace with ours website
                            ActivityViewController(activityItems: [URL(string: "https://www.apple.com")!])
                        })
                }

                Section(header: HFView(text: "Sound Recording".localized, imageName: "mic.circle")) {
                    Stepper(String(format: "Bitrate – %d".localized, bitrateValue),
                            value: $bitrateValue,
                            in: 1000...44000,
                            step: 1000) { _ in
                        saveSoundBitrate(bitrate: bitrateValue)
                    }

                    Stepper(String(format: "Min. confidence %d".localized, recognisionConfidenceValue),
                            value: $recognisionConfidenceValue,
                            in: 10...100,
                            step: 10) { _ in
                        saveRecognisionConfidence(confidence: recognisionConfidenceValue)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationBarTitle("Settings".localized, displayMode: .large)
            .onAppear {
                getAllValuesFromUserDefaults()
            }
        }
    }

    // MARK: Private methods

    private func saveSleepGoal(sleepGoal: Int) {
        UserDefaults.standard.set(sleepGoal, forKey: SleepySettingsKeys.sleepGoal.rawValue)
    }

    private func saveSoundBitrate(bitrate: Int) {
        UserDefaults.standard.set(bitrate, forKey: SleepySettingsKeys.soundBitrate.rawValue)
    }

    private func saveRecognisionConfidence(confidence: Int) {
        UserDefaults.standard.set(confidence, forKey: SleepySettingsKeys.soundRecognisionConfidence.rawValue)
    }

    private func getAllValuesFromUserDefaults() {
        self.sleepGoalValue = UserDefaults.standard.integer(forKey: SleepySettingsKeys.sleepGoal.rawValue)
        self.bitrateValue = UserDefaults.standard.integer(forKey: SleepySettingsKeys.soundBitrate.rawValue)
        self.recognisionConfidenceValue = UserDefaults.standard.integer(forKey: SleepySettingsKeys.soundRecognisionConfidence.rawValue)
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

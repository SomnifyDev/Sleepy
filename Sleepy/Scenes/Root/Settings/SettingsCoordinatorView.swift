//
//  SettingsCoordinatorView.swift
//  Sleepy
//
//  Created by Анас Бен Мустафа on 6/14/21.
//

import Armchair
import FirebaseAnalytics
import Foundation
import HKVisualKit
import SettingsKit
import SwiftUI
import XUI

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
                            in: 360 ... 720,
                            step: 15) { _ in
                        saveSetting(with: sleepGoalValue, forKey: SleepySettingsKeys.sleepGoal.rawValue)
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
                }.disabled(true)

                Section(header: HFView(text: "Sound Recording".localized, imageName: "mic.circle")) {
                    Stepper(String(format: "Bitrate – %d".localized, bitrateValue),
                            value: $bitrateValue,
                            in: 1000 ... 44000,
                            step: 1000) { _ in
                        saveSetting(with: bitrateValue, forKey: SleepySettingsKeys.soundBitrate.rawValue)
                    }

                    Stepper(String(format: "Min. confidence %d".localized, recognisionConfidenceValue),
                            value: $recognisionConfidenceValue,
                            in: 10 ... 95,
                            step: 5) { _ in
                        saveSetting(with: recognisionConfidenceValue, forKey: SleepySettingsKeys.soundRecognisionConfidence.rawValue)
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

    private func saveSetting(with value: Int, forKey key: String) {
        FirebaseAnalytics.Analytics.logEvent("Settings_saved", parameters: [
            "key": key,
            "value": value,
        ])
        UserDefaults.standard.set(value, forKey: key)
    }

    private func getAllValuesFromUserDefaults() {
        sleepGoalValue = UserDefaults.standard.integer(forKey: SleepySettingsKeys.sleepGoal.rawValue)
        bitrateValue = UserDefaults.standard.integer(forKey: SleepySettingsKeys.soundBitrate.rawValue)
        recognisionConfidenceValue = UserDefaults.standard.integer(forKey: SleepySettingsKeys.soundRecognisionConfidence.rawValue)
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

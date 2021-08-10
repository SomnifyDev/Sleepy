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

struct SettingsCoordinatorView: View {
    
    // MARK: Stored Properties
    
    @Store var viewModel: SettingsCoordinator

    @State private var stepperValue: Int = 300
    
    // MARK: Views
    
    var body: some View {
        NavigationView {
            List {
                Section(header: HFView(text: "Health", imageName: "heart.circle")) {
                    Stepper("Sleep goal – \(Date.minutesToDateDescription(minutes: stepperValue))",
                            value: $stepperValue,
                            in: 300...720,
                            step: 15) { _ in

                        do {
                            try viewModel.settingsProvider.setSetting(type: .sleepGoal, value: stepperValue)
                        } catch {
                            print("Error during saving sleep goal setting")
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationBarTitle("Settings", displayMode: .large)
        }
        .onAppear {
            self.stepperValue = getSleepGoal()
        }
    }

    private func getSleepGoal() -> Int {
        guard
            let sleepGoal = viewModel.settingsProvider.getSetting(type: .sleepGoal) as? Int
        else {
            assertionFailure("Invalid setting type returned")
            return 0
        }
        return sleepGoal
    }
    
}

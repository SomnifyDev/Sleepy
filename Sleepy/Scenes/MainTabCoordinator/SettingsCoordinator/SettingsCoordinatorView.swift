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
                    Stepper("Sleep goal – \(Date.minutesToClearString(minutes: stepperValue))",
                            value: $stepperValue,
                            in: 300...720,
                            step: 15) { _ in

                        UserDefaults.standard.set_setting(stepperValue, forKey: .sleepGoal)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationBarTitle("Settings", displayMode: .large)
        }
        .onAppear {
            self.stepperValue = UserDefaults.standard.get_integer(forKey: .sleepGoal) ?? 0
        }
    }

}

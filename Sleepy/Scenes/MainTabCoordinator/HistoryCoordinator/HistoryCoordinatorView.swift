//
//  HistoryCoordinatorView.swift
//  Sleepy
//
//  Created by Анас Бен Мустафа on 6/14/21.
//

import SwiftUI
import XUI
import HKVisualKit

struct HistoryCoordinatorView: View {
    
    // MARK: Stored Properties
    
    @Store var coordinator: HistoryCoordinator

    @State private var calendarType: HealthData = .sleep

    // MARK: Views
    
    var body: some View {
        NavigationView {
            HistoryListView(viewModel: coordinator, calendarType: $calendarType)
        }.navigationTitle("History")
    }
}

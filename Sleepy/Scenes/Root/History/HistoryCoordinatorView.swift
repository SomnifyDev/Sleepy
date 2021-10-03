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
    
    @Store var viewModel: HistoryCoordinator

    @State private var calendarType: HealthData = .sleep

    var body: some View {
        NavigationView {
            HistoryListView(viewModel: viewModel, calendarType: $calendarType)
        }
        .navigationTitle("History")

    }
}

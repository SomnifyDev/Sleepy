//
//  HistoryCoordinatorView.swift
//  Sleepy
//
//  Created by Анас Бен Мустафа on 6/14/21.
//

import Foundation
import SwiftUI
import XUI
import HKVisualKit

struct HistoryCoordinatorView: View {
    
    // MARK: Stored Properties
    
    @Store var coordinator: HistoryCoordinator
    @State var calendarType: HealthData = .sleep
    
    // MARK: Views
    
    var body: some View {
        CalendarView(colorSchemeProvider: coordinator.colorSchemeProvider,
                     statsProvider: coordinator.statisticsProvider, calendarType: $calendarType)
    }
    
}

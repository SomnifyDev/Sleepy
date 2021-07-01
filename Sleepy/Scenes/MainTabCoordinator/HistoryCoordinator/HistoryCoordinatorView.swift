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
        ScrollView(.vertical, showsIndicators: false) {
            GeometryReader { geometry in
                VStack(alignment: .center) {
                    CalendarView(calendarType: $calendarType,
                                 colorSchemeProvider: coordinator.colorSchemeProvider,
                                 statsProvider: coordinator.statisticsProvider)
                        .roundedCardBackground(color: coordinator.colorSchemeProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
                }
            }
        }.background(coordinator.colorSchemeProvider.sleepyColorScheme.getColor(of: .general(.appBackgroundColor)).edgesIgnoringSafeArea(.all))

    }
    
}

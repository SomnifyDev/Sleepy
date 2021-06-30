//
//  CalendarView.swift
//  Sleepy
//
//  Created by Никита Казанцев on 30.06.2021.
//

import SwiftUI
import HKVisualKit
import HKStatistics

struct CalendarView: View {

    @State var currentDate = Date()
    @State var calendarType: HealthData = HealthData.sleep

    private let colorSchemeProvider: ColorSchemeProvider
    private let statsProvider: HKStatisticsProvider

    private var grid = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()),
                        GridItem(.flexible()), GridItem(.flexible()),
                        GridItem(.flexible()), GridItem(.flexible())]

    init(colorSchemeProvider: ColorSchemeProvider, statsProvider: HKStatisticsProvider) {
        self.colorSchemeProvider = colorSchemeProvider
        self.statsProvider = statsProvider
    }

    var body: some View {
        GeometryReader { geometry in
            LazyVGrid(columns: grid) {
                    ForEach((0...currentDate.getDaysInMonth()), id: \.self) { index in
                        CalendarDayView(colorScheme: colorSchemeProvider.sleepyColorScheme,
                                        type: calendarType,
                                        date: Calendar.current.date(byAdding: .day, value: index, to: currentDate) ?? Date(),
                                        statsProvider: statsProvider)
                            .frame(height: geometry.size.width / 8)
                    }
            }
        }
    }
}

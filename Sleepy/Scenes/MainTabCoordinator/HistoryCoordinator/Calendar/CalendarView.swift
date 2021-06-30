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
    @Binding var calendarType: HealthData

    private let colorSchemeProvider: ColorSchemeProvider
    private let statsProvider: HKStatisticsProvider

    let healthTypeGridLayout = Array(repeating: GridItem(.adaptive(minimum: 50)), count: 4)
    private var calendarGridLayout = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()),
                                      GridItem(.flexible()), GridItem(.flexible()),
                                      GridItem(.flexible()), GridItem(.flexible())]

    init(colorSchemeProvider: ColorSchemeProvider, statsProvider: HKStatisticsProvider, calendarType: Binding<HealthData>) {
        self.colorSchemeProvider = colorSchemeProvider
        self.statsProvider = statsProvider
        _calendarType = calendarType
    }

    var body: some View {
        GeometryReader { geometry in

            VStack {

                TagCloudView(selectedType: $calendarType, colorScheme: colorSchemeProvider.sleepyColorScheme)

                LazyVGrid(columns: calendarGridLayout) {
                    ForEach((0...currentDate.getDaysInMonth()), id: \.self) { index in
                        CalendarDayView(colorScheme: colorSchemeProvider.sleepyColorScheme,
                                        type: $calendarType,
                                        statsProvider: statsProvider, date: Calendar.current.date(byAdding: .day, value: index - currentDate.getDayInt(), to: currentDate) ?? Date())
                            .frame(height: geometry.size.width / 8)
                    }
                }
            }
        }
    }
}

struct ExtractedView: View {

    var type: HealthData
    var description: String
    var colorScheme: SleepyColorScheme

    @Binding var selectedType: HealthData

    var body: some View {
        HStack {
            Text(description)
                .lineLimit(1)
                .padding(.top, 6)
                .padding(.bottom, 6)
                .padding(.leading)
                .padding(.trailing)
                .foregroundColor(type == selectedType  ? .white : .black)
                .background(type == selectedType
                            ? ( type == .sleep
                                ? colorScheme.getColor(of: .general(.mainSleepyColor))
                                : colorScheme.getColor(of: .heart(.heartColor)))
                            : colorScheme.getColor(of: .calendar(.emptyDayColor)))
                .cornerRadius(12)
                .onTapGesture {
                    selectedType = type
            }
        }
    }
}

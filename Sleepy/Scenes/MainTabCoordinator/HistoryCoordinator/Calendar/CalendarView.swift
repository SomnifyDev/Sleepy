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

    let colorSchemeProvider: ColorSchemeProvider
    let statsProvider: HKStatisticsProvider

    private let calendarGridLayout = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        GeometryReader { geometry in

            VStack {

                // заголовок с названием месяца
                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 24))

                    Text("\(currentDate.getMonthString()) \(currentDate.getYearString())")
                        .font(.system(size: 24))
                        .fontWeight(.bold)

                    Spacer()

                }.frame(height: 30, alignment: .top)

                HealthTypeSwitchView(selectedType: $calendarType, colorScheme: colorSchemeProvider.sleepyColorScheme)

                LazyVGrid(columns: calendarGridLayout) {
                    ForEach(1...currentDate.getDaysInMonth(), id: \.self) { index in
                        VStack {
                            CalendarDayView(type: $calendarType,
                                            currentDate: $currentDate,
                                            colorScheme: colorSchemeProvider.sleepyColorScheme,
                                            statsProvider: statsProvider,
                                            dateIndex: index)
                                .frame(height: geometry.size.width / 8)

                            Text(String(index))
                                .font(.system(size: 7))
                                .opacity(0.5)
                        }
                    }
                }
                // обработка свайпов для переключения месяца
                .gesture(DragGesture(minimumDistance: 20, coordinateSpace: .global)
                            .onEnded { value in
                    let horizontalAmount = value.translation.width as CGFloat
                    let verticalAmount = value.translation.height as CGFloat

                    if abs(horizontalAmount) > abs(verticalAmount) {
                        if horizontalAmount < 0 {
                            // свайп слева направо
                            print("увеличиваем")
                            print(currentDate.getMonthString())
                            currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate)!
                            print(currentDate.getMonthString())
                        } else {
                            // свайп справа налево
                            print("уменьшаем \n \n \n")
                            print(currentDate.getMonthString())
                            currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate)!
                            print(currentDate.getMonthString())
                        }

                    }

                })
            }
        }
    }
}

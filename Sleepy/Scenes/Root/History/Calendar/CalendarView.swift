import SwiftUI
import HKVisualKit
import HKStatistics

struct CalendarView: View {

    @State private var totalHeight = CGFloat.zero // variant for ScrollView/List
    // = CGFloat.infinity - variant for VStack

    @State private var monthDate = Date()
    @Binding var calendarType: HealthData

    private let calendarGridLayout = Array(repeating: GridItem(.flexible()), count: 7)
    private let colorSchemeProvider: ColorSchemeProvider
    private let statsProvider: HKStatisticsProvider

    init(calendarType: Binding<HealthData>, colorSchemeProvider: ColorSchemeProvider, statsProvider: HKStatisticsProvider) {
        self._calendarType = calendarType
        self.colorSchemeProvider = colorSchemeProvider
        self.statsProvider = statsProvider
    }

    var body: some View {
        VStack {
            GeometryReader { geometry in
                let calendarElementSize = geometry.size.width / 8

                VStack {
                    CalendarTitleView(calendarType: $calendarType,
                                      monthDate: $monthDate,
                                      colorSchemeProvider: colorSchemeProvider)

                    HealthTypeSwitchView(selectedType: $calendarType,
                                         colorScheme: colorSchemeProvider.sleepyColorScheme)

                    LazyVGrid(columns: calendarGridLayout, spacing: 4) {
                        ForEach(1...monthDate.getDaysInMonth(), id: \.self) { index in
                            VStack(spacing: 2) {
                                if index >= 1 && index <= 7 {
                                    let tmpWeekDay = Calendar.current.date(byAdding: .day,
                                                                           value: index - 1,
                                                                           to: monthDate.startOfMonth)!

                                    Text(tmpWeekDay.weekday() ?? "")
                                        .weekDayTextModifier(width: calendarElementSize)
                                }

                                CalendarDayView(type: $calendarType,
                                                monthDate: $monthDate,
                                                colorScheme: colorSchemeProvider.sleepyColorScheme,
                                                statsProvider: statsProvider,
                                                currentDate: Date(),
                                                dateIndex: index)
                                    .frame(height: calendarElementSize)

                                Text(String(index))
                                    .dayNumberTextModifier()
                            }
                        }
                    }
                    .gesture(DragGesture(minimumDistance: 20, coordinateSpace: .global)
                                .onEnded { value in
                        let horizontalAmount = value.translation.width as CGFloat
                        let verticalAmount = value.translation.height as CGFloat

                        if abs(horizontalAmount) > abs(verticalAmount) {
                            monthDate = Calendar.current.date(byAdding: .month,
                                                              value: horizontalAmount < 0 ? 1 : -1,
                                                              to: monthDate)!
                        }
                    })
                }.background(viewHeightReader($totalHeight))
            }
        }.frame(height: totalHeight) // - variant for ScrollView/List
        //.frame(maxHeight: totalHeight) - variant for VStack
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}

private struct CalendarTitleView: View {

    @Binding var calendarType: HealthData
    @Binding var monthDate: Date

    let colorSchemeProvider: ColorSchemeProvider

    var body: some View {
        HStack {
            Text(Image(systemName: "calendar"))
                .regularTextModifier(color: getSelectedCalendarColor(for: calendarType), size: 24)

            Text("\(monthDate.getMonthString()) \(monthDate.getYearString())")
                .calendarMonthTitleModifier(color: getSelectedCalendarColor(for: calendarType))

            Spacer()

            Button(action: {
                monthDate = Calendar.current.date(byAdding: .month,
                                                  value: -1,
                                                  to: monthDate)!
            }) {
                Text(Image(systemName: "chevron.left"))
                    .boldTextModifier(color: getSelectedCalendarColor(for: calendarType))
            }
            .padding(.trailing, 8)

            Button(action: {
                monthDate = Calendar.current.date(byAdding: .month,
                                                  value: 1,
                                                  to: monthDate)!
            }) {
                Text(Image(systemName: "chevron.right"))
                    .boldTextModifier(color: getSelectedCalendarColor(for: calendarType))
            }

        }.frame(height: 30, alignment: .top)
    }

    private func getSelectedCalendarColor(for type: HealthData) -> Color {
        switch type {
        case .heart:
            return colorSchemeProvider.sleepyColorScheme.getColor(of: .heart(.heartColor))
        case .energy:
            return colorSchemeProvider.sleepyColorScheme.getColor(of: .energy(.energyColor))
        case .sleep:
            return colorSchemeProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor))
        case .inbed:
            return colorSchemeProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor))
        }
    }
    
}

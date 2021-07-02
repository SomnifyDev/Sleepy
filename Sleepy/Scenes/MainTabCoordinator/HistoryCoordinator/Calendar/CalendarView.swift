import SwiftUI
import HKVisualKit
import HKStatistics

struct CalendarView: View {

    @State private var totalHeight = CGFloat.zero // variant for ScrollView/List
    // = CGFloat.infinity - variant for VStack
    
    @State var monthDate = Date()
    @Binding var calendarType: HealthData

    let colorSchemeProvider: ColorSchemeProvider
    let statsProvider: HKStatisticsProvider

    private let calendarGridLayout = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        VStack {
            GeometryReader { geometry in
                let calendarElementSize = geometry.size.width / 8

                VStack {
                    TitleView(calendarType: $calendarType,
                              monthDate: $monthDate,
                              colorSchemeProvider: colorSchemeProvider)

                    HealthTypeSwitchView(selectedType: $calendarType,
                                         colorScheme: colorSchemeProvider.sleepyColorScheme)


                    LazyVGrid(columns: calendarGridLayout, spacing: 4) {
                        ForEach(1...monthDate.getDaysInMonth(), id: \.self) { index in
                            VStack(spacing: 2) {
                                if (index >= 1 && index <= 7) {
                                    let tmpWeekDay = Calendar.current.date(byAdding: .day,
                                                                           value: index - 1,
                                                                           to: monthDate.startOfMonth)!

                                    Text(tmpWeekDay.weekday() ?? "")
                                        .font(.system(size: 8))
                                        .fontWeight(.semibold)
                                        .opacity(0.3)
                                        .frame(width: calendarElementSize)
                                }

                                CalendarDayView(type: $calendarType,
                                                monthDate: $monthDate,
                                                colorScheme: colorSchemeProvider.sleepyColorScheme,
                                                statsProvider: statsProvider,
                                                currentDate: Date(),
                                                dateIndex: index)
                                    .frame(height: calendarElementSize)

                                Text(String(index))
                                    .font(.system(size: 8))
                                    .fontWeight(.semibold)
                                    .opacity(0.3)
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

private struct TitleView: View {

    @Binding var calendarType: HealthData
    @Binding var monthDate: Date

    let colorSchemeProvider: ColorSchemeProvider

    var body: some View {
        HStack {
            Image(systemName: "calendar")
                .font(.system(size: 24))
                .foregroundColor(getSelectedCalendarColor(for: calendarType))

            Text("\(monthDate.getMonthString()) \(monthDate.getYearString())")
                .foregroundColor(getSelectedCalendarColor(for: calendarType))
                .font(.system(size: 24))
                .fontWeight(.bold)

            Spacer()

            Button(action: {
                monthDate = Calendar.current.date(byAdding: .month,
                                                  value: -1,
                                                  to: monthDate)!
            }) {
                Text(Image(systemName: "chevron.left"))
                    .foregroundColor(getSelectedCalendarColor(for: calendarType))
                    .fontWeight(.bold)
            }
            .padding(.trailing, 8)

            Button(action: {
                monthDate = Calendar.current.date(byAdding: .month,
                                                  value: 1,
                                                  to: monthDate)!
            }) {
                Text(Image(systemName: "chevron.right"))
                    .foregroundColor(getSelectedCalendarColor(for: calendarType))
                    .fontWeight(.bold)
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

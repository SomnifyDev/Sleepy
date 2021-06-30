import SwiftUI
import HKVisualKit
import HealthKit
import HKStatistics

struct CalendarDayView: View {

    @Binding var type: HealthData
    @Binding var currentDate: Date
    @State private var description = ""
    @State private var value: Double = 0
    @State private var circleColor: Color?

    let colorScheme: SleepyColorScheme
    let statsProvider: HKStatisticsProvider
    let dateIndex: Int

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    //.strokeBorder(currentDate == date ? .yellow : .clear ,lineWidth: 2)
                    .foregroundColor(circleColor ?? colorScheme.getColor(of: .calendar(.emptyDayColor)))

                Text(description)
                    .colorInvert()
                    .font(.system(size: geometry.size.height > geometry.size.width
                                  ? geometry.size.width * 0.3
                                  : geometry.size.height * 0.3))
                    .lineLimit(1)
                    .onAppear(perform: getData)
                    .onChange(of: type) { _ in
                        getData()
                    }
                    .onChange(of: currentDate) { _ in
                        getData()
                    }
            }
        }
    }

    private func getCircleColor() {
        if value.isNaN {
            circleColor = colorScheme.getColor(of: .calendar(.emptyDayColor))
            return
        }

        switch type {

        case .heart:
            circleColor = colorScheme.getColor(of: .heart(.heartColor))

        case .sleep, .inbed:
            circleColor = value > 480
            ? colorScheme.getColor(of: .calendar(.positiveDayColor))
            : (value > 360
               ? colorScheme.getColor(of: .calendar(.neutralDayColor))
               : colorScheme.getColor(of: .calendar(.negativeDayColor)))

        case .energy:
            circleColor = colorScheme.getColor(of: .energy(.energyColor))

        }
    }

    private func getData() {
        let date = Calendar.current.date(byAdding: .day, value: dateIndex - currentDate.getDayInt(), to: currentDate) ?? Date()
        print("GETTING DATA FOR \(date.getMonthString())")

        description = ""
        switch type {
        case .heart:
            statsProvider.getDataByIntervalWithIndicator(healthType: .heart, indicatorType: .mean, for: DateInterval(start: date.startOfDay, end: date.endOfDay)) { val in
                value = val
                getCircleColor()

                description = !val.isNaN ? String(Int(val)) : "-"
            }

        case .energy:
            statsProvider.getDataByIntervalWithIndicator(healthType: .energy, indicatorType: .mean, for: DateInterval(start: date.startOfDay, end: date.endOfDay)) { val in
                value = val
                getCircleColor()

                description = !val.isNaN ? String(format: "%.2f", value) : "-"
            }

        case .sleep:
            statsProvider.getDataByIntervalWithIndicator(healthType: .asleep, indicatorType: .mean, for: DateInterval(start: date.startOfDay, end: date.endOfDay)) { val in
                value = val
                getCircleColor()

                description = !value.isNaN ? Date.minutesToDateDescription(minutes: Int(value)) : "-"
            }
            
        case .inbed:
            statsProvider.getDataByIntervalWithIndicator(healthType: .inbed, indicatorType: .mean, for: DateInterval(start: date.startOfDay, end: date.endOfDay)) { val in
                value = val
                getCircleColor()

                description = !value.isNaN ? Date.minutesToDateDescription(minutes: Int(value)) : "-"
            }

        }
    }

}

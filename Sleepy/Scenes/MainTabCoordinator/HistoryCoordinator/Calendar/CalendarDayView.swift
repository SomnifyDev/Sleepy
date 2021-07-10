import SwiftUI
import HKVisualKit
import HealthKit
import HKStatistics

struct CalendarDayView: View {

    @Binding var type: HealthData
    @Binding var monthDate: Date
    
    @State private var description = ""
    @State private var value: Double?
    @State private var circleColor: Color?

    let colorScheme: SleepyColorScheme
    let statsProvider: HKStatisticsProvider
    let currentDate: Date
    let dateIndex: Int

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .foregroundColor(circleColor ?? colorScheme.getColor(of: .calendar(.emptyDayColor)))

                if currentDate.getMonthInt() == monthDate.getMonthInt() &&
                    currentDate.getDayInt() == dateIndex {
                    Circle()
                        .strokeBorder(colorScheme.getColor(of: .calendar(.calendarCurrentDateColor)), lineWidth: 3)
                }

                Text(description)
                    .dayCircleInfoTextModifier(geometry: geometry)
                    .onAppear(perform: getData)
                    .onChange(of: type) { _ in
                        getData()
                    }
                    .onChange(of: monthDate) { _ in
                        getData()
                    }
            }
        }
    }

    private func getCircleColor() {
        if let value = value {
            switch type {
            case .heart:
                circleColor = colorScheme.getColor(of: .heart(.heartColor))

            case .sleep, .inbed:
                // TODO: remove constants and use users desired sleep duration value instead
                circleColor = value > 480
                ? colorScheme.getColor(of: .calendar(.positiveDayColor))
                : (value > 360
                   ? colorScheme.getColor(of: .calendar(.neutralDayColor))
                   : colorScheme.getColor(of: .calendar(.negativeDayColor)))

            case .energy:
                circleColor = colorScheme.getColor(of: .energy(.energyColor))

            }
        } else {
            circleColor = colorScheme.getColor(of: .calendar(.emptyDayColor))
            return
        }
    }

    private func getData() {
        let date = Calendar.current.date(byAdding: .day, value: dateIndex - monthDate.getDayInt(), to: monthDate) ?? Date()
        description = ""

        switch type {
        case .heart:
            statsProvider.getDataByIntervalWithIndicator(healthType: .heart, indicatorType: .mean, for: DateInterval(start: date.startOfDay, end: date.endOfDay)) { val in
                value = val
                getCircleColor()

                if let value = value {
                    description = !value.isNaN ? String(Int(value)) : "-"
                } else {
                    description = "-"
                }
            }

        case .energy:
            statsProvider.getDataByIntervalWithIndicator(healthType: .energy, indicatorType: .mean, for: DateInterval(start: date.startOfDay, end: date.endOfDay)) { val in
                value = val
                getCircleColor()

                if let value = value {
                    description = !value.isNaN ? String(format: "%.2f", value) : "-"
                } else {
                    description = "-"
                }
            }

        case .sleep:
            statsProvider.getDataByIntervalWithIndicator(healthType: .asleep, indicatorType: .mean, for: DateInterval(start: date.startOfDay, end: date.endOfDay), bundlePrefix: "com.sinapsis") { val in
                value = val
                getCircleColor()

                if let value = value {
                    description = !value.isNaN ? Date.minutesToDateDescription(minutes: Int(value)) : "-"
                } else {
                    description = "-"
                }
            }
            
        case .inbed:
            statsProvider.getDataByIntervalWithIndicator(healthType: .inbed, indicatorType: .mean, for: DateInterval(start: date.startOfDay, end: date.endOfDay), bundlePrefix: "com.sinapsis") { val in
                value = val
                getCircleColor()

                if let value = value {
                    description = !value.isNaN ? Date.minutesToDateDescription(minutes: Int(value)) : "-"
                } else {
                    description = "-"
                }
            }
        }
    }

}

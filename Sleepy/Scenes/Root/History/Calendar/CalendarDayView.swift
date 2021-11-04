import HealthKit
import HKStatistics
import HKVisualKit
import SwiftUI
import SettingsKit

struct CalendarDayView: View {
    @Binding var type: HealthData
    @Binding var monthDate: Date

    @State private var description = ""
    @State private var value: Double?
    @State private var circleColor: Color?

    private let colorScheme: SleepyColorScheme
    private let statsProvider: HKStatisticsProvider
    private let currentDate: Date
    private let dateIndex: Int

    private let sleepGoal: Int

    init(type: Binding<HealthData>,
         monthDate: Binding<Date>,
         colorScheme: SleepyColorScheme,
         statsProvider: HKStatisticsProvider,
         currentDate: Date,
         dateIndex: Int) {
        _type = type
        _monthDate = monthDate
        self.colorScheme = colorScheme
        self.statsProvider = statsProvider
        self.currentDate = currentDate
        self.dateIndex = dateIndex
        self.sleepGoal = UserDefaults.standard.integer(forKey: SleepySettingsKeys.sleepGoal.rawValue)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .foregroundColor(circleColor ?? colorScheme.getColor(of: .calendar(.emptyDayColor)))

                if currentDate.getMonthInt() == monthDate.getMonthInt() &&
                    currentDate.getDayInt() == dateIndex
                {
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
                circleColor = Int(value) > sleepGoal
                    ? colorScheme.getColor(of: .calendar(.positiveDayColor))
                : (value > Double(sleepGoal) * 0.9
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
        description = "-"
        value = nil
        getCircleColor()

        switch type {
        case .heart:
            statsProvider.metaData(.heart, .mean, DateInterval(start: date.startOfDay, end: date.endOfDay)) { val in
                value = val
                getCircleColor()

                if let value = value {
                    description = !value.isNaN ? String(Int(value)) : "-"
                } else {
                    description = "-"
                }
            }

        case .energy:
            statsProvider.metaData(.energy, .mean, DateInterval(start: date.startOfDay, end: date.endOfDay)) { val in
                value = val
                getCircleColor()

                if let value = value {
                    description = !value.isNaN ? String(format: "%.2f", value) : "-"
                } else {
                    description = "-"
                }
            }

        case .sleep:
            statsProvider.data(.asleep, .sum, DateInterval(start: date.startOfDay, end: date.endOfDay), bundlePrefixes: ["com.sinapsis", "com.benmustafa"]) { val in
                value = val
                getCircleColor()

                if let value = value {
                    description = !value.isNaN ? Date.minutesToDateDescription(minutes: Int(value)) : "-"
                } else {
                    description = "-"
                }
            }

        case .inbed:
            statsProvider.data(.inbed, .sum, DateInterval(start: date.startOfDay, end: date.endOfDay), bundlePrefixes: ["com.sinapsis", "com.benmustafa"]) { val in
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

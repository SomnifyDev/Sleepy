import SwiftUI
import HKVisualKit
import HealthKit
import HKStatistics

struct CalendarDayView: View {

    @State private var description = ""

    private let colorScheme: SleepyColorScheme
    private let type: HealthData
    private let statsProvider: HKStatisticsProvider
    private let date: Date

    init(colorScheme: SleepyColorScheme, type: HealthData, date: Date,
         statsProvider: HKStatisticsProvider) {
        self.colorScheme = colorScheme
        self.type = type
        self.date = date
        self.statsProvider = statsProvider
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .foregroundColor(getCircleColor())
                Text(description)
                    .font(.system(size: geometry.size.height > geometry.size.width
                                  ? geometry.size.width * 0.4
                                  : geometry.size.height * 0.4))
                    .onAppear(perform: getDescription)
            }
        }
    }

    private func getCircleColor() -> Color {
        switch type {

        case .heart:
            return colorScheme.getColor(of: .heart(.heartColor))

        case .sleep:
            return colorScheme.getColor(of: .calendar(.neutralDayColor))

        case .inbed:
            return colorScheme.getColor(of: .calendar(.neutralDayColor))

        case .energy, .some:
            return Color(UIColor())

        }
    }

    private func getDescription() {
        switch type {
        case .heart:
            statsProvider.getDataByIntervalWithIndicator(healthType: .heart, indicatorType: .mean, for: DateInterval(start: date.startOfDay, end: date.endOfDay)) { value in
                description = String(value)
            }

        case .energy:
            assertionFailure("not made yet for calendar")

        case .sleep:
            statsProvider.getDataByIntervalWithIndicator(healthType: .asleep, indicatorType: .mean, for: DateInterval(start: date.startOfDay, end: date.endOfDay)) { value in
                description = String(value)
            }

        case .inbed:
            statsProvider.getDataByIntervalWithIndicator(healthType: .inbed, indicatorType: .mean, for: DateInterval(start: date.startOfDay, end: date.endOfDay)) { value in
                description = String(value)
            }

        case .some:
            assertionFailure("not made yet for calendar")

        }
    }

}


import SwiftUI
import HKVisualKit
import HealthKit
import HKStatistics

struct CalendarDayView: View {

    @State private var description = ""

    let colorScheme: SleepyColorScheme
    @Binding var type: HealthData
    let statsProvider: HKStatisticsProvider
    let date: Date

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .foregroundColor(getCircleColor())
                Text(description)
                    .font(.system(size: geometry.size.height > geometry.size.width
                                  ? geometry.size.width * 0.4
                                  : geometry.size.height * 0.4))
                    .lineLimit(1)
                    .onAppear(perform: getDescription)
                    .onChange(of: type) { _ in
                        getDescription()
                    }
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

        case .energy:
            return colorScheme.getColor(of: .calendar(.emptyDayColor))

        }
    }

    private func getDescription() {
        description = ""
        switch type {
        case .heart:
            statsProvider.getDataByIntervalWithIndicator(healthType: .heart, indicatorType: .mean, for: DateInterval(start: date.startOfDay, end: date.endOfDay)) { value in
                if !value.isNaN {
                    description = String(Int(value))
                }
            }

        case .energy:
            assertionFailure("not made yet for calendar")

        case .sleep:
            statsProvider.getDataByIntervalWithIndicator(healthType: .asleep, indicatorType: .mean, for: DateInterval(start: date.startOfDay, end: date.endOfDay)) { value in
                if !value.isNaN {
                    description = Date.minutesToDateDescription(minutes: Int(value))
                }
            }

        case .inbed:
            statsProvider.getDataByIntervalWithIndicator(healthType: .inbed, indicatorType: .mean, for: DateInterval(start: date.startOfDay, end: date.endOfDay)) { value in
                if !value.isNaN {
                    description = Date.minutesToDateDescription(minutes: Int(value))
                }
            }

        }
    }

}


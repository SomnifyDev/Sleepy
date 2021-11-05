// Copyright (c) 2021 Sleepy.

import HealthKit
import HKStatistics
import HKVisualKit
import SettingsKit
import SwiftUI

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
	     dateIndex: Int)
	{
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
			switch self.type {
			case .heart:
				self.circleColor = self.colorScheme.getColor(of: .heart(.heartColor))

			case .sleep, .inbed:
				// TODO: remove constants and use users desired sleep duration value instead
				self.circleColor = Int(value) > self.sleepGoal
					? self.colorScheme.getColor(of: .calendar(.positiveDayColor))
					: (value > Double(self.sleepGoal) * 0.9
						? self.colorScheme.getColor(of: .calendar(.neutralDayColor))
						: self.colorScheme.getColor(of: .calendar(.negativeDayColor)))

			case .energy:
				self.circleColor = self.colorScheme.getColor(of: .energy(.energyColor))
            case .respiratory:
                self.circleColor = Color(.systemBlue)
			}
		} else {
			self.circleColor = self.colorScheme.getColor(of: .calendar(.emptyDayColor))
			return
		}
	}

	private func getData() {
		let date = Calendar.current.date(byAdding: .day, value: self.dateIndex - self.monthDate.getDayInt(), to: self.monthDate) ?? Date()
		self.description = "-"
		self.value = nil
		self.getCircleColor()

		switch self.type {
		case .heart:
			self.statsProvider.getMetaDataByIntervalWithIndicator(healthType: .heart,
			                                                      indicatorType: .mean,
			                                                      for: DateInterval(start: date.startOfDay, end: date.endOfDay)) { val in
				value = val
				getCircleColor()

				if let value = value {
					description = !value.isNaN ? String(Int(value)) : "-"
				} else {
					description = "-"
				}
			}

		case .energy:
			self.statsProvider.getMetaDataByIntervalWithIndicator(healthType: .energy,
			                                                      indicatorType: .mean,
			                                                      for: DateInterval(start: date.startOfDay, end: date.endOfDay)) { val in
				value = val
				getCircleColor()

				if let value = value {
					description = !value.isNaN ? String(format: "%.2f", value) : "-"
				} else {
					description = "-"
				}
			}

		case .sleep:
			self.statsProvider.getDataByIntervalWithIndicator(healthType: .asleep,
			                                                  indicatorType: .sum,
			                                                  for: DateInterval(start: date.startOfDay, end: date.endOfDay),
			                                                  bundlePrefixes: ["com.sinapsis", "com.benmustafa"]) { val in
				value = val
				getCircleColor()

				if let value = value {
					description = !value.isNaN ? Date.minutesToDateDescription(minutes: Int(value)) : "-"
				} else {
					description = "-"
				}
			}

		case .inbed:
			self.statsProvider.getDataByIntervalWithIndicator(healthType: .inbed,
			                                                  indicatorType: .sum,
			                                                  for: DateInterval(start: date.startOfDay, end: date.endOfDay),
			                                                  bundlePrefixes: ["com.sinapsis", "com.benmustafa"]) { val in
				value = val
				getCircleColor()

				if let value = value {
					description = !value.isNaN ? Date.minutesToDateDescription(minutes: Int(value)) : "-"
				} else {
					description = "-"
				}
			}
        case .respiratory:
            self.statsProvider.getDataByIntervalWithIndicator(healthType: .respiratory,
                                                              indicatorType: .mean,
                                                              for: DateInterval(start: date.startOfDay, end: date.endOfDay),
                                                              bundlePrefixes: ["com.sinapsis", "com.benmustafa"]) { val in
                value = val
                getCircleColor()

                if let value = value {
                    description = !value.isNaN ? String(Int(value)) : "-"
                } else {
                    description = "-"
                }
            }
        }
	}
}

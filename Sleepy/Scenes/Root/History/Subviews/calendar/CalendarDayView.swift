// Copyright (c) 2021 Sleepy.

import HealthKit
import HKCoreSleep
import HKStatistics
import HKVisualKit
import SettingsKit
import SwiftUI
import XUI

struct CalendarDayView: View {
	@Store var viewModel: HistoryCoordinator
	@Binding var monthDate: Date

	@State private var description = ""
	@State private var value: Double?
	@State private var circleColor: Color?

	let currentDate: Date
	let dateIndex: Int

	let sleepGoal: Int

	var body: some View {
		GeometryReader { geometry in
			ZStack {
				Circle()
					.foregroundColor(circleColor ?? viewModel.colorSchemeProvider.sleepyColorScheme.getColor(of: .calendar(.emptyDayColor)))

				if currentDate.getMonthInt() == monthDate.getMonthInt() &&
					currentDate.getDayInt() == dateIndex
				{
					Circle()
						.strokeBorder(viewModel.colorSchemeProvider.sleepyColorScheme.getColor(of: .calendar(.calendarCurrentDateColor)), lineWidth: 3)
				}

				Text(description)
					.dayCircleInfoTextModifier(geometry: geometry)
					.onAppear(perform: getDayData)
					.onChange(of: viewModel.calendarType) { _ in
						getDayData()
					}
					.onChange(of: monthDate) { _ in
						getDayData()
					}
			}
		}
	}

	private func getDayData() {
		let date = Calendar.current.date(byAdding: .day, value: self.dateIndex - self.monthDate.getDayInt(), to: self.monthDate) ?? Date()
		self.description = "-"
		self.value = nil
		self.setCircleColor()

		guard let calendarType = HKService.HealthType(rawValue: self.viewModel.calendarType.rawValue) else { return }

		switch calendarType {
		case .heart, .respiratory, .energy:
			self.viewModel.statisticsProvider.getMetaData(healthType: calendarType,
			                                              indicator: .mean,
			                                              interval: DateInterval(start: date.startOfDay, end: date.endOfDay)) { val in
				value = val
				setCircleColor()

				if let value = value {
					description = !value.isNaN
						? calendarType == .energy
						? String(format: "%.2f", value)
						: String(Int(value))
						: "-"
				} else {
					description = "-"
				}
			}

		case .asleep, .inbed:
			self.viewModel.statisticsProvider.getData(healthType: calendarType,
			                                          indicator: .sum,
			                                          interval: DateInterval(start: date.startOfDay, end: date.endOfDay),
			                                          bundlePrefixes: ["com.sinapsis", "com.benmustafa"]) { val in
				value = val
				setCircleColor()

				if let value = value {
					description = !value.isNaN ? Date.minutesToDateDescription(minutes: Int(value)) : "-"
				} else {
					description = "-"
				}
			}
		}
	}

	private func setCircleColor() {
		if let value = value {
			switch self.viewModel.calendarType {
			case .heart:
				self.circleColor = self.viewModel.colorSchemeProvider.sleepyColorScheme.getColor(of: .heart(.heartColor))

			case .asleep, .inbed:
				self.circleColor = Int(value) > self.sleepGoal
					? self.viewModel.colorSchemeProvider.sleepyColorScheme.getColor(of: .calendar(.positiveDayColor))
					: (value > Double(self.sleepGoal) * 0.9
						? self.viewModel.colorSchemeProvider.sleepyColorScheme.getColor(of: .calendar(.neutralDayColor))
						: self.viewModel.colorSchemeProvider.sleepyColorScheme.getColor(of: .calendar(.negativeDayColor)))

			case .energy:
				self.circleColor = self.viewModel.colorSchemeProvider.sleepyColorScheme.getColor(of: .energy(.energyColor))

			case .respiratory:
				self.circleColor = Color(.systemBlue)
			}
		} else {
			self.circleColor = self.viewModel.colorSchemeProvider.sleepyColorScheme.getColor(of: .calendar(.emptyDayColor))
			return
		}
	}
}

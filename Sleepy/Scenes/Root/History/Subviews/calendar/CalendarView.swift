// Copyright (c) 2021 Sleepy.

import HKStatistics
import SettingsKit
import SwiftUI
import UIComponents
import XUI

struct CalendarView: View {
	@Store var viewModel: HistoryCoordinator
	@State private var totalHeight = CGFloat.zero // variant for ScrollView/List
	// = CGFloat.infinity - variant for VStack

	private let calendarGridLayout = Array(repeating: GridItem(.flexible()), count: 7)

	var body: some View {
		VStack {
			GeometryReader { geometry in
				let calendarElementSize = geometry.size.width / 8

				VStack {
					CalendarTitleView(calendarType: $viewModel.calendarType,
					                  monthDate: $viewModel.monthDate,
					                  colorSchemeProvider: viewModel.colorSchemeProvider)

					HealthTypeSwitchView(selectedType: $viewModel.calendarType,
					                     colorScheme: viewModel.colorSchemeProvider.sleepyColorScheme)

					LazyVGrid(columns: calendarGridLayout, spacing: 4) {
						ForEach(1 ... viewModel.monthDate.getDaysInMonth(), id: \.self) { index in
							VStack(spacing: 2) {
								if index >= 1, index <= 7 {
									let tmpWeekDay = Calendar.current.date(byAdding: .day,
									                                       value: index - 1,
									                                       to: viewModel.monthDate.startOfMonth)!

									Text(tmpWeekDay.weekday() ?? "")
										.weekDayTextModifier(width: calendarElementSize)
								}

								CalendarDayView(viewModel: viewModel,
								                monthDate: $viewModel.monthDate,
								                currentDate: Date(),
								                dateIndex: index, sleepGoal: UserDefaults.standard.integer(forKey: SleepySettingsKeys.sleepGoal.rawValue))
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
								viewModel.monthDate = Calendar.current.date(byAdding: .month,
								                                            value: horizontalAmount < 0 ? 1 : -1,
								                                            to: viewModel.monthDate)!
							}
						})
				}.background(viewHeightReader($totalHeight))
			}
		}.frame(height: totalHeight) // - variant for ScrollView/List
		// .frame(maxHeight: totalHeight) - variant for VStack
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

			Button {
				monthDate = Calendar.current.date(byAdding: .month,
				                                  value: -1,
				                                  to: monthDate)!
			} label: {
				Text(Image(systemName: "chevron.left"))
					.boldTextModifier(color: getSelectedCalendarColor(for: calendarType))
			}
			.padding(.trailing, 8)

			Button {
				monthDate = Calendar.current.date(byAdding: .month,
				                                  value: 1,
				                                  to: monthDate)!
			} label: {
				Text(Image(systemName: "chevron.right"))
					.boldTextModifier(color: getSelectedCalendarColor(for: calendarType))
			}

		}.frame(height: 30, alignment: .top)
	}

	private func getSelectedCalendarColor(for type: HealthData) -> Color {
		switch type {
		case .heart:
			return self.colorSchemeProvider.sleepyColorScheme.getColor(of: .heart(.heartColor))
		case .energy:
			return self.colorSchemeProvider.sleepyColorScheme.getColor(of: .energy(.energyColor))
		case .asleep:
			return self.colorSchemeProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor))
		case .inbed:
			return self.colorSchemeProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor))
		case .respiratory:
			return Color(.systemBlue)
		}
	}
}

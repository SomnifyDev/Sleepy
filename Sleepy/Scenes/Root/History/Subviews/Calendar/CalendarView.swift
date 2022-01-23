// Copyright (c) 2021 Sleepy.

import HKStatistics
import SettingsKit
import SwiftUI
import HKCoreSleep
import UIComponents
import XUI

struct CalendarView: View {
	@Store var viewModel: HistoryCoordinator
    let interactor: HistoryInteractor

	@State private var totalHeight = CGFloat.zero // variant for ScrollView/List
	// = CGFloat.infinity - variant for VStack

	private let calendarGridLayout = Array(repeating: GridItem(.flexible()), count: 7)

	var body: some View {
		VStack {
			GeometryReader { geometry in
				let calendarElementSize = geometry.size.width / 8

				VStack {
					CalendarTitleView(calendarType: $viewModel.calendarType,
					                  monthDate: $viewModel.monthDate)

                    HealthTypeSwitchView(selectedType: $viewModel.calendarType, interactor: self.interactor)

					LazyVGrid(columns: calendarGridLayout, spacing: 4) {
                        ForEach(1 ... viewModel.calendarData.count, id: \.self) { index in
							VStack(spacing: 2) {
								if index >= 1, index <= 7 {
									let tmpWeekDay = Calendar.current.date(byAdding: .day,
									                                       value: index - 1,
									                                       to: viewModel.monthDate.startOfMonth)!

									Text(tmpWeekDay.weekday() ?? "")
										.weekDayTextModifier(width: calendarElementSize)
								}

                                CalendarDayView(displayItem: viewModel.calendarData[index - 1])
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
                                self.interactor.extractCalendarData()
							}
						})
				}.background(viewHeightReader($totalHeight))
            }.onAppear {
                self.interactor.extractCalendarData()
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
	@Binding var calendarType: HKService.HealthType
	@Binding var monthDate: Date

	var body: some View {
		HStack {
			Text(Image(systemName: "calendar"))
                .regularTextModifier(color: ColorsRepository.Text.standard, size: 24)

			Text("\(monthDate.getMonthString()) \(monthDate.getYearString())")
				.calendarMonthTitleModifier(color: ColorsRepository.Text.standard)

			Spacer()

			Button {
				monthDate = Calendar.current.date(byAdding: .month,
				                                  value: -1,
				                                  to: monthDate)!
			} label: {
				Text(Image(systemName: "chevron.left"))
                    .boldTextModifier(color: ColorsRepository.Text.standard)
			}
			.padding(.trailing, 8)

			Button {
				monthDate = Calendar.current.date(byAdding: .month,
				                                  value: 1,
				                                  to: monthDate)!
			} label: {
				Text(Image(systemName: "chevron.right"))
					.boldTextModifier(color: ColorsRepository.Text.standard)
			}

		}.frame(height: 30, alignment: .top)
	}
}

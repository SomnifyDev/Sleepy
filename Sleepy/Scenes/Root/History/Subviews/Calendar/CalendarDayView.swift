// Copyright (c) 2021 Sleepy.

import HealthKit
import HKCoreSleep
import HKStatistics
import SettingsKit
import SwiftUI
import UIComponents
import XUI

struct CalendarDayView: View {
    struct DisplayItem {
        var value: Double?
        var description: String
        var color: Color
        var isToday: Bool
    }

    let displayItem: DisplayItem

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .foregroundColor(displayItem.color)

                if displayItem.isToday {
                    Circle()
                        .strokeBorder(ColorsRepository.Calendar.calendarCurrentDate, lineWidth: 3)
                }

                Text(displayItem.description)
                    .dayCircleInfoTextModifier(geometry: geometry)
//                    .onAppear(perform: self.viewModel.getDay)
//                    .onChange(of: viewModel.calendarType) { _ in
//                        getDayData()
//                    }
//                    .onChange(of: monthDate) { _ in
//                        getDayData()
//                    }
            }
        }
    }
}

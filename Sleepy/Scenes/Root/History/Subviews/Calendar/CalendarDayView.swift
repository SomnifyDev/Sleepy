// Copyright (c) 2022 Sleepy.

import HealthKit
import HKCoreSleep
import HKStatistics
import SettingsKit
import SwiftUI
import UIComponents
import XUI

struct CalendarDayView: View {
    struct DisplayItem: Identifiable, Hashable {
        var id = UUID()
        var dayNumber: Int
        let value: Double?
        let description: String
        let color: Color
        let isToday: Bool
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
            }
        }
    }
}

//
//  TimeLineView.swift
//  HKVisualKit
//
//  Created by Анас Бен Мустафа on 7/14/21.
//

import SwiftUI

struct TimeLineView: View {

    private let colorProvider: ColorSchemeProvider
    private let startTime: Date
    private let endTime: Date

    init(colorProvider: ColorSchemeProvider, startTime: Date, endTime: Date) {
        self.colorProvider = colorProvider
        self.startTime = startTime
        self.endTime = endTime
    }

    var body: some View {
        HStack {
            Text("\(startTime)")
                .regularTextModifier(color: colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)), size: 10, opacity: 0.4)
            
            Spacer()

            Text("\(endTime)")
                .regularTextModifier(color: colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)), size: 10, opacity: 0.4)
        }
    }
}

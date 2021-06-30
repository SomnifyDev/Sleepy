//
//  SleepyColorsScheme.swift
//  Sleepy
//
//  Created by Анас Бен Мустафа on 6/9/21.
//

import Foundation
import SwiftUI

// MARK: - Protocol

public protocol HKApplicationColorScheme {

    func getColor(of type: ColorType) -> Color

}

// MARK: - Implementation

public final class SleepyColorScheme: HKApplicationColorScheme {

    // general
    var appBackgroundColor: Color
    var mainSleepyColor: Color
    var healthColor: Color

    // cards
    var cardBackgroundColor: Color

    // calendar
    var emptyDayColor: Color
    var negativeDayColor: Color
    var neutralDayColor: Color
    var positiveDayColor: Color

    // phases
    var wakeUpColor: Color
    var lightSleepColor: Color
    var deepSleepColor: Color

    // heart
    var heartColor: Color

    // genInfoCard
    var awakeColor: Color
    var moonColor: Color

    // MARK: init
    
    init() {
        appBackgroundColor = Color("backgroundColor")
        mainSleepyColor = Color("mainColor")
        healthColor = Color("healthColor")
        cardBackgroundColor = Color("cardsBackground")
        emptyDayColor = Color("calendarEmptyColor")
        negativeDayColor = Color("calendarNegativityColor")
        neutralDayColor = Color("calendarNeutralColor")
        positiveDayColor = Color("calendarPositivityColor")
        wakeUpColor = Color("wakingColor")
        lightSleepColor = Color("lightSleepColor")
        deepSleepColor = Color("deepSleepColor")
        heartColor = Color("heartColor")
        awakeColor = Color("awakeColor")
        moonColor = Color("moonColor")
    }

    // MARK: Public methods

    public func getColor(of type: ColorType) -> Color {
        switch type {
        // general
        case .general(.appBackgroundColor):
            return appBackgroundColor
        case .general(.healthColor):
            return healthColor
        case .general(.mainSleepyColor):
            return mainSleepyColor

        // card
        case .card(.cardBackgroundColor):
            return cardBackgroundColor

        // phases
        case .phases(.deepSleepColor):
            return deepSleepColor
        case .phases(.lightSleepColor):
            return lightSleepColor
        case .phases(.wakeUpColor):
            return wakeUpColor

        // heart
        case .heart(.heartColor):
            return heartColor

        // calendar
        case .calendar(.emptyDayColor):
            return emptyDayColor
        case .calendar(.negativeDayColor):
            return emptyDayColor
        case .calendar(.neutralDayColor):
            return emptyDayColor
        case .calendar(.positiveDayColor):
            return emptyDayColor

        // general info card
        case .genInfoCardColors(.awakeColor):
            return awakeColor
        case .genInfoCardColors(.moonColor):
            return moonColor
        }
    }

}

//
//  SleepyColorsScheme.swift
//  Sleepy
//
//  Created by Анас Бен Мустафа on 6/9/21.
//
// TODO: - перенести asset'ы цветов из главной прилы внутрь фреймворма

import Foundation
import SwiftUI

// MARK: - Protocol

public protocol HKApplicationColorScheme {

    func getColor(of type: ColorType) -> Color

}

// MARK: - Implementation

public final class SleepyColorScheme: HKApplicationColorScheme {

    // general
    private var appBackgroundColor: Color
    private var mainSleepyColor: Color
    private var healthColor: Color

    // cards
    private var cardBackgroundColor: Color

    // calendar
    private var emptyDayColor: Color
    private var negativeDayColor: Color
    private var neutralDayColor: Color
    private var positiveDayColor: Color

    // phases
    private var wakeUpColor: Color
    private var lightSleepColor: Color
    private var deepSleepColor: Color

    // heart
    private var heartColor: Color

    // energy
    private var energyColor: Color

    // genInfoCard
    private var awakeColor: Color
    private var moonColor: Color

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
        energyColor = Color("energyColor")
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

            // energy
        case .energy(.energyColor):
            return energyColor

            // calendar
        case .calendar(.emptyDayColor):
            return emptyDayColor
        case .calendar(.negativeDayColor):
            return negativeDayColor
        case .calendar(.neutralDayColor):
            return neutralDayColor
        case .calendar(.positiveDayColor):
            return positiveDayColor

            // general info card
        case .genInfoCardColors(.awakeColor):
            return awakeColor
        case .genInfoCardColors(.moonColor):
            return moonColor
        }
    }

}

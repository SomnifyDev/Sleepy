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



public final class SleepyColorScheme: HKApplicationColorScheme {

    // general
    private let appBackgroundColor: Color
    private let mainSleepyColor: Color
    private let healthColor: Color

    // cards
    private let cardBackgroundColor: Color

    // calendar
    private let emptyDayColor: Color
    private let negativeDayColor: Color
    private let neutralDayColor: Color
    private let positiveDayColor: Color
    private let calendarCurrentDateColor: Color

    // phases
    private let wakeUpColor: Color
    private let lightSleepColor: Color
    private let deepSleepColor: Color

    // heart
    private let heartColor: Color

    // energy
    private let energyColor: Color

    // genInfoCard
    private let awakeColor: Color
    private let moonColor: Color
    private let sleepDurationColor: Color
    private let fallAsleepDurationColor: Color

    // texts
    private let standartText: Color
    private let secondaryText: Color
    private let adviceText: Color
    // charts
    private let verticalProgressChartElementColor: Color

    
    
    init() {
        appBackgroundColor = Color("backgroundColor")
        mainSleepyColor = Color("mainColor")
        healthColor = Color("healthColor")
        cardBackgroundColor = Color("cardsBackground")
        emptyDayColor = Color("calendarEmptyColor")
        negativeDayColor = Color("calendarNegativityColor")
        neutralDayColor = Color("calendarNeutralColor")
        positiveDayColor = Color("calendarPositivityColor")
        calendarCurrentDateColor = Color("calendarCurrentDateColor")
        wakeUpColor = Color("wakingColor")
        lightSleepColor = Color("lightSleepColor")
        deepSleepColor = Color("deepSleepColor")
        heartColor = Color("heartColor")
        awakeColor = Color("awakeColor")
        moonColor = Color("moonColor")
        energyColor = Color("energyColor")
        standartText = Color("SleepyStandartTexts")
        secondaryText = Color("SecondaryText")
        adviceText = Color("AdviceText")
        sleepDurationColor = Color("sleepDurationColor")
        fallAsleepDurationColor = Color("fallAsleepDurationColor")
        verticalProgressChartElementColor = Color("VerticalProgressChartElementBackground")
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
        case .calendar(.calendarCurrentDateColor):
            return calendarCurrentDateColor

            // general info card
        case .summaryCardColors(.awakeColor):
            return awakeColor
        case .summaryCardColors(.moonColor):
            return moonColor
        case .summaryCardColors(.sleepDurationColor):
            return sleepDurationColor
        case .summaryCardColors(.fallAsleepDurationColor):
            return fallAsleepDurationColor

            // texts
        case .textsColors(.standartText):
            return standartText
        case .textsColors(.secondaryText):
            return secondaryText
        case .chartColors(.verticalProgressChartElement):
            return verticalProgressChartElementColor
        case .textsColors(.adviceText):
            return adviceText
        }
    }

}

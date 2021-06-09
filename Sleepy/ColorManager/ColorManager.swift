//
//  ColorManager.swift
//  Sleepy
//
//  Created by Анас Бен Мустафа on 6/7/21.
//

import UIKit
import SwiftUI

final class SleepyColorScheme: HKApllicationColorScheme {
    
    // MARK: General
    var appBackgroundColor: Color
    var mainSleepyColor: Color
    var healthColor: Color
    
    enum GeneralColors {
        case appBackgroundColor
        case mainSleepyColor
        case healthColor
    }
    
    // MARK: Cards
    var cardBackgroundColor: Color
    
    enum CardColors {
        case cardBackgroundColor
    }
    
    // MARK: Calendar
    var emptyDayColor: Color
    var negativeDayColor: Color
    var neutralDayColor: Color
    var positiveDayColor: Color
    
    enum CalendarColors {
        case emptyDayColor
        case negativeDayColor
        case neutralDayColor
        case positiveDayColor
    }
    
    // MARK: Phases
    var wakeUpColor: Color
    var lightSleepColor: Color
    var deepSleepColor: Color
    
    enum PhasesColors {
        case wakeUpColor
        case lightSleepColor
        case deepSleepColor
    }
    
    // MARK: Heart
    var heartColor: Color
    
    enum HeartColors {
        case heartColor
    }
    
    // MARK: GenInfoCard
    var awakeColor: Color
    var moonColor: Color
    
    enum GenInfoCardColors {
        case awakeColor
        case moonColor
    }
    
    // MARK: init - getting colors from assets
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
    
    enum colorType {
        case general(GeneralColors)
        case card(CardColors)
        case phases(PhasesColors)
        case heart(HeartColors)
        case calendar(CalendarColors)
        case genInfoCardColors(GenInfoCardColors)
    }
    
    func getColor(of type: colorType) -> Color {
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

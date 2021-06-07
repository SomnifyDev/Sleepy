//
//  ColorManager.swift
//  Sleepy
//
//  Created by Анас Бен Мустафа on 6/7/21.
//

import UIKit
import SwiftUI

// exmaple of color manager
class colorManager {
    
    // MARK: General
    var appBackgroundColor: Color
    var mainSleepyColor: Color
    var healthColor: Color
    
    enum generalColors {
        case appBackgroundColor
        case mainSleepyColor
        case healthColor
    }
    
    // MARK: Cards
    var cardBackgroundColor: Color
    
    enum cardColors {
        case cardBackgroundColor
    }
    
    // MARK: Calendar
    var emptyDayColor: Color
    var negativeDayColor: Color
    var neutralDayColor: Color
    var positiveDayColor: Color
    
    enum calendarColors {
        case emptyDayColor
        case negativeDayColor
        case neutralDayColor
        case positiveDayColor
    }
    
    // MARK: Phases
    var wakeUpColor: Color
    var lightSleepColor: Color
    var deepSleepColor: Color
    
    enum phasesColors {
        case wakeUpColor
        case lightSleepColor
        case deepSleepColor
    }
    
    // MARK: Heart
    var heartColor: Color
    
    enum heartColors {
        case heartColor
    }
    
    // MARK: GenInfoCard
    var awakeColor: Color
    var moonColor: Color
    
    enum genInfoCardColors {
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
        case general(generalColors)
        case card(cardColors)
        case phases(phasesColors)
        case heart(heartColors)
        case calendar(calendarColors)
        case genInfoCardColors(genInfoCardColors)
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

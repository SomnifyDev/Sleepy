//
//  SleepyColorsScheme.swift
//  Sleepy
//
//  Created by Анас Бен Мустафа on 6/9/21.
//

import Foundation
import SwiftUI

public protocol HKApllicationColorScheme {
    
    // MARK: General
    var appBackgroundColor: Color { get }
    var mainSleepyColor: Color { get }
    var healthColor: Color { get }
    
    // MARK: Cards
    var cardBackgroundColor: Color { get }
    
    // MARK: Calendar
    var emptyDayColor: Color { get }
    var negativeDayColor: Color { get }
    var neutralDayColor: Color { get }
    var positiveDayColor: Color { get }
    
    // MARK: Phases
    var wakeUpColor: Color { get }
    var lightSleepColor: Color { get }
    var deepSleepColor: Color { get }
    
    // MARK: Heart
    var heartColor: Color { get }
    
    // MARK: GenInfoCard
    var awakeColor: Color { get }
    var moonColor: Color { get }
    
}

//
//  Enums.swift
//  HKStatistics
//
//  Created by Анас Бен Мустафа on 6/25/21.
//

import Foundation

enum IndicatorType {
    
    case min
    case max
    case mean
    
}

enum NumericDataType {
    
    case heart
    case energy
    
}

enum SleepDataType {
    
    case sleep
    case phases
    
}

enum PhasesStatisticsType {
    
    case deepPhaseTime
    case lightPhaseTime
    case mostIntervalInDeepPhase
    case mostIntervalInLightPhase
    
}

enum PhaseCondition {
    
    case deepPhase
    case lightPhase
    
}

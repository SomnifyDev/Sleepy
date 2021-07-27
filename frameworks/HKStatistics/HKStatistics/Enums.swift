//
//  Enums.swift
//  HKStatistics
//
//  Created by Анас Бен Мустафа on 6/25/21.
//

import Foundation

public enum IndicatorType {
    
    case min
    case max
    case mean
    case sum
    
}

public enum NumericDataType {
    
    case heart
    case energy
    
}

public enum SleepStatType {
    
    case asleep
    case inBed
    
}

public enum PhasesStatisticsType {

    case phasesData
    case deepPhaseTime
    case lightPhaseTime
    case mostIntervalInDeepPhase
    case mostIntervalInLightPhase
    
}

public enum PhaseCondition {
    
    case deepPhase
    case lightPhase
    
}

public enum SleepBoundaryType {

    case start
    case end

}

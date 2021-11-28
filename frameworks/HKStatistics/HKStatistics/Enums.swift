// Copyright (c) 2021 Sleepy.

import Foundation

public enum IndicatorType: String {
    case min = "Min."
    case max = "Max."
    case mean = "Avg."
    case sum = "Sum."
}

public enum NumericDataType {
    case heart
    case energy
    case respiratory
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

public enum SleepIntervalType {
    case inbed
    case asleep
}

//
//  SubProviders.swift
//  HKStatistics
//
//  Created by Анас Бен Мустафа on 6/25/21.
//

import Foundation

// Здесь обрабатываются сразу двое - сердце и энергия (потенциально еще звук)
final class HKNumericTypesStatisticsProvider {
    
    func handlingIndicator(of type: IndicatorType, for data: [Double]) -> Double {
        switch type {
        case .min:
            if let min = data.min() { return min } else { assertionFailure("Couldn't get min from data"); return -1 }
        case .max:
            if let max = data.max() { return max } else { assertionFailure("Couldn't get max from data"); return -1 }
        case .mean:
            return data.reduce(0.0) { $0 + $1 } / Double(data.count)
        }
        
    }
}

final class HKPhasesStatisticsProvider {
    
    func handlingStatistic(of type: PhasesStatisticsType, for data: [Phase]) -> Double {
        switch type {
        case .deepPhaseTime:
            return data.filter { $0.condition == .deepPhase }.reduce(0.0) { partialResult, phase in
                partialResult + minutesBetweenDates(phase.startTime, phase.endTime)
            }
        case .lightPhaseTime:
            return data.filter { $0.condition == .lightPhase }.reduce(0.0) { partialResult, phase in
                partialResult + minutesBetweenDates(phase.startTime, phase.endTime)
            }
        case .mostIntervalInDeepPhase:
            return data.filter { $0.condition == .deepPhase }.map { minutesBetweenDates($0.startTime, $0.endTime) }.max()!
        case .mostIntervalInLightPhase:
            return data.filter { $0.condition == .lightPhase }.map { minutesBetweenDates($0.startTime, $0.endTime) }.max()!
        }
    }
    
    private func minutesBetweenDates(_ oldDate: Date, _ newDate: Date) -> Double {
        let newDateMinutes = newDate.timeIntervalSinceReferenceDate / 60
        let oldDateMinutes = oldDate.timeIntervalSinceReferenceDate / 60
        return Double(newDateMinutes - oldDateMinutes)
    }
    
}

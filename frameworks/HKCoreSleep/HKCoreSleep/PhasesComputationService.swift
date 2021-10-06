import Foundation
import HealthKit

final class PhasesComputationService {
    var phasesData: [Phase] = []

    init(sleep: Sleep) {
        computatePhases(sleep: sleep)
    }

    // MARK: Phases computation

    private func computatePhases(sleep: Sleep) {
        let (heartRateTimeData, heartRateValuesData, meanHeartRate) = getPulseData(heartSamples: sleep.heartSamples?.reversed())
        let (energyTimeData, energyValuesData) = getEnergyData(energySamples: sleep.energySamples?.reversed())

        guard
            !heartRateTimeData.isEmpty,
            !heartRateValuesData.isEmpty,
            !energyTimeData.isEmpty,
            !energyValuesData.isEmpty,
            let meanHeartRate = meanHeartRate
        else {
            return
        }

        for index in stride(from: 0, to: heartRateTimeData.count, by: 3) {
            guard index + 3 < heartRateTimeData.count else { break }

            let isPotencialAwake = index - 3 >= 0 ? isDifferenceBiggerThan20Percents(measurings: heartRateValuesData[(index - 3) ... (index + 3)]) : false
            let coeff1 = lastEnergyTimeIntervalBeforeLastHeartRate(energyTimeData: energyTimeData, heartRateTime: heartRateTimeData[index + 3])
            let coeff2 = heartRateJumps(heartRateData: heartRateValuesData[index ... (index + 3)])
            let coeff3 = isPulseIntervalLessThanAverage(heartRateData: heartRateValuesData[index ... (index + 3)], meanHeartRate: meanHeartRate)

            let verdictCoefficient = coeff1 + coeff2 + coeff3

            let interval = DateInterval(start: heartRateTimeData[index], end: heartRateTimeData[index + 3])
            let condition: Condition = verdictCoefficient > 0.5 ? .deep : isPotencialAwake ? .awake : .light
            let meanHeartRate: Double = heartRateValuesData[index ... index + 3].reduce(0.0) { $0 + Double($1) } / 4.0

            phasesData.append(Phase(interval: interval,
                                    condition: condition,
                                    verdictCoefficient: verdictCoefficient,
                                    meanHeartRate: meanHeartRate,
                                    chartPoint: getChartPoint(condition: condition, verdictCoefficient: verdictCoefficient, meanHeartRate: meanHeartRate)))
        }

        if !phasesData.isEmpty {
            phasesData.append(Phase(interval: DateInterval(start: sleep.sleepInterval.end, end: sleep.sleepInterval.end),
                                    condition: .awake,
                                    verdictCoefficient: 1,
                                    meanHeartRate: nil,
                                    chartPoint: 1.1))
        }
    }

    // MARK: Coefficients computation

    private func lastEnergyTimeIntervalBeforeLastHeartRate(energyTimeData: [Date], heartRateTime: Date) -> Double {
        var previousInterval = heartRateTime.timeIntervalSince(energyTimeData[0])

        for i in 1 ..< energyTimeData.count {
            if heartRateTime.timeIntervalSince(energyTimeData[i]) < 0 {
                return (previousInterval >= 900) ? 0.35 : 0.0
            }
            previousInterval = heartRateTime.timeIntervalSince(energyTimeData[i])
        }

        return (previousInterval >= 900) ? 0.35 : 0.0
    }

    private func heartRateJumps(heartRateData: Array<Int>.SubSequence) -> Double {
        guard
            let max = heartRateData.max(),
            let min = heartRateData.min()
        else {
            return 0.0
        }

        return max - min < 3 ? 0.45 : 0.0
    }

    private func isPulseIntervalLessThanAverage(heartRateData: Array<Int>.SubSequence, meanHeartRate: Double) -> Double {
        return (heartRateData.reduce(0.0) { $0 + Double($1) } / 4.0) < meanHeartRate ? 0.2 : 0.0
    }

    private func isDifferenceBiggerThan20Percents(measurings: Array<Int>.SubSequence) -> Bool {
        let stack1 = measurings[...(measurings.startIndex + 3)], stack2 = measurings[(measurings.startIndex + 3)...]
        guard
            let min = stack1.min(),
            let max = stack2.max()
        else {
            return false
        }
        return Double(max - min) / Double(min) >= 0.2 ? true : false
    }

    // MARK: Phases chart points

    private func getChartPoint(condition: Condition, verdictCoefficient: Double, meanHeartRate: Double) -> Double {
        switch condition {
        case .awake:
            return getAwakeChartPoint(verdictCoefficient: verdictCoefficient, meanHeartRate: meanHeartRate)
        case .light:
            return getLightChartPoint(verdictCoefficient: verdictCoefficient, meanHeartRate: meanHeartRate)
        case .deep:
            return getDeepChartPoint(verdictCoefficient: verdictCoefficient, meanHeartRate: meanHeartRate)
        }
    }

    private func getAwakeChartPoint(verdictCoefficient _: Double, meanHeartRate _: Double) -> Double {
        return 1.1
    }

    private func getLightChartPoint(verdictCoefficient: Double, meanHeartRate: Double) -> Double {
        let tmp = 1 - verdictCoefficient
        if doubleEqual(tmp, 1) {
            return 0.75 + (meanHeartRate.truncatingRemainder(dividingBy: 10) / 100)
        } else if doubleEqual(tmp, 0.8) {
            return 0.7 + (meanHeartRate.truncatingRemainder(dividingBy: 10) / 100)
        } else if doubleEqual(tmp, 0.65) {
            return 0.65 + (meanHeartRate.truncatingRemainder(dividingBy: 10) / 100)
        } else if doubleEqual(tmp, 0.55) {
            return 0.55 + (meanHeartRate.truncatingRemainder(dividingBy: 10) / 100)
        }
        return 0.0
    }

    private func getDeepChartPoint(verdictCoefficient: Double, meanHeartRate: Double) -> Double {
        let tmp = 1 - verdictCoefficient
        if doubleEqual(tmp, 0) {
            return 0.15 + (meanHeartRate.truncatingRemainder(dividingBy: 10) / 100)
        } else if doubleEqual(tmp, 0.2) {
            return 0.2 + (meanHeartRate.truncatingRemainder(dividingBy: 10) / 100)
        } else if doubleEqual(tmp, 0.35) {
            return 0.25 + (meanHeartRate.truncatingRemainder(dividingBy: 10) / 100)
        } else if doubleEqual(tmp, 0.45) {
            return 0.35 + (meanHeartRate.truncatingRemainder(dividingBy: 10) / 100)
        }
        return 0.0
    }

    // MARK: Data handlers

    private func getPulseData(heartSamples: [HKSample]?) -> ([Date], [Int], Double?) {
        guard
            let heartSamples = heartSamples as? [HKQuantitySample]
        else {
            return ([], [], nil)
        }

        let heartRateData = heartSamples.map { Int($0.quantity.doubleValue(for: HKUnit(from: "count/min"))) }

        return (heartSamples.map { $0.startDate },
                heartRateData,
                (heartRateData.reduce(0.0) { $0 + Double($1) }) / Double(heartRateData.count))
    }

    private func getEnergyData(energySamples: [HKSample]?) -> ([Date], [Double]) {
        guard
            let energySamples = energySamples as? [HKQuantitySample]
        else {
            return ([], [])
        }

        return (energySamples.map { $0.startDate },
                energySamples.map { $0.quantity.doubleValue(for: HKUnit.kilocalorie()) })
    }

    // MARK: Auxiliary functions

    private func doubleEqual(_ a: Double, _ b: Double) -> Bool {
        return fabs(a - b) < Double.ulpOfOne
    }
}

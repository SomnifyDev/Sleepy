// Copyright (c) 2021 Sleepy.

import Foundation
import HealthKit

final class PhasesComputationService
{
    static func computatePhases(energySamples: [HKSample],
                                heartSamples: [HKSample],
                                breathSamples: [HKSample],
                                sleepInterval: DateInterval) -> [Phase]
    {
        let (heartRateTimeData, heartRateValuesData, meanHeartRate) = self.getPulseData(heartSamples: heartSamples.reversed())
        let (energyTimeData, energyValuesData) = self.getEnergyData(energySamples: energySamples.reversed())

        guard !heartRateTimeData.isEmpty,
              !heartRateValuesData.isEmpty,
              !energyTimeData.isEmpty,
              !energyValuesData.isEmpty,
              let meanHeartRate = meanHeartRate else
        {
            return []
        }

        var phasesData: [Phase] = []

        for index in stride(from: 0, to: heartRateTimeData.count, by: 3)
        {
            guard index + 3 < heartRateTimeData.count,
                  let minsDiff = Calendar.current.dateComponents(
                      [.minute],
                      from: heartRateTimeData[index],
                      to: heartRateTimeData[index + 3]
                  )
                  .minute else
            {
                break
            }

            guard minsDiff > 3 else { continue }

            let isPotencialAwake = index - 3 >= 0 ? self.isDifferenceBiggerThan20Percents(measurings: heartRateValuesData[(index - 3) ... (index + 3)]) : false
            let coeff1 = self.lastEnergyTimeIntervalBeforeLastHeartRate(energyTimeData: energyTimeData, heartRateTime: heartRateTimeData[index + 3])
            let coeff2 = self.heartRateJumps(heartRateData: heartRateValuesData[index ... (index + 3)])
            let coeff3 = self.isPulseIntervalLessThanAverage(heartRateData: heartRateValuesData[index ... (index + 3)], meanHeartRate: meanHeartRate)

            let verdictCoefficient = coeff1 + coeff2 + coeff3

            let interval = DateInterval(
                start: heartRateTimeData[index],
                end: heartRateTimeData[index + 3]
            )

            let condition: Condition = verdictCoefficient > 0.5 ? .deep : isPotencialAwake ? .awake : .light

            let phaseHeartRate = heartRateValuesData[index ... index + 3]
            let meanHeartRate: Double = phaseHeartRate.reduce(0.0) { $0 + Double($1) } / 4.0

            // формируем объекты SampleData каждого показателя здоровья на промежутке фазы
            let heartSampleData: [HKSample] = heartSamples.reversed().filter { $0.startDate >= interval.start && $0.endDate <= interval.end }
            let energySampleData: [HKSample] = energySamples.reversed().filter { $0.startDate >= interval.start && $0.endDate <= interval.end }
            let breathSampleData: [HKSample] = breathSamples.reversed().filter { $0.startDate >= interval.start && $0.endDate <= interval.end }

            guard
                let quantityHeart = heartSampleData as? [HKQuantitySample],
                let quantityEnergy = energySampleData as? [HKQuantitySample],
                let quantityBreath = breathSampleData as? [HKQuantitySample] else
            {
                continue
            }

            phasesData.append(
                Phase(
                    interval: interval,
                    condition: condition,
                    heartData: quantityHeart.map { SampleData(
                        date: $0.startDate,
                        value: $0.quantity.doubleValue(
                            for: HKUnit(from: "count/min")
                        )
                    ) },
                    energyData: quantityEnergy.map { SampleData(
                        date: $0.startDate,
                        value: $0.quantity.doubleValue(
                            for: HKUnit.kilocalorie()
                        )
                    ) },
                    breathData: quantityBreath.map { SampleData(
                        date: $0.startDate,
                        value: $0.quantity.doubleValue(
                            for: HKUnit(from: "count/min")
                        )
                    ) },
                    verdictCoefficient: verdictCoefficient,
                    meanHeartRate: meanHeartRate,
                    chartPoint: self.getChartPoint(
                        condition: condition,
                        verdictCoefficient: verdictCoefficient,
                        meanHeartRate: meanHeartRate
                    )
                )
            )
        }

        if !phasesData.isEmpty
        {
            phasesData.append(
                Phase(
                    interval: DateInterval(
                        start: sleepInterval.end,
                        end: sleepInterval.end
                    ),
                    condition: .awake,
                    heartData: [],
                    energyData: [],
                    breathData: [],
                    verdictCoefficient: 1,
                    meanHeartRate: nil,
                    chartPoint: 1.1
                )
            )
        }
        return phasesData
    }

    // MARK: Coefficients computation

    private static func lastEnergyTimeIntervalBeforeLastHeartRate(energyTimeData: [Date],
                                                                  heartRateTime: Date) -> Double
    {
        var previousInterval = heartRateTime.timeIntervalSince(energyTimeData[0])

        for i in 1 ..< energyTimeData.count
        {
            if heartRateTime.timeIntervalSince(energyTimeData[i]) < 0
            {
                return (previousInterval >= 900) ? 0.35 : 0.0
            }
            previousInterval = heartRateTime.timeIntervalSince(energyTimeData[i])
        }

        return (previousInterval >= 900) ? 0.35 : 0.0
    }

    private static func heartRateJumps(heartRateData: Array<Int>.SubSequence) -> Double
    {
        guard let max = heartRateData.max(),
              let min = heartRateData.min() else
        {
            return 0.0
        }

        return max - min < 3 ? 0.45 : 0.0
    }

    private static func isPulseIntervalLessThanAverage(heartRateData: Array<Int>.SubSequence, meanHeartRate: Double) -> Double
    {
        return (heartRateData.reduce(0.0) { $0 + Double($1) } / 4.0) < meanHeartRate ? 0.2 : 0.0
    }

    private static func isDifferenceBiggerThan20Percents(measurings: Array<Int>.SubSequence) -> Bool
    {
        let stack1 = measurings[...(measurings.startIndex + 3)], stack2 = measurings[(measurings.startIndex + 3)...]
        guard let min = stack1.min(),
              let max = stack2.max() else
        {
            return false
        }
        return Double(max - min) / Double(min) >= 0.2 ? true : false
    }

    // MARK: Phases chart points

    private static func getChartPoint(condition: Condition, verdictCoefficient: Double, meanHeartRate: Double) -> Double
    {
        switch condition
        {
        case .awake:
            return self.getAwakeChartPoint(verdictCoefficient: verdictCoefficient, meanHeartRate: meanHeartRate)
        case .light:
            return self.getLightChartPoint(verdictCoefficient: verdictCoefficient, meanHeartRate: meanHeartRate)
        case .deep:
            return self.getDeepChartPoint(verdictCoefficient: verdictCoefficient, meanHeartRate: meanHeartRate)
        }
    }

    private static func getAwakeChartPoint(verdictCoefficient _: Double, meanHeartRate _: Double) -> Double
    {
        return 1.1
    }

    private static func getLightChartPoint(verdictCoefficient: Double, meanHeartRate: Double) -> Double
    {
        let tmp = 1 - verdictCoefficient
        if self.doubleEqual(tmp, 1)
        {
            return 0.75 + (meanHeartRate.truncatingRemainder(dividingBy: 10) / 100)
        }
        else if self.doubleEqual(tmp, 0.8)
        {
            return 0.7 + (meanHeartRate.truncatingRemainder(dividingBy: 10) / 100)
        }
        else if self.doubleEqual(tmp, 0.65)
        {
            return 0.65 + (meanHeartRate.truncatingRemainder(dividingBy: 10) / 100)
        }
        else if self.doubleEqual(tmp, 0.55)
        {
            return 0.55 + (meanHeartRate.truncatingRemainder(dividingBy: 10) / 100)
        }
        return 0.0
    }

    private static func getDeepChartPoint(verdictCoefficient: Double, meanHeartRate: Double) -> Double
    {
        let tmp = 1 - verdictCoefficient
        if self.doubleEqual(tmp, 0)
        {
            return 0.15 + (meanHeartRate.truncatingRemainder(dividingBy: 10) / 100)
        }
        else if self.doubleEqual(tmp, 0.2)
        {
            return 0.2 + (meanHeartRate.truncatingRemainder(dividingBy: 10) / 100)
        }
        else if self.doubleEqual(tmp, 0.35)
        {
            return 0.25 + (meanHeartRate.truncatingRemainder(dividingBy: 10) / 100)
        }
        else if self.doubleEqual(tmp, 0.45)
        {
            return 0.35 + (meanHeartRate.truncatingRemainder(dividingBy: 10) / 100)
        }
        return 0.0
    }

    // MARK: Data handlers

    private static func getPulseData(heartSamples: [HKSample]?) -> ([Date], [Int], Double?)
    {
        guard let heartSamples = heartSamples as? [HKQuantitySample] else
        {
            return ([], [], nil)
        }

        let heartRateData = heartSamples.map { Int($0.quantity.doubleValue(for: HKUnit(from: "count/min"))) }

        return (
            heartSamples.map { $0.startDate },
            heartRateData,
            (heartRateData.reduce(0.0) { $0 + Double($1) }) / Double(heartRateData.count)
        )
    }

    private static func getEnergyData(energySamples: [HKSample]?) -> ([Date], [Double])
    {
        guard let energySamples = energySamples as? [HKQuantitySample] else
        {
            return ([], [])
        }

        return (
            energySamples.map { $0.startDate },
            energySamples.map { $0.quantity.doubleValue(for: HKUnit.kilocalorie()) }
        )
    }

    // MARK: Auxiliary functions

    private static func doubleEqual(_ a: Double, _ b: Double) -> Bool
    {
        return fabs(a - b) < Double.ulpOfOne
    }
}

import Foundation
import HealthKit

public protocol HKDetectionProvider {

    func retrieveData(completionHandler: @escaping (Sleep?) -> Void)

}

public class HKSleepAppleDetectionProvider: HKDetectionProvider {

    let hkService: HKService?

    // MARK: - Init

    public init(hkService: HKService) {
        self.hkService = hkService
    }

    // MARK: - Public methods

    public func retrieveData(completionHandler: @escaping (Sleep?) -> Void) {
        // считываем все данные здоровья, например, за трое суток
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -3, to: endDate)!

        let interval = DateInterval(start: startDate, end: endDate)

        // TODO: это все исполняется в бекграунд потоках, нам нужно в главном + параллельно.
        // TODO: Переделать этот момент, ибо heart, energy исполняются относительно долго
        hkService?.readData(type: .asleep, interval: interval, completionHandler: { query1, asleepRaw, error1 in
            self.hkService?.readData(type: .heart, interval: interval, completionHandler: { query2, heartRaw, error2 in
                self.hkService?.readData(type: .energy, interval: interval, completionHandler: { query3, energyRaw, error3 in
                    self.hkService?.readData(type: .inbed, interval: interval, completionHandler: { query4, inBedRaw, error4 in
                        if error1 != nil || error2 != nil || error3 != nil || error4 != nil {
                            completionHandler(nil)
                            return
                        }

                        // иногда inbed или asleep может не быть - пытаемся обыграть эти кейсы
                        if (inBedRaw ?? []).isEmpty && (asleepRaw ?? []).isEmpty {
                            completionHandler(nil)
                            return
                        }

                        let sleepData = self.detectSleep(inbedSamplesRaw: ((inBedRaw ?? []).isEmpty && !(asleepRaw ?? []).isEmpty) ? asleepRaw : inBedRaw,
                                                         asleepSamplesRaw: ((asleepRaw ?? []).isEmpty && !(inBedRaw ?? []).isEmpty) ? inBedRaw : asleepRaw,
                                                         heartSamplesRaw: heartRaw,
                                                         energySamplesRaw: energyRaw)

                        if sleepData.error {
                            completionHandler(nil)
                            return
                        }

                        guard let asleepInterval = sleepData.asleepInterval else {
                            completionHandler(nil)
                            return
                        }

                        guard let inbedInterval = sleepData.inbedInterval else {
                            completionHandler(nil)
                            return
                        }

                        let sleep =  Sleep(sleepInterval: asleepInterval,
                                           inBedInterval: inbedInterval,
                                           inBedSamples: sleepData.inBedSamples,
                                           asleepSamples: sleepData.asleepSamples,
                                           heartSamples: sleepData.heartSamples,
                                           energySamples: sleepData.energySamples,
                                           phases: nil)

                        let phases = self.detectPhases(sleep: sleep)

                        sleep.phases = phases

                        completionHandler(sleep)
                    })
                })
            })
        })
    }

    // MARK: - Private methods

    private func detectSleep(inbedSamplesRaw: [HKSample]?,
                             asleepSamplesRaw: [HKSample]?,
                             heartSamplesRaw: [HKSample]?,
                             energySamplesRaw: [HKSample]?) -> (asleepInterval: DateInterval?,
                                                                inbedInterval: DateInterval?,
                                                                inBedSamples: [HKSample]?,
                                                                asleepSamples: [HKSample]?,
                                                                heartSamples: [HKSample]?,
                                                                energySamples: [HKSample]?,
                                                                error: Bool) {

        // минимальные требования для определения
        guard let asleepSamplesRaw = asleepSamplesRaw, let inbedSamplesRaw = inbedSamplesRaw else {
            return (nil, nil, nil, nil, nil, nil, true)
        }

        // Cюда будем складывать сэмплы исключительно последнего сна/времяпрепровождения в кровати.
        // Будем считать,что две смежные записи считаются сном/временем в кровати если между ними разница <25 мин
        var asleepSamples: [HKCategorySample] = []
        var inBedSamples: [HKCategorySample] = []

        // время начала предыдущего сэмпла  (должны сравнивать с датой конца след сэмпла (тк идем в прошлое) и следить, чтоб разница < 25 мин
        guard let firstAsleep = asleepSamplesRaw.first as? HKCategorySample else {
            return (nil, nil, nil, nil, nil, nil, true)
        }

        let startDateBeforeAsleep: Date = firstAsleep.startDate

        guard let firstInbed = inbedSamplesRaw.first as? HKCategorySample else {
            return (nil, nil, nil, nil, nil, nil, true)
        }

        let startDateBeforeInbed: Date = firstInbed.startDate

        // идем от самого нового сэмпла к старым (двигаемся в прошлое)
        for item in asleepSamplesRaw {
            if let sample = item as? HKCategorySample {
                if sample.sourceRevision.source.bundleIdentifier.hasPrefix("com.apple") {
                    if item == firstAsleep {
                        asleepSamples.append(sample)
                    } else {
                        if asleepSamples.last?.endDate.minutes(from: startDateBeforeAsleep) ?? Int.max <= 25 {
                            // все еще наш сон, пополняем массив новым сэмплом
                            asleepSamples.append(sample)
                        } else { break }
                    }
                }
            }
        }

        for item in inbedSamplesRaw {
            if let sample = item as? HKCategorySample {
                if sample.sourceRevision.source.bundleIdentifier.hasPrefix("com.apple") {
                    if item == firstInbed {
                        inBedSamples.append(sample)
                    } else {
                        if inBedSamples.last?.endDate.minutes(from: startDateBeforeInbed) ?? Int.max <= 25 {
                            // все еще наш сон, пополняем массив новым сэмплом
                            inBedSamples.append(sample)
                        } else { break }
                    }
                }
            }
        }

        if inBedSamples.isEmpty || asleepSamples.isEmpty {
            return (nil, nil, nil, nil, nil, nil, true)
        }

        assert(!inBedSamples.isEmpty, "InBed Samples should not be empty")
        assert(!asleepSamples.isEmpty, "Asleep Samples should not be empty")

        // итоговый интервал сна/времяпрепровождения в кровати
        let asleepInterval = DateInterval(start: asleepSamples.last!.startDate, end: asleepSamples.first!.endDate)
        let inbedInterval = DateInterval(start: inBedSamples.last!.startDate, end: inBedSamples.first!.endDate)

        // может такое случиться, что часы заряжались => за прошлую ночь asleep сэмплы отсутствуют (а inbed есть),
        // тогда asleep вытащятся за позапрошлые сутки (последние сэмплы asleep) и это будут разные промежутки у inbed и asleep
        // или наоборот
        if !inbedInterval.intersects(asleepInterval) {
            return (nil, nil, nil, nil, nil, nil, true)
        }

        // остается отфильтровать сердце, энергию, чтоб оно было внутри сна
        let heartSamples = heartSamplesRaw?.filter { asleepInterval.intersects(DateInterval(start: $0.startDate, end: $0.endDate)) }
        let energySamples = energySamplesRaw?.filter { asleepInterval.intersects(DateInterval(start: $0.startDate, end: $0.endDate)) }
        
        return (asleepInterval, inbedInterval, inBedSamples, asleepSamples, heartSamples, energySamples, false)
    }

    private func detectPhases(sleep: Sleep) -> [Phase]? {
        // TODO: - Implement detect phases algo
        return []
    }

}

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

        getRawData(interval: interval) { _, asleepRaw, error1, _, heartRaw, error2, _, energyRaw, error3, _, inBedRaw, error4 in
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

            self.saveSleep(sleep: sleep, completionHandler: { result, error in
                print("new sleep saved")
                // TODO: handle error if so
            })

            completionHandler(sleep)
        }
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

        var startDateBeforeAsleep: Date = firstAsleep.startDate

        guard let firstInbed = inbedSamplesRaw.first as? HKCategorySample else {
            return (nil, nil, nil, nil, nil, nil, true)
        }

        var startDateBeforeInbed: Date = firstInbed.startDate

        // идем от самого нового сэмпла к старым (двигаемся в прошлое)
        for item in asleepSamplesRaw {
            if let sample = item as? HKCategorySample {
                if sample == firstAsleep {
                    asleepSamples.append(sample)
                } else {
                    if sample.endDate.minutes(from: startDateBeforeAsleep) <= 25 {
                        asleepSamples.append(sample)
                        startDateBeforeAsleep = sample.startDate
                    } else { break }
                }
            }
        }

        for item in inbedSamplesRaw {
            if let sample = item as? HKCategorySample {
                if sample == firstInbed {
                    inBedSamples.append(sample)
                } else {
                    if sample.endDate.minutes(from: startDateBeforeInbed) <= 25 {
                        inBedSamples.append(sample)
                        startDateBeforeInbed = sample.startDate
                    } else { break }
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

    /// Func that gets all raw data samples for provider to star analysis
    /// - Parameters:
    ///   - interval: date interval for samples to extract from
    ///   - completion: result with samples and errors if so occured
    func getRawData(interval: DateInterval, completion: @escaping((HKSampleQuery?, [HKSample]?, Error?, // asleep
                                                                   HKSampleQuery?, [HKSample]?, Error?, // heart
                                                                   HKSampleQuery?, [HKSample]?, Error?, // energy
                                                                   HKSampleQuery?, [HKSample]?, Error?) // inbed
                                                                  -> Void)) {
        var query1: HKSampleQuery?
        var samples1: [HKSample]?
        var error1: Error?

        var query2: HKSampleQuery?
        var samples2: [HKSample]?
        var error2: Error?

        var query3: HKSampleQuery?
        var samples3: [HKSample]?
        var error3: Error?

        var query4: HKSampleQuery?
        var samples4: [HKSample]?
        var error4: Error?

        let group = DispatchGroup()

        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            self.hkService?.readData(type: .asleep, interval: interval, bundlePrefixes: ["com.apple"], completionHandler: { query, samplesRaw, error in
                query1 = query
                samples1 = samplesRaw
                error1 = error

                group.leave()
            })
        }

        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            self.hkService?.readData(type: .heart, interval: interval, completionHandler: { query, samplesRaw, error in
                query2 = query
                samples2 = samplesRaw
                error2 = error

                group.leave()
            })
        }

        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            self.hkService?.readData(type: .energy, interval: interval, completionHandler: { query, samplesRaw, error in
                query3 = query
                samples3 = samplesRaw
                error3 = error

                group.leave()
            })
        }

        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            self.hkService?.readData(type: .inbed, interval: interval, bundlePrefixes: ["com.apple"], completionHandler: { query, samplesRaw, error in
                query4 = query
                samples4 = samplesRaw
                error4 = error

                group.leave()
            })
        }

        group.notify(queue: .global(qos: .default)) {
            completion(query1, samples1, error1,
                       query2, samples2, error2,
                       query3, samples3, error3,
                       query4, samples4, error4)
        }

    }

    /// Saves sleep analysis as inBed & Asleep samples in HealthStore
    /// - Parameters:
    ///   - sleep: sleep object to be saved
    ///   - completionHandler: completion with success or failure of this operation
    func saveSleep(sleep: Sleep, completionHandler: @escaping (Bool, Error?) -> Void) {
        // checking sleep analysis existence
        self.hkService?.readData(type: .asleep, interval: sleep.sleepInterval, bundlePrefixes: ["com.benmustafa", "com.sinapsis"], completionHandler: { _, samples, _ in
            guard let samples = samples, samples.isEmpty else {
                return
            }
            
            if let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
                let asleepSample = HKCategorySample(type: sleepType,
                                                    value: HKCategoryValueSleepAnalysis.asleep.rawValue,
                                                    start: sleep.sleepInterval.start,
                                                    end: sleep.sleepInterval.end)

                let inBedSample = HKCategorySample(type: sleepType,
                                                   value: HKCategoryValueSleepAnalysis.inBed.rawValue,
                                                   start: sleep.inBedInterval.start,
                                                   end: sleep.inBedInterval.end)

                self.hkService?.writeData(objects: [asleepSample, inBedSample], type: .asleep, completionHandler: completionHandler)
            }
        })
    }

}

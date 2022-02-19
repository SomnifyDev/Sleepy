// Copyright (c) 2022 Sleepy.

import HealthKit
import UIKit

public protocol HKDetectionProvider {
    func retrieveData(completionHandler: @escaping (Sleep?) -> Void)
}

public class HKSleepAppleDetectionProvider: HKDetectionProvider {
    public enum Constants {
        // допустимая погрешность разницы между сэмплами, чтоб не считать это пробуждением
        public static let minimalSimilarMicroSleepSamplesDifference = 15

        // максимально допустимое время пробуждения, чтобы продолжать считать это одним сном в рамках приложения
        public static let maximalSleepDifference = 45

        // минимальная длительность микро сна
        public static let minimalMicroSleepDuration = 30
    }

    private let hkService: HKService?
    private let notificationCenter = UNUserNotificationCenter.current()
    private let lock = NSLock()

    // MARK: - Init

    public init(hkService: HKService) {
        self.hkService = hkService
    }

    // MARK: - Public methods

    /// Сохраняет микросон в базу данных healthKit
    /// - Parameters:
    ///   - sleep: микросон, который хотим сохранить
    ///   - completionHandler: completionHandler
    public func saveMicroSleep(microSleep: MicroSleep, completionHandler: @escaping (Bool, Error?) -> Void) {
        let expandedIntervalStart = Calendar.current.date(byAdding: .minute, value: -5, to: microSleep.inBedInterval.start)!
        let expandedIntervalEnd = Calendar.current.date(byAdding: .minute, value: 5, to: microSleep.inBedInterval.end)!
        let expandedInterval = DateInterval(start: expandedIntervalStart, end: expandedIntervalEnd)
        self.hkService?.readData(type: .asleep, interval: expandedInterval, bundleAuthor: .sleepy, completionHandler: { _, samples, _ in
            // данной проверкой убеждаемся, что в данном интервале не было сохранено сна ранее, чтоб не сохранять дубли
            guard let samples = samples, samples.isEmpty,
                  let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)
            else {
                completionHandler(false, nil)
                return
            }

            var metadata: [String: Any] = [:]
            let phases = microSleep.phases.flatMap { $0 }

            let heartRates = phases?.flatMap { $0.heartData }
            let energyRates = phases?.flatMap { $0.energyData }
            let breathRates = phases?.flatMap { $0.breathData }

            let heartValues = heartRates?.compactMap { $0.value } ?? []
            let energyValues = energyRates?.compactMap { $0.value } ?? []
            let breathValues = breathRates?.compactMap { $0.value } ?? []

            let meanHeartRate = (heartValues.reduce(0.0, +)) / Double(heartValues.count)
            let energyConsumption = energyValues.reduce(0.0, +)
            let meanBreathRate = (breathValues.reduce(0.0, +)) / Double(breathValues.count)

            metadata["Heart rate mean"] = String(format: "%.3f", meanHeartRate)
            metadata["Energy consumption"] = String(format: "%.3f", energyConsumption)
            metadata["Respiratory rate"] = String(format: "%.3f", meanBreathRate)

            let asleepSample = HKCategorySample(
                type: sleepType,
                value: HKCategoryValueSleepAnalysis.asleep.rawValue,
                start: microSleep.sleepInterval.start,
                end: microSleep.sleepInterval.end,
                metadata: metadata
            )

            let inBedSample = HKCategorySample(
                type: sleepType,
                value: HKCategoryValueSleepAnalysis.inBed.rawValue,
                start: microSleep.inBedInterval.start,
                end: microSleep.inBedInterval.end
            )

            self.hkService?.writeData(objects: [asleepSample, inBedSample], type: .asleep, completionHandler: completionHandler)
        })
    }

    /// Основная функция анализа сна в приложении. Считываем сэмплы здоровья за последние 3 дня,
    ///
    ///  Идет с конца (с настоящего в  прошлое) и пытается вытащить последний сон (ориентируясь на сэмплы сна от Apple)
    ///  Так как сами эпловские сэмплы выгружаются в виде нескольких записей (*) (не одной, которая бы могла характеризовать сон в целом)
    ///  так, что нативного способа понять рамки последнего сна не имеем, поэтому пытаемся оперировать собственной логикой, что
    ///  - Сон является сном если его длительность 30 минут
    ///  - Сон является сном если его разница от прошлой сессии сна - более 45 минут
    ///  - Микросны (разбиение сна на отдельные части из-за недлительных пробуждений) это составляющие любого сна, разница между которыми не менее 15 минут,
    ///  - Микросон не может быть меньше 30 минут, иначе принимаем это за ошибку
    ///  иначе не считаем это пробуждением
    ///
    /// Из-за (*)  логика выгрузки эпла подвержена следующим багам или непонятным пока механикам
    ///  - Иногда Apple'овский анализ сна может не выгрузить любой из типов сэмплов вообще (inbed / asleep)
    ///  - Иногда inbed сэмпл может ошибиться на пару часов (какая-то их внутренняя ошибка, когда часы продолжают засчитыаать лежание в постели при бодрствовании)
    ///  - Иногда сэмплы могут быть выгружены в разное время (не синхронно), из-за чего Sleepy при первой выгрузке может получить не всю инфу =>  предоставить некорректный анализ
    ///  - Иногда может быть выгружены сэмплы, словно человек спал минуту и подобное (какой-то рандомный ошибочный шум)
    ///  ** to be continued **
    ///
    /// - Parameter completionHandler: completionHandler
    public func retrieveData(completionHandler: @escaping (Sleep?) -> Void) {
        self.lock.lock()

        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -3, to: endDate)!

        let interval = DateInterval(start: startDate, end: endDate)

        self.getRawData(interval: interval) { asleepRaw, error1, heartRaw, error2, energyRaw, error3, inBedRaw, error4, respiratoryRaw, _ in
            // иногда inbed или asleep может не быть - пытаемся обыграть эти кейсы
            if error1 != nil ||
                error2 != nil ||
                error3 != nil ||
                error4 != nil ||
                (inBedRaw ?? []).isEmpty, (asleepRaw ?? []).isEmpty
            {
                completionHandler(nil)
                self.lock.unlock()
                return
            }

            var lastMicroSleepStart = endDate

            var inBedRawFiltered = inBedRaw
            var asleepRawFiltered = asleepRaw
            var heartRawFiltered = heartRaw
            var energyRawFiltered = energyRaw
            var respiratoryRawFiltered = respiratoryRaw

            let sleep = Sleep(samples: [])
            var shouldNotifyAnalysisByPush = true
            var isFirstFetch = true
            // идем в прошлое, отсекая справа уже просчитанный сон, в надежде найти еще один/несколько снов (вдруг человек просыпался)
            while true {
                inBedRawFiltered = inBedRawFiltered?.filter { $0.endDate <= lastMicroSleepStart }
                asleepRawFiltered = asleepRawFiltered?.filter { $0.endDate <= lastMicroSleepStart }
                heartRawFiltered = heartRawFiltered?.filter { $0.endDate <= lastMicroSleepStart }
                energyRawFiltered = energyRawFiltered?.filter { $0.endDate <= lastMicroSleepStart }
                respiratoryRawFiltered = respiratoryRawFiltered?.filter { $0.endDate <= lastMicroSleepStart }

                // запускаем функцию определения последнего микросна сна для отфильтрованных сэмплов
                let sleepData = self.detectSleep(
                    inbedSamplesRaw: ((inBedRawFiltered ?? []).isEmpty && !(asleepRawFiltered ?? []).isEmpty) ? asleepRawFiltered : inBedRawFiltered,
                    asleepSamplesRaw: ((asleepRawFiltered ?? []).isEmpty && !(inBedRawFiltered ?? []).isEmpty) ? inBedRawFiltered : asleepRawFiltered,
                    heartSamplesRaw: heartRawFiltered,
                    energySamplesRaw: energyRawFiltered,
                    respiratoryRaw: respiratoryRawFiltered,
                    isFirstFetch: isFirstFetch
                )

                // если нет ошибок и обнаруженный сон имеет промежуток с другим,
                // обнаруженным ранее, в <= заданная константа, то считаем это одним сном
                guard !sleepData.error,
                      let asleepInterval = sleepData.asleepInterval,
                      abs(asleepInterval.end.minutes(from: lastMicroSleepStart)) <= Constants.maximalSleepDifference
                      || lastMicroSleepStart == endDate
                      || sleep.samples.isEmpty,
                      let inbedInterval = sleepData.inbedInterval,
                      let energySamples = sleepData.energySamples,
                      let heartSamples = sleepData.heartSamples,
                      let respiratorySamples = sleepData.respiratorySamples
                else {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        let state = UIApplication.shared.applicationState
                        let group = DispatchGroup()

                        sleep.samples.forEach {
                            group.enter()

                            self.saveMicroSleep(microSleep: $0, completionHandler: { [weak self] isAlreadySaved, error in
                                guard error == nil || isAlreadySaved else {
                                    shouldNotifyAnalysisByPush = false
                                    completionHandler(nil)
                                    self?.lock.unlock()
                                    return
                                }
                                group.leave()
                            })
                        }

                        group.notify(queue: .global(qos: .default)) {
                            if let sleepInterval = sleep.sleepInterval,
                               state == .background || state == .inactive,
                               shouldNotifyAnalysisByPush
                            {
                                self.notifyByPush(title: "New sleep analysis", body: sleepInterval.stringFromDateInterval(type: .time))
                            }
                        }
                    }

                    completionHandler(!sleep.samples.isEmpty ? sleep : nil)
                    self.lock.unlock()
                    return
                }

                lastMicroSleepStart = asleepInterval.start

                // если микро сон оказался слишком маленьким по времени - пропускаем его
                if inbedInterval.duration / 60.0 < Double(Constants.minimalMicroSleepDuration) {
                    continue
                }

                // определяем фазы на получившимся отрезке
                let phases = PhasesComputationService.computatePhases(
                    energySamples: energySamples,
                    heartSamples: heartSamples,
                    breathSamples: respiratorySamples,
                    sleepInterval: asleepInterval
                )

                let microSleep = MicroSleep(
                    sleepInterval: asleepInterval,
                    inBedInterval: inbedInterval,
                    phases: phases
                )

                sleep.samples.append(microSleep)
                isFirstFetch = false
            }
        }
    }

    /// Функция для определения сна по эпловским сэмплам.
    ///  См. описание функции retrieveData
    private func detectSleep(
        inbedSamplesRaw: [HKSample]?,
        asleepSamplesRaw: [HKSample]?,
        heartSamplesRaw: [HKSample]?,
        energySamplesRaw: [HKSample]?,
        respiratoryRaw: [HKSample]?,
        isFirstFetch: Bool
    ) -> (
        asleepInterval: DateInterval?,
        inbedInterval: DateInterval?,
        inBedSamples: [HKSample]?,
        asleepSamples: [HKSample]?,
        heartSamples: [HKSample]?,
        energySamples: [HKSample]?,
        respiratorySamples: [HKSample]?,
        error: Bool
    ) {
        guard let asleepSamplesRaw = asleepSamplesRaw,
              let inbedSamplesRaw = inbedSamplesRaw,
              let firstAsleep = asleepSamplesRaw.first as? HKCategorySample,
              let firstInbed = inbedSamplesRaw.first as? HKCategorySample
        else {
            return (nil, nil, nil, nil, nil, nil, nil, true)
        }
        var startDateBeforeInbed: Date = firstInbed.startDate
        var startDateBeforeAsleep: Date = firstAsleep.startDate

        var asleepSamples: [HKCategorySample] = []
        var inBedSamples: [HKCategorySample] = []

        for item in asleepSamplesRaw {
            if let sample = item as? HKCategorySample {
                if sample == firstAsleep {
                    asleepSamples.append(sample)
                } else {
                    if sample.endDate.minutes(from: startDateBeforeAsleep) <= Constants.minimalSimilarMicroSleepSamplesDifference {
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
                    if sample.endDate.minutes(from: startDateBeforeInbed) <= Constants.minimalSimilarMicroSleepSamplesDifference {
                        inBedSamples.append(sample)
                        startDateBeforeInbed = sample.startDate
                    } else { break }
                }
            }
        }

        if inBedSamples.isEmpty, asleepSamples.isEmpty {
            return (nil, nil, nil, nil, nil, nil, nil, true)
        } else if inBedSamples.isEmpty {
            inBedSamples = asleepSamples
        } else if asleepSamples.isEmpty {
            asleepSamples = inBedSamples
        }

        // итоговый интервал сна/времяпрепровождения в кровати
        var asleepInterval = DateInterval(start: asleepSamples.last!.startDate, end: asleepSamples.first!.endDate)
        var inbedInterval = DateInterval(start: inBedSamples.last!.startDate, end: inBedSamples.first!.endDate)

        // может такое случиться, что часы заряжались => за прошлую ночь asleep сэмплы отсутствуют (а inbed есть),
        // тогда asleep вытащятся за позапрошлые сутки (последние сэмплы asleep) и это будут разные промежутки у inbed и asleep
        // или наоборот есть только asleep сэмплы (такой баг случается если встаешь раньше будильника)
        if !inbedInterval.intersects(asleepInterval), isFirstFetch {
            // если действительно произошел такой кейс
            if inbedInterval.end > asleepInterval.end {
                asleepSamples = inBedSamples
                asleepInterval = DateInterval(start: asleepSamples.last!.startDate, end: asleepSamples.first!.endDate)
            } else {
                inBedSamples = asleepSamples
                inbedInterval = DateInterval(start: inBedSamples.last!.startDate, end: inBedSamples.first!.endDate)
            }
        }

        // может такое случиться, что inbed конец по времени будет раньше конца asleep
        // словно человек встал с кровати раньше чем проснулся
        // Пытаемся пофиксить данный случай
        if inbedInterval.end < asleepInterval.end {
            inbedInterval.end = asleepInterval.end
        }

        let heartSamples = heartSamplesRaw?.filter { asleepInterval.intersects(DateInterval(start: $0.startDate, end: $0.endDate)) }
        let energySamples = energySamplesRaw?.filter { asleepInterval.intersects(DateInterval(start: $0.startDate, end: $0.endDate)) }
        let respiratorySamples = respiratoryRaw?.filter { asleepInterval.intersects(DateInterval(start: $0.startDate, end: $0.endDate)) }

        return (asleepInterval, inbedInterval, inBedSamples, asleepSamples, heartSamples, energySamples, respiratorySamples, false)
    }

    /// Функция для слежения за изменениями хранилища HealthStore для типов inbed asleep здоровья (сигнализирующих о появлении нового сна)
    /// - Parameters:
    ///   - observeHandler: result that contains boolean value indicating if enabled state and error if it occured during func work
    public func observeData() {
        let startDate = Calendar.current.date(byAdding: .day, value: -2, to: Date())
        let sampleDataPredicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: Date.distantFuture,
            options: []
        )

        let queryPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [sampleDataPredicate])

        for type in [HKSampleType.categoryType(forIdentifier: .sleepAnalysis)!] {
            // swiftformat:disable:next all
            let query = HKObserverQuery(sampleType: type, predicate: queryPredicate) { [weak self] _, completionHandler, errorOrNil in
                DispatchQueue.main.sync {
                    let state = UIApplication.shared.applicationState

                    guard state == .background, errorOrNil == nil
                    else {
                        completionHandler()
                        return
                    }

                    self?.hkService?.readDataLast(type: .inbed, completionHandler: { _, samples, error in
                        guard error == nil, let samples = samples, !samples.isEmpty
                        else {
                            completionHandler()
                            return
                        }

                        if samples.first!.sourceRevision.source.bundleIdentifier.hasPrefix("com.apple") {
                            self?.retrieveData(completionHandler: { _ in
                                completionHandler()
                            })
                        } else {
                            completionHandler()
                            return
                        }
                    })
                }
            }

            // Run the query.
            HKService.healthStore.execute(query)
        }
    }

    // MARK: - Private methods

    private func notifyByPush(title: String, body: String) {
        // TODO: вынести нотификации в отдельную сущность
        let content = UNMutableNotificationContent() // Содержимое уведомления
        let categoryIdentifier = "Delete Notification Type"

        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.badge = 1
        content.categoryIdentifier = categoryIdentifier

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 15 * 60, repeats: false)
        let identifier = "Sleepy Notification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        self.notificationCenter.add(request) { error in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }

        let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
        let deleteAction = UNNotificationAction(identifier: "DeleteAction", title: "Delete", options: [.destructive])
        let category = UNNotificationCategory(
            identifier: categoryIdentifier,
            actions: [snoozeAction, deleteAction],
            intentIdentifiers: [],
            options: []
        )

        self.notificationCenter.setNotificationCategories([category])
    }

    /// Func that gets all raw data samples for provider to star analysis
    /// - Parameters:
    ///   - interval: date interval for samples to extract from
    ///   - completion: result with samples and errors if so occured
    private func getRawData(interval: DateInterval, completion: @escaping (
        (
            [HKSample]?,
            Error?, // asleep
            [HKSample]?,
            Error?, // heart
            [HKSample]?,
            Error?, // energy
            [HKSample]?,
            Error?, // inbed
            [HKSample]?,
            Error?
        ) // respiratory
            -> Void
    )) {
        var samples1: [HKSample]?
        var error1: Error?

        var samples2: [HKSample]?
        var error2: Error?

        var samples3: [HKSample]?
        var error3: Error?

        var samples4: [HKSample]?
        var error4: Error?

        var samples5: [HKSample]?
        var error5: Error?

        let group = DispatchGroup()

        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            self.hkService?.readData(type: .asleep, interval: interval, bundleAuthor: .apple, completionHandler: { _, samplesRaw, error in
                samples1 = samplesRaw
                error1 = error

                group.leave()
            })
        }

        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            self.hkService?.readData(type: .heart, interval: interval, bundleAuthor: .apple, completionHandler: { _, samplesRaw, error in
                samples2 = samplesRaw
                error2 = error

                group.leave()
            })
        }

        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            self.hkService?.readData(type: .energy, interval: interval, bundleAuthor: .apple, completionHandler: { _, samplesRaw, error in
                samples3 = samplesRaw
                error3 = error

                group.leave()
            })
        }

        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            self.hkService?.readData(type: .inbed, interval: interval, bundleAuthor: .apple, completionHandler: { _, samplesRaw, error in
                samples4 = samplesRaw
                error4 = error

                group.leave()
            })
        }

        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            self.hkService?.readData(type: .respiratory, interval: interval, bundleAuthor: .apple, completionHandler: { _, samplesRaw, error in
                samples5 = samplesRaw
                error5 = error

                group.leave()
            })
        }

        group.notify(queue: .global(qos: .default)) {
            completion(
                samples1,
                error1,
                samples2,
                error2,
                samples3,
                error3,
                samples4,
                error4,
                samples5,
                error5
            )
        }
    }
}

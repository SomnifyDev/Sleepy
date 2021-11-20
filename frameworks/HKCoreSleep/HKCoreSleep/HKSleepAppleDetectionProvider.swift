// Copyright (c) 2021 Sleepy.

import HealthKit
import UIKit

public protocol HKDetectionProvider {
	func retrieveData(completionHandler: @escaping (Sleep?) -> Void)
}

public class HKSleepAppleDetectionProvider: HKDetectionProvider {
	private let hkService: HKService?
	private let notificationCenter = UNUserNotificationCenter.current()
	private let lock = NSLock()

	// MARK: - Init

	public init(hkService: HKService) {
		self.hkService = hkService
	}

	// MARK: - Public methods

	/// Saves sleep analysis as inBed & Asleep samples in HealthStore
	/// - Parameters:
	///   - sleep: sleep object to be saved
	///   - completionHandler: completion with success or failure of this operation
	public func saveSleep(sleep: Sleep, completionHandler: @escaping (Bool, Error?) -> Void) {
		// checking sleep analysis existence

		// lets expand sleep interval a little bit to be 100% while not sure about strict predicate comparsion ( < or <=)
		let expandedIntervalStart = Calendar.current.date(byAdding: .minute, value: -5, to: sleep.inBedInterval.start)!
		let expandedIntervalEnd = Calendar.current.date(byAdding: .minute, value: 5, to: sleep.inBedInterval.end)!
		let expandedInterval = DateInterval(start: expandedIntervalStart, end: expandedIntervalEnd)
		self.hkService?.readData(type: .asleep, interval: expandedInterval, bundlePrefixes: ["com.benmustafa", "com.sinapsis"], completionHandler: { _, samples, _ in
			guard let samples = samples, samples.isEmpty else {
				completionHandler(false, nil)
				return
			}

			if let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
				var metadata: [String: Any] = [:]
				if let phases = sleep.phases {
					let heartRates = phases.flatMap { $0.heartData }
					let energyRates = phases.flatMap { $0.energyData }
					let breathRates = phases.flatMap { $0.breathData }

					let heartValues = heartRates.compactMap { $0.value }
					let energyValues = energyRates.compactMap { $0.value }
					let breathValues = breathRates.compactMap { $0.value }

					let meanHeartRate = (heartValues.reduce(0.0, +)) / Double(heartValues.count)
					let meanEnergyRate = (energyValues.reduce(0.0, +)) / Double(energyValues.count)
					let meanBreathRate = (breathValues.reduce(0.0, +)) / Double(breathValues.count)

					metadata["Heart rate mean"] = String(format: "%.3f", meanHeartRate)
					metadata["Energy consumption"] = String(format: "%.3f", meanEnergyRate)
					metadata["Respiratory rate"] = String(format: "%.3f", meanBreathRate)
				}

				let asleepSample = HKCategorySample(type: sleepType,
				                                    value: HKCategoryValueSleepAnalysis.asleep.rawValue,
				                                    start: sleep.sleepInterval.start,
				                                    end: sleep.sleepInterval.end)

				let inBedSample = HKCategorySample(type: sleepType,
				                                   value: HKCategoryValueSleepAnalysis.inBed.rawValue,
				                                   start: sleep.inBedInterval.start,
				                                   end: sleep.inBedInterval.end,
				                                   metadata: metadata)

				self.hkService?.writeData(objects: [asleepSample, inBedSample], type: .asleep, completionHandler: completionHandler)
			}
		})
	}

	public func retrieveData(completionHandler: @escaping (Sleep?) -> Void) {
		// async stuff
		// acquire the lock
		self.lock.lock()
		// считываем все данные здоровья, например, за трое суток
		let endDate = Date()
		let startDate = Calendar.current.date(byAdding: .day, value: -3, to: endDate)!

		let interval = DateInterval(start: startDate, end: endDate)

		self.getRawData(interval: interval) { _, asleepRaw, error1, _, heartRaw, error2, _, energyRaw, error3, _, inBedRaw, error4, _, respiratoryRaw, _ in
			if error1 != nil || error2 != nil || error3 != nil || error4 != nil {
				completionHandler(nil)
				self.lock.unlock()
				return
			}

			// иногда inbed или asleep может не быть - пытаемся обыграть эти кейсы
			if (inBedRaw ?? []).isEmpty, (asleepRaw ?? []).isEmpty {
				completionHandler(nil)
				self.lock.unlock()
				return
			}

			var lastIntervalStart = endDate

			var inBedRawFiltered = inBedRaw
			var asleepRawFiltered = asleepRaw
			var heartRawFiltered = heartRaw
			var energyRawFiltered = energyRaw
			var respiratoryRawFiltered = respiratoryRaw

			var latestSleepWillFetch = true

			while true {
				// идем в прошлое, отсекая справа уже просчитанный сон, в надежде найти еще один/несколько снов (вдруг человек просыпался)
				inBedRawFiltered = inBedRawFiltered?.filter { $0.endDate <= lastIntervalStart }
				asleepRawFiltered = asleepRawFiltered?.filter { $0.endDate <= lastIntervalStart }
				heartRawFiltered = heartRawFiltered?.filter { $0.endDate <= lastIntervalStart }
				energyRawFiltered = energyRawFiltered?.filter { $0.endDate <= lastIntervalStart }
				respiratoryRawFiltered = respiratoryRawFiltered?.filter { $0.endDate <= lastIntervalStart }

				// запускаем функцию определения сна для отфильтрованных сэмплов
				let sleepData = self.detectSleep(inbedSamplesRaw: ((inBedRawFiltered ?? []).isEmpty && !(asleepRawFiltered ?? []).isEmpty) ? asleepRawFiltered : inBedRawFiltered,
				                                 asleepSamplesRaw: ((asleepRawFiltered ?? []).isEmpty && !(inBedRawFiltered ?? []).isEmpty) ? inBedRawFiltered : asleepRawFiltered,
				                                 heartSamplesRaw: heartRawFiltered,
				                                 energySamplesRaw: energyRawFiltered,
				                                 respiratoryRaw: respiratoryRawFiltered)

				// если нет ошибок и обнаруженный сон имеет промежуток с другим, обнаруженным ранее, в <= 60 минут, то считаем это одним сном
				// и идем сохранять его в хранилище
				guard !sleepData.error,
				      let asleepInterval = sleepData.asleepInterval,
				      abs(asleepInterval.end.minutes(from: lastIntervalStart)) <= 60 || lastIntervalStart == endDate,
				      let inbedInterval = sleepData.inbedInterval,
				      let energySamples = sleepData.energySamples,
				      let heartSamples = sleepData.heartSamples,
				      let respiratorySamples = sleepData.respiratorySamples else
				{
					self.lock.unlock()
					return
				}

				lastIntervalStart = asleepInterval.start

				// определяем фазы на получившимся отрезке
				let phases = PhasesComputationService.computatePhases(energySamples: energySamples,
				                                                      heartSamples: heartSamples,
				                                                      breathSamples: respiratorySamples,
				                                                      sleepInterval: asleepInterval)

				let sleep = Sleep(sleepInterval: asleepInterval,
				                  inBedInterval: inbedInterval,
				                  phases: phases)

				// swiftformat:disable:next all
				self.saveSleep(sleep: sleep, completionHandler: { [weak self] success, error in
					guard error == nil else {
						print(error.debugDescription)
						completionHandler(nil)
						self?.lock.unlock()
						return
					}

					DispatchQueue.main.async {
						let state = UIApplication.shared.applicationState
						if state == .background || state == .inactive, success,
						   latestSleepWillFetch
						{
							// чтоб не спамить уведомлениями о каждом найденном отрезке сна, оповестим только о самом свежем
							// background sleep analysis push being delivered in 15 minutes
							self?.notifyByPush(title: "New sleep analysis".localized, body: sleep.sleepInterval.stringFromDateInterval(type: .time))
						}
					}

					// в комплишене возвращаем только самый первый (самый свежий сон), ибо возвращаемое значение передается в UI и используется на экранах
					// а остальные сны мы тихо сохраняем в БД
					if latestSleepWillFetch {
						completionHandler(sleep)
					}
					latestSleepWillFetch = false
				})
			}
		}
	}

	/// Observes the HealthStore for changes in the types we're interested in, e.g, inbed, asleep samples
	/// - Parameters:
	///   - observeHandler: result that contains boolean value indicating if enabled state and error if it occured during func work
	public func observeData() {
		let startDate = Calendar.current.date(byAdding: .day, value: -2, to: Date())
		let sampleDataPredicate = HKQuery.predicateForSamples(withStart: startDate,
		                                                      end: Date.distantFuture,
		                                                      options: [])

		let queryPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [sampleDataPredicate])

		for type in [HKSampleType.categoryType(forIdentifier: .sleepAnalysis)!] {
			// swiftformat:disable:next all
			let query = HKObserverQuery(sampleType: type, predicate: queryPredicate) { [weak self] _, completionHandler, errorOrNil in
				DispatchQueue.main.sync {
					let state = UIApplication.shared.applicationState

					guard state == .background, errorOrNil == nil else {
						completionHandler()
						return
					}

					// Take whatever sleep samples are necessary to update your app.
					// This often involves executing other queries to access the new data.
					// We need to defiene if new samples are from apple
					self?.hkService?.readDataLast(type: .inbed, completionHandler: { _, samples, error in
						guard error == nil, let samples = samples, !samples.isEmpty else {
							completionHandler()
							return
						}

						if samples.first!.sourceRevision.source.bundleIdentifier.hasPrefix("com.apple") {
							self?.retrieveData(completionHandler: { _ in
								// If you have subscribed for background updates you must call the completion handler here.
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
		let category = UNNotificationCategory(identifier: categoryIdentifier,
		                                      actions: [snoozeAction, deleteAction],
		                                      intentIdentifiers: [],
		                                      options: [])

		self.notificationCenter.setNotificationCategories([category])
	}

	private func detectSleep(inbedSamplesRaw: [HKSample]?,
	                         asleepSamplesRaw: [HKSample]?,
	                         heartSamplesRaw: [HKSample]?,
	                         energySamplesRaw: [HKSample]?,
	                         respiratoryRaw: [HKSample]?) -> (asleepInterval: DateInterval?,
	                                                          inbedInterval: DateInterval?,
	                                                          inBedSamples: [HKSample]?,
	                                                          asleepSamples: [HKSample]?,
	                                                          heartSamples: [HKSample]?,
	                                                          energySamples: [HKSample]?,
	                                                          respiratorySamples: [HKSample]?,
	                                                          error: Bool)
	{
		// минимальные требования для определения
		guard let asleepSamplesRaw = asleepSamplesRaw,
		      let inbedSamplesRaw = inbedSamplesRaw,
		      let firstAsleep = asleepSamplesRaw.first as? HKCategorySample,
		      let firstInbed = inbedSamplesRaw.first as? HKCategorySample else
		{
			return (nil, nil, nil, nil, nil, nil, nil, true)
		}

		// время начала предыдущего сэмпла  (должны сравнивать с датой конца след сэмпла (тк идем в прошлое) и следить, чтоб разница < 25 мин
		var startDateBeforeInbed: Date = firstInbed.startDate
		var startDateBeforeAsleep: Date = firstAsleep.startDate

		// Cюда будем складывать сэмплы исключительно последнего сна/времяпрепровождения в кровати.
		// Будем считать,что две смежные записи считаются одним сном/временем в кровати если между ними разница <= 25 мин
		var asleepSamples: [HKCategorySample] = []
		var inBedSamples: [HKCategorySample] = []

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
		if !inbedInterval.intersects(asleepInterval) {
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

		// остается отфильтровать сердце, энергию, чтоб оно было внутри сна
		let heartSamples = heartSamplesRaw?.filter { asleepInterval.intersects(DateInterval(start: $0.startDate, end: $0.endDate)) }
		let energySamples = energySamplesRaw?.filter { asleepInterval.intersects(DateInterval(start: $0.startDate, end: $0.endDate)) }
		let respiratorySamples = respiratoryRaw?.filter { asleepInterval.intersects(DateInterval(start: $0.startDate, end: $0.endDate)) }

		return (asleepInterval, inbedInterval, inBedSamples, asleepSamples, heartSamples, energySamples, respiratorySamples, false)
	}

	/// Func that gets all raw data samples for provider to star analysis
	/// - Parameters:
	///   - interval: date interval for samples to extract from
	///   - completion: result with samples and errors if so occured
	private func getRawData(interval: DateInterval, completion: @escaping ((HKSampleQuery?, [HKSample]?, Error?, // asleep
	                                                                        HKSampleQuery?, [HKSample]?, Error?, // heart
	                                                                        HKSampleQuery?, [HKSample]?, Error?, // energy
	                                                                        HKSampleQuery?, [HKSample]?, Error?, // inbed
	                                                                        HKSampleQuery?, [HKSample]?, Error?) // respiratory
			-> Void))
	{
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

		var query5: HKSampleQuery?
		var samples5: [HKSample]?
		var error5: Error?

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

		group.enter()
		DispatchQueue.global(qos: .userInitiated).async {
			self.hkService?.readData(type: .respiratory, interval: interval, bundlePrefixes: ["com.apple"], completionHandler: { query, samplesRaw, error in
				query5 = query
				samples5 = samplesRaw
				error5 = error

				group.leave()
			})
		}

		group.notify(queue: .global(qos: .default)) {
			completion(query1, samples1, error1,
			           query2, samples2, error2,
			           query3, samples3, error3,
			           query4, samples4, error4,
			           query5, samples5, error5)
		}
	}
}

// Copyright (c) 2021 Sleepy.

//
//  SoundCoordinator.swift
//  Sleepy
//
//  Created by Никита Казанцев on 14.08.2021.
//
import FirebaseAnalytics
import Foundation
import SettingsKit
import SoundAnalysis
import UIComponents
import XUI

class SoundsCoordinator: ObservableObject, ViewModel {
	private unowned let parent: RootCoordinator

	@Published var openedURL: URL?
	@Published var showAnalysis = false
	@Published var showLoading = false

	let resultsObserver = AudioResultsObserver()
	let colorProvider: ColorSchemeProvider

	init(colorSchemeProvider: ColorSchemeProvider, parent: RootCoordinator) {
		self.parent = parent
		self.colorProvider = colorSchemeProvider
	}

	func openSettings() {
		self.parent.openTabView(of: .settings, components: nil)
	}

	func open(_ url: URL) {
		self.openedURL = url
	}
}

extension SoundsCoordinator {
	/// Вызывается в моменте клика по наименованию записи для генерирования анализа (распознавания звуков)
	/// В колбэке получает результат анализа, в случае успеха показывается sheet анализа
	/// Данные для sheet'а берутся из AudioResultsObserver.analysis
	/// - Parameter audioFileURL: путь до файла с записью
	func runAnalysis(audioFileURL: URL) {
		do {
			self.showLoading = true

			let request: SNClassifySoundRequest
			let config = MLModelConfiguration()
			let mlModel = try soundClassifier(configuration: config)

			request = try SNClassifySoundRequest(mlModel: mlModel.model)

			guard let audioFileAnalyzer = createAnalyzer(audioFileURL: audioFileURL) else {
				self.showLoading = false
				return
			}
			self.resultsObserver.fileName = audioFileURL.lastPathComponent
			self.resultsObserver.date = FileHelper.creationDateForLocalFilePath(filePath: audioFileURL.path)
			self.resultsObserver.array = []

			// Prepare a new request for the trained model.
			try audioFileAnalyzer.add(request, withObserver: self.resultsObserver)

			audioFileAnalyzer.analyze(completionHandler: { result in
				DispatchQueue.main.async {
					self.showAnalysis = result
					self.showLoading = false
				}
			})
		} catch {
			self.showLoading = false
		}
	}

	func createAnalyzer(audioFileURL: URL) -> SNAudioFileAnalyzer? {
		return try? SNAudioFileAnalyzer(url: audioFileURL)
	}

	func sendAnalytics() {
		FirebaseAnalytics.Analytics.logEvent("Sounds_viewed", parameters: nil)
	}
}

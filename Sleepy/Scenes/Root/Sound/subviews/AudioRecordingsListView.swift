// Copyright (c) 2021 Sleepy.

import HKVisualKit
import SoundAnalysis
import SwiftUI
import XUI

struct AudioRecordingsListView: View {
	@Store var viewModel: SoundsCoordinator
	@ObservedObject var audioRecorder = AudioRecorder()

	private var groupedByDateData: [Date: [Recording]] {
		Dictionary(grouping: self.audioRecorder.recordings, by: { $0.createdAt.startOfDay })
	}

	var headers: [Date] {
		self.groupedByDateData.map { $0.key }.sorted()
	}

	@State private var showSheetView = false
	@State private var showProgress = false
	// Create a new observer to receive notifications for analysis results.
	let resultsObserver = AudioResultsObserver()

	var body: some View {
		ZStack(alignment: .center) {
			viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.appBackgroundColor))
				.edgesIgnoringSafeArea(.all)

			VStack {
				if audioRecorder.recordings.isEmpty {
					BannerView(bannerViewType: .advice(type: .soundRecording, imageSystemName: "speechAdvice"),
					           colorProvider: viewModel.colorProvider)
						.roundedCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
				} else {
					List {
						ForEach(headers, id: \.self) { header in
							Section(header: Text(header, style: .date)) {
								ForEach(groupedByDateData[header]!) { recording in
									RecordingRow(audioURL: recording.fileURL,
									             colorProvider: viewModel.colorProvider)
										.padding([.top, .bottom, .leading, .trailing], 4)
										.onTapGesture {
											showProgress = true
											runAnalysis(audioFileURL: recording.fileURL)
										}
								}.onDelete { indexSet in
									for index in indexSet {
										try? FileManager.default.removeItem(at: audioRecorder.recordings[index].fileURL)
										self.audioRecorder.fetchRecordings()
									}
								}
							}
						}
					}
				}
				Spacer()
			}.sheet(isPresented: $showSheetView) {
				AnalysisListView(viewModel: self.viewModel,
				                 result: resultsObserver.array,
				                 fileName: resultsObserver.fileName,
				                 endDate: resultsObserver.date,
				                 colorProvider: viewModel.colorProvider,
				                 showSheetView: $showSheetView)
			}

			if showProgress {
				ProgressView().frame(width: 35, height: 35)
					.background(Color.black.opacity(0.3))
					.cornerRadius(6)
					.progressViewStyle(CircularProgressViewStyle())
			}
		}
	}

	private func runAnalysis(audioFileURL: URL) {
		do {
			let request: SNClassifySoundRequest

			let config = MLModelConfiguration()
			let mlModel = try soundClassifier(configuration: config)

			request = try SNClassifySoundRequest(mlModel: mlModel.model)

			guard let audioFileAnalyzer = createAnalyzer(audioFileURL: audioFileURL) else {
				self.showProgress = false
				return
			}
			self.resultsObserver.fileName = audioFileURL.lastPathComponent
			self.resultsObserver.date = FileHelper.creationDateForLocalFilePath(filePath: audioFileURL.path)
			self.resultsObserver.array = []

			// Prepare a new request for the trained model.
			try audioFileAnalyzer.add(request, withObserver: self.resultsObserver)

			audioFileAnalyzer.analyze(completionHandler: { result in
				showSheetView = result
				showProgress = false
			})
		} catch {
			self.showProgress = false
		}
	}

	/// Creates an analyzer for an audio file.
	/// - Parameter audioFileURL: The URL to an audio file.
	func createAnalyzer(audioFileURL: URL) -> SNAudioFileAnalyzer? {
		return try? SNAudioFileAnalyzer(url: audioFileURL)
	}
}

private struct RecordingRow: View {
	var audioURL: URL
	let colorProvider: ColorSchemeProvider
	var body: some View {
		VStack {
			CardTitleView(titleText: "Recording",
			              leftIcon: Image(systemName: "mic.circle.fill"),
			              rightIcon: Image(systemName: "chevron.right"),
			              titleColor: self.colorProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor)),
			              showSeparator: false,
			              colorProvider: colorProvider)
			HStack {
				Text(FileHelper.creationDateForLocalFilePath(filePath: audioURL.path)?.getFormattedDate(format: "'at' HH:mm") ?? "")
					.regularTextModifier(color: colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))
				Spacer()
				Text(FileHelper.covertToFileString(with: FileHelper.sizeForLocalFilePath(filePath: audioURL.path)))
					.regularTextModifier(color: colorProvider.sleepyColorScheme.getColor(of: .textsColors(.secondaryText)))
			}
		}
	}
}

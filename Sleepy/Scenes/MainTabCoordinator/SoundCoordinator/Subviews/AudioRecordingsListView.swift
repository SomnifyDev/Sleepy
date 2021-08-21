//
//  RecordingsList.swift
//  Sleepy
//
//  Created by Никита Казанцев on 14.08.2021.
//

import SwiftUI
import SoundAnalysis
import HKVisualKit
import XUI

struct AudioRecordingsListView: View {

    @Store var viewModel: SoundsCoordinator
    @ObservedObject var audioRecorder = AudioRecorder()

    var groupedByDateData: [Date: [Recording]] {
        Dictionary(grouping: audioRecorder.recordings, by: {$0.createdAt.startOfDay})
    }
    var headers: [Date] {
        groupedByDateData.map({ $0.key }).sorted()
    }

    @State private var showSheetView = false
    @State private var showProgress = false
    // Create a new observer to receive notifications for analysis results.
    let resultsObserver = ResultsObserver()

    var body: some View {
        ZStack(alignment: .center) {
            viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.appBackgroundColor))
                .edgesIgnoringSafeArea(.all)

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
                        }.onDelete { (indexSet) in
                            for index in indexSet {
                                try? FileManager.default.removeItem(at: audioRecorder.recordings[index].fileURL)
                                self.audioRecorder.fetchRecordings()
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showSheetView) {
                AnalysisListView(result: resultsObserver.array,
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
        // TODO: лучше обучить модель
            do {
                let request: SNClassifySoundRequest

                if #available(iOS 15.0, *) { // apple's sound classifier
                    let version1 = SNClassifierIdentifier.version1
                    request = try SNClassifySoundRequest(classifierIdentifier: version1)
                } else { // sleepy ones
                    let config = MLModelConfiguration()
                    let mlModel = try soundClassifier(configuration: config)

                    request = try SNClassifySoundRequest(mlModel: mlModel.model)
                }

                guard let audioFileAnalyzer = self.createAnalyzer(audioFileURL: audioFileURL)
                else {
                    showProgress = false
                    return
                }
                resultsObserver.fileName = audioFileURL.lastPathComponent
                resultsObserver.date = FileHelper.creationDateForLocalFilePath(filePath: audioFileURL.path)
                resultsObserver.array = []

                // Prepare a new request for the trained model.
                try audioFileAnalyzer.add(request, withObserver: resultsObserver)

                audioFileAnalyzer.analyze(completionHandler: { result in
                    showSheetView = result
                    showProgress = false
                })
            } catch {
                showProgress = false
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
            CardTitleView(colorProvider: colorProvider,
                          systemImageName: "mic.circle.fill",
                          titleText: "New_recording\(FileHelper.creationDateForLocalFilePath(filePath: audioURL.path)?.getFormattedDate(format: "dd.MM_HH:mm") ?? "")",
                          titleColor: self.colorProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor)),
                          showSeparator: false,
                          showChevron: true)
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

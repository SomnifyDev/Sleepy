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

    @State private var showSheetView = false
    @State private var showProgress = false
    // Create a new observer to receive notifications for analysis results.
    let resultsObserver = ResultsObserver()

    var body: some View {
        ZStack(alignment: .center) {
            viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.appBackgroundColor))
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                List {
                    Section(header: Text("Recordings")) {
                        ForEach(audioRecorder.recordings, id: \.self) { recording in
                            VStack {
                                RecordingRow(audioURL: recording.fileURL,
                                             colorProvider: viewModel.colorProvider)
                                    .onTapGesture {
                                        showProgress = true
                                        runAnalysis(audioFileURL: recording.fileURL)
                                    }
                            }
                        }.onDelete { (indexSet) in
                            for index in indexSet {
                                try? FileManager.default.removeItem(at: audioRecorder.recordings[index].fileURL)
                                self.audioRecorder.fetchRecordings()
                            }
                        }
                    }.sheet(isPresented: $showSheetView) {
                        AnalysisListView(result: resultsObserver.array,
                                         fileName: resultsObserver.fileName,
                                         endDate: resultsObserver.date,
                                         colorProvider: viewModel.colorProvider,
                                         showSheetView: $showSheetView)
                    }
                }
            }

            if showProgress {
                ProgressView().frame(width: 35, height: 35)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(6)
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
    }

    func runAnalysis(audioFileURL: URL) {
        // TODO: https://medium.com/@narner/classification-of-sound-files-on-ios-with-the-soundanalysis-framework-and-esc-10-coreml-model-3a5154db903f
        // эта часть доступна онли с айос 15 из-за строчек 70-72. Но это можно исправить!
        if #available(iOS 15.0, *) {
            do {
                let version1 = SNClassifierIdentifier.version1

                let request = try SNClassifySoundRequest(classifierIdentifier: version1)

                guard let audioFileAnalyzer = self.createAnalyzer(audioFileURL: audioFileURL)
                else {
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
            } catch {}
        } else {
            // Fallback on earlier versions
            showProgress = false
        }
    }

    /// Creates an analyzer for an audio file.
    /// - Parameter audioFileURL: The URL to an audio file.
    func createAnalyzer(audioFileURL: URL) -> SNAudioFileAnalyzer? {
        return try? SNAudioFileAnalyzer(url: audioFileURL)
    }
}

struct RecordingRow: View {

    var audioURL: URL
    let colorProvider: ColorSchemeProvider
    var body: some View {
        HStack {
            CardTitleView(colorProvider: colorProvider,
                          systemImageName: "mic.circle.fill",
                          titleText: "\(FileHelper.creationDateForLocalFilePath(filePath: audioURL.path)?.getFormattedDate(format: "dd.MM HH:mm") ?? "")",
                          mainText: "sound recording, \(FileHelper.covertToFileString(with: FileHelper.sizeForLocalFilePath(filePath: audioURL.path)))",
                          navigationText: "sounds",
                          titleColor: self.colorProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor)),
                          mainTextColor: colorProvider.sleepyColorScheme.getColor(of: .textsColors(.secondaryText)),
                          showSeparator: false,
                          showChevron: true)
        }
    }
}

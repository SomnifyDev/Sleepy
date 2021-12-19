// Copyright (c) 2021 Sleepy.

import HKVisualKit
import SoundAnalysis
import SwiftUI
import XUI

struct AudioRecordingsListView: View
{
    @Store var viewModel: SoundsCoordinator

    @ObservedObject var audioRecorder = AudioRecorder()
    @State var audioPlayer: AVAudioPlayer!

    private var groupedByDateData: [Date: [Recording]]
    {
        Dictionary(grouping: self.audioRecorder.recordings, by: { $0.createdAt.startOfDay })
    }

    private var headers: [Date]
    {
        self.groupedByDateData.map { $0.key }.sorted()
    }

    var body: some View
    {
        ZStack(alignment: .center)
        {
            self.viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.appBackgroundColor))
                .edgesIgnoringSafeArea(.all)

            VStack
            {
                if self.audioRecorder.recordings.isEmpty
                {
                    BannerView(
                        bannerViewType: .advice(type: .soundRecording, imageSystemName: "speechAdvice"),
                        colorProvider: self.viewModel.colorProvider
                    )
                        .roundedCardBackground(color: self.viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
                }
                else
                {
                    List
                    {
                        ForEach(self.headers, id: \.self)
                        { header in
                            Section(header: Text(header, style: .date))
                            {
                                ForEach(self.groupedByDateData[header] ?? [])
                                { recording in
                                    RecordingRowView(
                                        audioURL: recording.fileURL,
                                        colorProvider: self.viewModel.colorProvider
                                    )
                                        .padding([.top, .bottom, .leading, .trailing], 4)
                                        .contentShape(Rectangle())
                                        .onTapGesture { self.configureAnalysisView(recording: recording) }
                                }.onDelete { indexSet in self.deleteRecordings(indexSet: indexSet) }
                            }
                        }
                    }
                }
                Spacer()
            }
            .sheet(isPresented: self.$viewModel.showAnalysis)
            {
                AnalysisListView(
                    viewModel: self.viewModel,
                    showSheetView: self.$viewModel.showAnalysis,
                    audioPlayer: Binding(self.$audioPlayer)!,
                    result: self.viewModel.resultsObserver.array,
                    fileName: self.viewModel.resultsObserver.fileName,
                    endDate: self.viewModel.resultsObserver.date,
                    colorProvider: self.viewModel.colorProvider
                )
                    .onDisappear(perform: self.audioPlayer.stop)
            }

            if self.viewModel.showLoading
            {
                ProgressView()
                    .frame(width: 35, height: 35)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(6)
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
    }

    private func configureAnalysisView(recording: Recording)
    {
        self.setupAudioPlayer(audioURL: recording.fileURL)
        self.viewModel.runAnalysis(audioFileURL: recording.fileURL)
    }

    private func setupAudioPlayer(audioURL: URL)
    {
        if let newPlayer = try? AVAudioPlayer(contentsOf: audioURL)
        {
            self.audioPlayer = newPlayer
        }
    }

    private func deleteRecordings(indexSet: IndexSet)
    {
        for index in indexSet
        {
            try? FileManager.default.removeItem(at: self.audioRecorder.recordings[index].fileURL)
            self.audioRecorder.fetchRecordings()
        }
    }
}

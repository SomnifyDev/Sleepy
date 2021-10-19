//
//  AudioRecorderView.swift
//  Sleepy
//
//  Created by Никита Казанцев on 14.08.2021.
//

import FirebaseAnalytics
import HKVisualKit
import AVFoundation
import SwiftUI
import XUI

struct SoundsCoordinatorView: View {
    @Store var viewModel: SoundsCoordinator
    @ObservedObject private var audioRecorder = AudioRecorder()

    @State private var showingErrorAlert = false
    @State private var shouldGrantPermissions = false
    private let avAudioSession = AVAudioSession.sharedInstance()

    var body: some View {
        NavigationView {
            ZStack {
                viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.appBackgroundColor))
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    AudioRecordingsListView(viewModel: viewModel, audioRecorder: audioRecorder)

                    if audioRecorder.recording == false {
                        Text(shouldGrantPermissions ? "Allow mic access" : "Record".localized)
                            .customButton(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor)))
                            .onTapGesture {
                                if shouldGrantPermissions {
                                    self.audioRecorder.requestPermissions(self.avAudioSession, completion: { _ in
                                        self.shouldGrantPermissions = self.avAudioSession.recordPermission != .granted
                                    })
                                } else {
                                    showingErrorAlert = !audioRecorder.startRecording()
                                }
                            }
                    } else {
                        Text("STOP".localized)
                            .customButton(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .heart(.heartColor)))
                            .onTapGesture { audioRecorder.stopRecording() }
                    }
                }
            }
            .navigationBarTitle("Sound recognition".localized)
            .onAppear {
                self.sendAnalytics()
                self.shouldGrantPermissions = self.avAudioSession.recordPermission != .granted
            }
            .alert(isPresented: self.$showingErrorAlert) {
                Alert(title: Text("Error".localized), message: Text("Recording Failed. Check microphone permissions".localized))
            }
        }
    }

    private func sendAnalytics() {
        FirebaseAnalytics.Analytics.logEvent("Sounds_viewed", parameters: nil)
    }
}

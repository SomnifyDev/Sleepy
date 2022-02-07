// Copyright (c) 2022 Sleepy.

import AVFoundation
import SwiftUI
import UIComponents
import XUI

struct SoundsCoordinatorView: View {
    @Store var viewModel: SoundsCoordinator

    @ObservedObject private var audioRecorder = AudioRecorder()

    @State private var secondsRecorded = 0
    @State private var shouldShowErrorAlert = false
    @State private var shouldGrantPermissions = false
    @State private var shouldShowCountDown = false

    private let audioSession = AVAudioSession.sharedInstance()
    private let brightnessBeforeRecording = UIScreen.main.brightness

    var body: some View {
        NavigationView {
            ZStack {
                ColorsRepository.General.appBackground
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    AudioRecordingsListView(viewModel: viewModel, audioRecorder: audioRecorder)

                    if audioRecorder.isRecording == false {
                        Text(shouldGrantPermissions ? "Allow mic access" : "Record")
                            .customButton(color: ColorsRepository.General.mainSleepy)
                            .onTapGesture(perform: self.startRecording)
                    }
                }
            }
            .onAppear {
                self.viewModel.sendAnalytics()
                self.shouldGrantPermissions = self.audioSession.recordPermission != .granted
            }
            .navigationBarTitle("Sound recognition")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        audioRecorder.removeAllRecordings()
                    } label: {
                        Text("Remove all")
                            .foregroundColor(.red)
                    }
                }
            }
            .alert(isPresented: self.$shouldShowErrorAlert) {
                Alert(title: Text("Error"), message: Text("Recording Failed. Check microphone permissions"))
            }
            .fullScreenCover(isPresented: self.$shouldShowCountDown) {
                CountDownRecordingView(secondsRecorded: self.$secondsRecorded)
                    .disabled(self.secondsRecorded <= 3)
                    .onTapGesture(perform: self.stopRecording)
            }
        }
    }

    func startRecording() {
        if self.shouldGrantPermissions {
            self.audioRecorder.requestPermissions(self.audioSession, completion: { _ in
                self.shouldGrantPermissions = self.audioSession.recordPermission != .granted
            })
        } else {
            self.shouldShowErrorAlert = !self.audioRecorder.startRecording()
            self.shouldShowCountDown = !self.shouldShowErrorAlert
            UIScreen.main.brightness = 0
        }
    }

    func stopRecording() {
        self.audioRecorder.stopRecording()
        self.shouldShowCountDown = false
        self.secondsRecorded = 0
        UIScreen.main.brightness = self.brightnessBeforeRecording
    }
}

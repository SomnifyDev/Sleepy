// Copyright (c) 2021 Sleepy.

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

	var body: some View {
		NavigationView {
			ZStack {
				viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.appBackgroundColor))
					.edgesIgnoringSafeArea(.all)
				VStack {
					AudioRecordingsListView(viewModel: viewModel, audioRecorder: audioRecorder)

					if audioRecorder.recording == false {
						Text(shouldGrantPermissions ? "Allow mic access" : "Record")
							.customButton(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor)))
							.onTapGesture(perform: self.startRecording)
					}
				}
			}
			.navigationBarTitle("Sound recognition")
			.onAppear {
				self.viewModel.sendAnalytics()
				self.shouldGrantPermissions = self.audioSession.recordPermission != .granted
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
		}
	}

	func stopRecording() {
		self.audioRecorder.stopRecording()
		self.shouldShowCountDown = false
		self.secondsRecorded = 0
	}
}

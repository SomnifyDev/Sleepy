// Copyright (c) 2021 Sleepy.

import AVFoundation
import HKVisualKit
import SwiftUI
import XUI

struct SoundsCoordinatorView: View {
	@Store var viewModel: SoundsCoordinator
	@ObservedObject private var audioRecorder = AudioRecorder()

	@State private var shouldShowErrorAlert = false
	@State private var shouldGrantPermissions = false
	@State private var shouldShowCountDown = false
	@State private var secondsRecorded = 0
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
									self.shouldShowErrorAlert = !audioRecorder.startRecording()
									self.shouldShowCountDown = !shouldShowErrorAlert
								}
							}
					}
				}
			}
			.navigationBarTitle("Sound recognition".localized)
			.onAppear {
				self.viewModel.sendAnalytics()
				self.shouldGrantPermissions = self.avAudioSession.recordPermission != .granted
			}
			.alert(isPresented: self.$shouldShowErrorAlert) {
				Alert(title: Text("Error".localized), message: Text("Recording Failed. Check microphone permissions".localized))
			}
			.fullScreenCover(isPresented: self.$shouldShowCountDown) {
				CountDownRecordingView(secondsRecorded: self.$secondsRecorded)
					.disabled(self.secondsRecorded <= 3)
					.onTapGesture {
						self.audioRecorder.stopRecording()
						self.shouldShowCountDown = false
						self.secondsRecorded = 0
					}
			}
		}
	}
}

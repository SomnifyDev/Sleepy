//
//  AudioRecorderView.swift
//  Sleepy
//
//  Created by Никита Казанцев on 14.08.2021.
//

import FirebaseAnalytics
import HKVisualKit
import SwiftUI
import XUI

struct SoundsCoordinatorView: View {
    @Store var viewModel: SoundsCoordinator
    @ObservedObject private var audioRecorder = AudioRecorder()

    var body: some View {
        NavigationView {
            ZStack {
                viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.appBackgroundColor))
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    AudioRecordingsListView(viewModel: viewModel, audioRecorder: audioRecorder)

                    if audioRecorder.recording == false {
                        Text("Record".localized)
                            .customButton(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor)))
                            .onTapGesture { audioRecorder.startRecording() }
                    } else {
                        Text("STOP".localized)
                            .customButton(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .heart(.heartColor)))
                            .onTapGesture { audioRecorder.stopRecording() }
                    }
                }
            }
            .navigationBarTitle("Sound recognition".localized)
            .onAppear(perform: self.sendAnalytics)
        }
    }

    private func sendAnalytics() {
        FirebaseAnalytics.Analytics.logEvent("Sounds_viewed", parameters: nil)
    }
}

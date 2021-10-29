//
//  CountDownRecordingView.swift
//  Sleepy
//
//  Created by Никита Казанцев on 29.10.2021.
//

import SwiftUI

struct CountDownRecordingView: View {
    @Binding var secondsRecorded: Int

    var timer: Timer {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {_ in
            self.secondsRecorded += 1
        }
    }

    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)

            Text(self.getTimeLabel())
                .foregroundColor(.white)
                .opacity(0.7)
                .font(.largeTitle)
                .onAppear(perform: {
                    _ = self.timer
            })

            VStack {
                Spacer()
                Text("Tap anywhere to stop recording".localized)
                    .foregroundColor(.white)
                    .opacity(0.4)
            }
        }
    }

    private func getTimeLabel() -> String {
        let totalSeconds = Int(self.secondsRecorded)
        let hours = totalSeconds / 3600
        let minutes = totalSeconds % 3600 / 60
        let seconds = totalSeconds % 3600 % 60
        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
}

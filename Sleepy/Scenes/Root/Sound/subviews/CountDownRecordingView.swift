// Copyright (c) 2021 Sleepy.

import SwiftUI

struct CountDownRecordingView: View {
	@Binding var secondsRecorded: Int
	@State private var isActive = true
	private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

	var body: some View {
		ZStack {
			Color.black
				.edgesIgnoringSafeArea(.all)

			Text(self.getTimeLabel())
				.foregroundColor(.white)
				.opacity(0.7)
				.font(.largeTitle)

			VStack {
				Spacer()
				Text("Tap anywhere to stop recording".localized)
					.foregroundColor(.white)
					.opacity(0.4)
			}
		}
		.onReceive(timer) { _ in
			guard self.isActive else { return }
			self.secondsRecorded += 1
		}
		.statusBar(hidden: true)
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

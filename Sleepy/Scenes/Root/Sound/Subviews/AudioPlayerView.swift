// Copyright (c) 2021 Sleepy.

import AVKit
import SwiftUI
import UIComponents

struct AudioPlayerView: View {
	private enum Constants {
		static let soundIndentSeconds = 10.0
	}

	@Binding var audioPlayer: AVAudioPlayer

	@State private var isPlaying: Bool = false
	@State private var currentTime = TimeInterval()
	@State private var progress = 0.0

	private let colorProvider: ColorSchemeProvider
	private let playAtTime: TimeInterval
	private let endAtTime: TimeInterval
	private let audioName: String

	init(audioPlayer: Binding<AVAudioPlayer>,
	     colorProvider: ColorSchemeProvider,
	     playAtTime: TimeInterval,
	     endAtTime: TimeInterval,
	     audioName: String)
	{
		_audioPlayer = audioPlayer
		self.colorProvider = colorProvider
		self.playAtTime = max(0, playAtTime - Constants.soundIndentSeconds)
		self.endAtTime = min(audioPlayer.wrappedValue.duration, endAtTime + Constants.soundIndentSeconds)
		self.audioName = audioName

		self.setupAVSession()
	}

	var body: some View {
		VStack {
			HStack {
				if !isPlaying {
					Image(systemName: "play.circle.fill")
						.resizable()
						.frame(width: 25, height: 25)
						.foregroundColor(colorProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor)))
						.aspectRatio(contentMode: .fit)
						.onTapGesture(perform: self.playAudio)
				} else {
					Image(systemName: "pause.circle.fill")
						.resizable()
						.frame(width: 25, height: 25)
						.foregroundColor(colorProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor)))
						.aspectRatio(contentMode: .fit)
						.onTapGesture(perform: self.audioPlayer.pause)
				}

				Text(self.roundUp(endAtTime - playAtTime, toNearest: 1).stringTime)

				ProgressView(value: progress)
					.progressViewStyle(LinearProgressViewStyle(tint: colorProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor))))
			}
		}
	}

	private func setupAVSession() {
		// workaround чтоб фиксить отсутствие звука при беззвучном режиме
		do {
			try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
			try AVAudioSession.sharedInstance().setActive(true)
		} catch {}
	}

	private func playAudio() {
		self.audioPlayer.currentTime = self.playAtTime
		self.audioPlayer.play()

		self.fetchIsPlaying()
	}

	private func fetchIsPlaying() {
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			self.isPlaying = audioPlayer.isPlaying
			var val = (audioPlayer.currentTime - playAtTime) / (endAtTime - playAtTime)

			if val.isNaN {
				val = 0
			}

			if val >= 1 {
				self.progress = 1
				self.isPlaying = false
				self.audioPlayer.pause()
			} else {
				progress = val
			}

			if !isPlaying {
				progress = 0.0
				return
			}
			self.fetchIsPlaying()
		}
	}

	private func roundUp(_ value: Double, toNearest: Double) -> Double {
		return ceil(value / toNearest) * toNearest
	}
}

//
//  AudioPlayer.swift
//  Sleepy
//
//  Created by Никита Казанцев on 14.08.2021.
//

import AVKit
import HKVisualKit
import SwiftUI

struct AudioPlayerView: View {
    private var audioPlayer: AVAudioPlayer!
    @State private var isPlaying: Bool = false
    @State private var currentTime = TimeInterval()
    @State private var progress = 0.0

    let colorProvider: ColorSchemeProvider
    let playAtTime: TimeInterval
    let endAtTime: TimeInterval

    let audioName: String

    init(colorProvider: ColorSchemeProvider,
         playAtTime: TimeInterval,
         endAtTime: TimeInterval,
         audioName: String)
    {
        self.colorProvider = colorProvider
        self.playAtTime = playAtTime
        self.endAtTime = endAtTime
        self.audioName = audioName

        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentPath.appendingPathComponent(audioName)

        audioPlayer = try! AVAudioPlayer(contentsOf: audioFilename)

        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.none)
        } catch _ {}
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
                        .onTapGesture {
                            self.audioPlayer.currentTime = playAtTime
                            self.audioPlayer.play()

                            self.fetchIsPlaying()
                        }
                } else {
                    Image(systemName: "pause.circle.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(colorProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor)))
                        .aspectRatio(contentMode: .fit)
                        .onTapGesture {
                            self.audioPlayer.pause()
                        }
                }

                Text((endAtTime - currentTime).stringTime)

                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: colorProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor))))
            }
        }
    }

    private func fetchIsPlaying() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.isPlaying = audioPlayer.isPlaying
            self.currentTime = audioPlayer.currentTime

            var val = (currentTime - playAtTime) / (endAtTime - playAtTime)

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
                self.currentTime = playAtTime
                progress = 0.0
                return
            }
            self.fetchIsPlaying()
        }
    }
}

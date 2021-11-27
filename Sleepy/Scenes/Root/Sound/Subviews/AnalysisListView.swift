// Copyright (c) 2021 Sleepy.

import AVFAudio
import HKVisualKit
import SwiftUI
import XUI

struct AnalysisListView: View {
	@Store var viewModel: SoundsCoordinator

	@Binding var showSheetView: Bool
	@Binding var audioPlayer: AVAudioPlayer

	let result: [SoundAnalysisResult]
	let fileName: String
	let endDate: Date?
	let colorProvider: ColorSchemeProvider

	var body: some View {
		NavigationView {
			ZStack {
				colorProvider.sleepyColorScheme.getColor(of: .general(.appBackgroundColor))
					.edgesIgnoringSafeArea(.all)

				ScrollView(.vertical, showsIndicators: false) {
					VStack(alignment: .center, spacing: 2) {
						SectionNameTextView(text: "Recognized sounds",
						                    color: colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))
							.padding([.top, .bottom])

						ForEach(result, id: \.self) { item in
							VStack {
								CardTitleView(titleText: item.soundType,
								              mainText: String(format: "%.2f%% confidence", item.confidence),
								              leftIcon: Image(systemName: "waveform"),
								              navigationText: self.getDescription(item: item, date: endDate),
								              titleColor: colorProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor)),
								              mainTextColor: colorProvider.sleepyColorScheme.getColor(of: .textsColors(.secondaryText)),
								              showSeparator: false,
								              colorProvider: self.colorProvider)

								AudioPlayerView(audioPlayer: self.$audioPlayer,
								                colorProvider: self.colorProvider,
								                playAtTime: item.start,
								                endAtTime: item.end,
								                audioName: fileName)
							}.roundedCardBackground(color: colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
						}

						if result.isEmpty {
							Text("No sound recognized. You can try to lower recognisition confidence coefficient in your settings")
								.underline()
								.onTapGesture(perform: self.openSettings)
						}
					}
				}
			}
			.onDisappear(perform: self.stopAudioPlayer)
			.navigationTitle(endDate?.getFormattedDate(format: "MMM d") ?? "")
			.navigationBarItems(trailing: Button("Done", action: { showSheetView = false }))
		}
	}

	private func getDescription(item: SoundAnalysisResult, date: Date?) -> String? {
		if let startDate = date,
		   let startDate = Calendar.current.date(byAdding: .second, value: -Int(item.end - item.start), to: startDate)
		{
			return startDate.getFormattedDate(format: "HH:mm")
		}
		return nil
	}

	private func openSettings() {
		self.showSheetView = false
		self.viewModel.openSettings()
	}

	private func stopAudioPlayer() {
		self.audioPlayer.stop()
	}
}

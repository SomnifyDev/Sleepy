// Copyright (c) 2021 Sleepy.

import SwiftUI
import UIComponents

struct RecordingRowView: View {
	var audioURL: URL
	let colorProvider: ColorSchemeProvider
	var body: some View {
		VStack {
			CardTitleView(titleText: "Recording",
			              leftIcon: Image(systemName: "mic.circle.fill"),
			              rightIcon: Image(systemName: "chevron.right"),
			              titleColor: self.colorProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor)),
			              showSeparator: false,
			              colorProvider: colorProvider)
			HStack {
				Text(FileHelper.creationDateForLocalFilePath(filePath: audioURL.path)?.getFormattedDate(format: "'at' HH:mm") ?? "")
					.regularTextModifier(color: ColorsRepository.Text.standard)
				Spacer()
				Text(FileHelper.covertToFileString(with: FileHelper.sizeForLocalFilePath(filePath: audioURL.path)))
					.regularTextModifier(color: colorProvider.sleepyColorScheme.getColor(of: .textsColors(.secondaryText)))
			}
		}
	}
}

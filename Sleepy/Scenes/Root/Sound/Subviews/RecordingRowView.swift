// Copyright (c) 2022 Sleepy.

import SwiftUI
import UIComponents

struct RecordingRowView: View {
    var audioURL: URL

    var body: some View {
        VStack {
            CardTitleView(with: .init(
                leadIcon: IconsRepository.microphone,
                title: "Recording",
                description: nil,
                trailIcon: IconsRepository.chevronRight,
                trailText: nil,
                titleColor: ColorsRepository.General.mainSleepy,
                descriptionColor: nil,
                shouldShowSeparator: false
            ))

            HStack {
                Text(FileHelper.creationDateForLocalFilePath(filePath: audioURL.path)?.getFormattedDate(format: "'at' HH:mm") ?? "")
                    .regularTextModifier(color: ColorsRepository.Text.standard)
                Spacer()
                Text(FileHelper.covertToFileString(with: FileHelper.sizeForLocalFilePath(filePath: audioURL.path)))
                    .regularTextModifier(color: ColorsRepository.Text.secondary)
            }
        }
    }
}

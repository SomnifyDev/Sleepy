// Copyright (c) 2021 Sleepy.

import SwiftUI

public struct CardTitleView: View {

    private let config: CardTitleConfig

    public init(config: CardTitleConfig) {
        self.config = config
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                config.leftIcon
                    .foregroundColor(config.titleColor)

                Text(config.titleText)
                    .cardTitleTextModifier(color: config.titleColor)

                Spacer()

                if let navigationText = config.navigationText {
                    Text(navigationText)
                        .cardTitleTextModifier(color: config.titleColor)
                        .lineLimit(1)
                }

                if let rightIcon = config.rightIcon {
                    rightIcon
                        .foregroundColor(config.titleColor)
                        .onTapGesture {
                            if rightIcon == Image(systemName: "xmark.circle") {
                                config.onCloseTapAction?()
                            }
                        }
                }
            }

            if let mainText = config.mainText,
               let mainTextColor = config.mainTextColor {
                Text(mainText)
                    .cardDescriptionTextModifier(color: mainTextColor)
            }

            if config.shouldShowSeparator {
                Divider()
                    .padding(.top, 4)
            }
        }
        .frame(minHeight: .zero)
    }
}

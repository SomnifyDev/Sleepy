import SwiftUI

public struct AdviceBannerConfig {

    // MARK: - Properties

    let adviceType: AdviceBannerType
    let adviceImage: Image
    let colorProvider: ColorSchemeProvider
    let cardTitleConfig: CardTitleConfig

    // MARK: - Init

    public init(
        adviceType: AdviceBannerType,
        adviceImage: Image,
        colorProvider: ColorSchemeProvider
    ) {
        self.adviceType = adviceType
        self.adviceImage = adviceImage
        self.colorProvider = colorProvider
        self.cardTitleConfig = CardTitleConfig(
            titleText: "Advice",
            mainText: {
                switch adviceType {
                case .wearMore:
                    return "Try to sleep with your watch on your wrist to get phase, heart, and energy analysis"
                case .soundRecording:
                    return "Record your sleep sounds by pressing ‘record’ button below and get sound-recognision after you end recording"
                }
            }(),
            leftIcon: Image(systemName: "questionmark.square.dashed"),
            rightIcon: Image(systemName: "xmark.circle"),
            navigationText: nil,
            titleColor: colorProvider.sleepyColorScheme.getColor(of: .textsColors(.adviceText)),
            mainTextColor: colorProvider.sleepyColorScheme.getColor(of: .textsColors(.secondaryText)),
            shouldShowSeparator: true,
            onCloseTapAction: {
                UserDefaults.standard.set(true, forKey: adviceType.rawValue)
            },
            colorProvider: colorProvider
        )
    }

}

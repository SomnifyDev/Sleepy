import SwiftUI

public enum ErrorReason {
    case emptyData(type: HealthData)
    case brokenData(type: HealthData)
    case restrictedData(type: HealthData)
}

public struct ErrorBannerConfig {

    // MARK: - Properties

    let reason: ErrorReason
    let colorProvider: ColorSchemeProvider
    let cardTitleConfig: CardTitleConfig

    // MARK: - Init

    public init(
        reason: ErrorReason,
        colorProvider: ColorSchemeProvider
    ) {
        self.reason = reason
        self.colorProvider = colorProvider
        self.cardTitleConfig = CardTitleConfig(
            titleText: "Data is empty or restricted",
            mainText: {
                switch reason {
                case .emptyData(let type):
                    return String(format: "No data of type %@ was recieved".localized, type.rawValue)
                case .brokenData(let type):
                    return String(format: "There was not enought data to display your %@ charts. Try to sleep with Apple Watch More".localized, type.rawValue)
                case .restrictedData(let type):
                    return "Sleepy was restricted from reading your \(type.rawValue) data. Fix that in your settings"
                }
            }(),
            leftIcon: {
                switch reason {
                case .emptyData(_), .brokenData(_):
                    return Image(systemName: "exclamationmark.square.fill")
                case .restrictedData(_):
                    return Image(systemName: "eye.slash.fill")
                }
            }(),
            rightIcon: nil,
            navigationText: nil,
            titleColor: Color.red,
            mainTextColor: colorProvider.sleepyColorScheme.getColor(of: .textsColors(.secondaryText)),
            shouldShowSeparator: false,
            onCloseTapAction: nil,
            colorProvider: colorProvider
        )
    }

}

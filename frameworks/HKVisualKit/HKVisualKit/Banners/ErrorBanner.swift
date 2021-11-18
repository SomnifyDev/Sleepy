import SwiftUI

public enum ErrorReason {
    case emptyData(type: HealthData)
    case brokenData(type: HealthData)
    case restrictedData(type: HealthData)
}

public struct ErrorBanner: View {

    // MARK: - Properties

    private let reason: ErrorReason
    private let colorProvider: ColorSchemeProvider

    public var body: some View {
        CardTitleView(config: getCardTitleConfig())
    }

    // MARK: - Init

    public init(
        reason: ErrorReason,
        _ colorProvider: ColorSchemeProvider
    ) {
        self.reason = reason
        self.colorProvider = colorProvider
    }

    // MARK: - Private methods

    private func getCardTitleConfig() -> CardTitleConfig {
        return CardTitleConfig(
            titleText: "Data is empty or restricted",
            mainText: getMainText(),
            leftIcon: getLeftIcon(),
            rightIcon: nil,
            navigationText: nil,
            titleColor: Color.red,
            mainTextColor: colorProvider.sleepyColorScheme.getColor(of: .textsColors(.secondaryText)),
            shouldShowSeparator: false,
            onCloseTapAction: nil,
            colorProvider: colorProvider
        )
    }

    private func getMainText() -> String {
        switch reason {
        case .emptyData(let type):
            return String(format: "No data of type %@ was recieved".localized, type.rawValue)
        case .brokenData(let type):
            return String(format: "There was not enought data to display your %@ charts. Try to sleep with Apple Watch More".localized, type.rawValue)
        case .restrictedData(let type):
            return "Sleepy was restricted from reading your \(type.rawValue) data. Fix that in your settings"
        }
    }

    private func getLeftIcon() -> Image {
        switch reason {
        case .emptyData(_), .brokenData(_):
            return Image(systemName: "exclamationmark.square.fill")
        case .restrictedData(_):
            return Image(systemName: "eye.slash.fill")
        }
    }

}

fileprivate struct ErrorBanner_Previews: PreviewProvider {
    static var previews: some View {
        ErrorBanner(
            reason: .brokenData(type: .sleep),
            ColorSchemeProvider()
        )
    }
}

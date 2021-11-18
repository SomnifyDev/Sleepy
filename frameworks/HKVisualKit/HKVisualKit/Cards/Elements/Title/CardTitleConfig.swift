import SwiftUI

public struct CardTitleConfig {

    // MARK: - Properties

    let titleText: String
    let mainText: String?
    let leftIcon: Image
    let rightIcon: Image?
    let navigationText: String?
    let titleColor: Color
    let mainTextColor: Color?
    let shouldShowSeparator: Bool
    let onCloseTapAction: (() -> Void)?
    let colorProvider: ColorSchemeProvider

    // MARK: - Init

    public init(
        titleText: String,
        mainText: String?,
        leftIcon: Image,
        rightIcon: Image?,
        navigationText: String?,
        titleColor: Color,
        mainTextColor: Color?,
        shouldShowSeparator: Bool,
        onCloseTapAction: (() -> Void)?,
        colorProvider: ColorSchemeProvider
    ) {
        self.titleText = titleText
        self.mainText = mainText
        self.leftIcon = leftIcon
        self.rightIcon = rightIcon
        self.navigationText = navigationText
        self.titleColor = titleColor
        self.mainTextColor = mainTextColor
        self.shouldShowSeparator = shouldShowSeparator
        self.onCloseTapAction = onCloseTapAction
        self.colorProvider = colorProvider
    }

}

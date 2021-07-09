import SwiftUI

// MARK: Structs

public enum SleepyFontsSizes {
    static var cardNameFontSize: CGFloat { return 22 }
    static var cardDescriptionFontSize: CGFloat { return 16 }
    static var generalCardElementDescriptionFontSize: CGFloat { return 14 }
}

extension Text {

    // MARK: Cards abstract

    func cardNameText(with color: Color) -> some View {
        self
            .bold()
            .font(.system(size: SleepyFontsSizes.cardNameFontSize))
            .foregroundColor(color)
    }

    func cardTitleText(with color: Color) -> some View {
        self
            .bold()
            .foregroundColor(color)
    }

    func cardDescriptionText(with color: Color) -> some View {
        self
            .font(.system(size: SleepyFontsSizes.cardDescriptionFontSize, weight: .semibold, design: .default))
            .foregroundColor(color)
    }

    func cardBottomText(with color: Color) -> some View {
        self
            .fixedSize(horizontal: false, vertical: true)
            .foregroundColor(color)
    }

    // MARK: General card elements

    func generalCardElementValue(with color: Color) -> some View {
        self
            .bold()
            .foregroundColor(color)
    }

    func generalCardElementDescription(with color: Color) -> some View {
        self
            .bold()
            .font(.system(size: SleepyFontsSizes.generalCardElementDescriptionFontSize))
            .foregroundColor(color)
    }




}

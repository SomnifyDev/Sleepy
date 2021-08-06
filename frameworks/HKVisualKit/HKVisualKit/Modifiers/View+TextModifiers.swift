import SwiftUI

// MARK: Structs

public enum SleepyFontsSizes {
    static var cardNameFontSize: CGFloat { return 22 }
    static var cardDescriptionFontSize: CGFloat { return 16 }
    static var generalCardElementDescriptionFontSize: CGFloat { return 14 }
    static var calendarDayNumberFontSize: CGFloat { return 8 }
    static var calendarWeekDayFontSize: CGFloat { return 8}
}

extension Text {

    // MARK: Cards abstract

    public func boldTextModifier(color: Color, size: CGFloat = 16, opacity: CGFloat = 1) -> some View {
        self
            .bold()
            .foregroundColor(color)
            .font(.system(size: size))
    }

    public func semiboldTextModifier(color: Color, size: CGFloat = 16, opacity: CGFloat = 1) -> some View {
        self
            .fontWeight(.semibold)
            .foregroundColor(color)
            .font(.system(size: size))
    }

    public func regularTextModifier(color: Color, size: CGFloat = 16, opacity: CGFloat = 1) -> some View {
        self
            .foregroundColor(color)
            .font(.system(size: size))
            .opacity(opacity)
    }

    public func cardNameTextModifier(color: Color) -> some View {
        self
            .bold()
            .font(.system(size: SleepyFontsSizes.cardNameFontSize))
            .foregroundColor(color)
    }

    public func cardTitleTextModifier(color: Color) -> some View {
        self
            .bold()
            .fixedSize(horizontal: false, vertical: true)
            .foregroundColor(color)
    }

    public func cardDescriptionTextModifier(color: Color) -> some View {
        self
            .font(.system(size: SleepyFontsSizes.cardDescriptionFontSize, weight: .semibold, design: .default))
            .fixedSize(horizontal: false, vertical: true)
            .foregroundColor(color)
            .padding(.top, 8)
    }

    public func cardBottomTextModifier(color: Color) -> some View {
        self
            .fontWeight(.semibold)
            .font(.system(size: 14))
            .fixedSize(horizontal: false, vertical: true)
            .foregroundColor(color)
            .padding(.top, 4)
    }

    // MARK: General card elements

    public func generalCardElementValueModifier(color: Color) -> some View {
        self
            .bold()
            .foregroundColor(color)
    }

    public func generalCardElementDescriptionModifier(color: Color) -> some View {
        self
            .bold()
            .font(.system(size: SleepyFontsSizes.generalCardElementDescriptionFontSize))
            .foregroundColor(color)
    }

    // MARK: Calendar

    public func calendarMonthTitleModifier(color: Color) -> some View {
        self
            .foregroundColor(color)
            .font(.system(size: 24))
            .fontWeight(.bold)
    }

    public func dayCircleInfoTextModifier(geometry: GeometryProxy) -> some View {
        self
            .font(.system(size: geometry.size.height > geometry.size.width
                          ? geometry.size.width * 0.3
                          : geometry.size.height * 0.3))
            .foregroundColor(.white)
            .lineLimit(1)
    }

    public func dayNumberTextModifier() -> some View {
        self
            .font(.system(size: SleepyFontsSizes.calendarDayNumberFontSize))
            .fontWeight(.semibold)
            .opacity(0.3)
    }

    public func weekDayTextModifier(width: CGFloat) -> some View {
        self
            .font(.system(size: SleepyFontsSizes.calendarWeekDayFontSize))
            .fontWeight(.semibold)
            .opacity(0.3)
            .frame(width: width)
    }

    public func healthTypeSwitchTextModifier() -> some View {
        self
            .padding([.top, .bottom], 6)
            .padding([.leading, .trailing], 10)
            .font(.system(size: 14).weight(.semibold))
            .foregroundColor(.white)
    }

    public func linkTextModifier() -> some View {
        self
            .font(.system(size: SleepyFontsSizes.generalCardElementDescriptionFontSize))
            .fontWeight(.semibold)
            .underline()
            .lineLimit(1)
            .opacity(0.3)
    }

}

public struct CardNameTextView: View {

    private let color: Color
    private let text: String

    public init(text: String, color: Color) {
        self.text = text
        self.color = color
    }

    public var body: some View {
        HStack {
            Text(text)
                .cardNameTextModifier(color: color)
            Spacer()
        }
        .padding(.leading)
    }
}

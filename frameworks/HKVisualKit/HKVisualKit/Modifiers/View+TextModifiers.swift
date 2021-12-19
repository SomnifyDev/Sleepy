// Copyright (c) 2021 Sleepy.

import SwiftUI

// MARK: Structs

public enum SleepyFontsSizes
{
    static var cardNameFontSize: CGFloat { return 22 }
    static var cardDescriptionFontSize: CGFloat { return 16 }
    static var generalCardElementDescriptionFontSize: CGFloat { return 14 }
    static var calendarDayNumberFontSize: CGFloat { return 8 }
    static var calendarWeekDayFontSize: CGFloat { return 8 }
}

public extension Text
{
    // MARK: Cards abstract

    func boldTextModifier(color: Color, size: CGFloat = 16, opacity _: CGFloat = 1) -> some View
    {
        bold()
            .foregroundColor(color)
            .font(.system(size: size))
    }

    func semiboldTextModifier(color: Color, size: CGFloat = 16, opacity _: CGFloat = 1) -> some View
    {
        fontWeight(.semibold)
            .foregroundColor(color)
            .font(.system(size: size))
    }

    func regularTextModifier(color: Color, size: CGFloat = 16, opacity: CGFloat = 1) -> some View
    {
        foregroundColor(color)
            .font(.system(size: size))
            .opacity(opacity)
    }

    func cardNameTextModifier(color: Color) -> some View
    {
        bold()
            .font(.system(size: SleepyFontsSizes.cardNameFontSize))
            .foregroundColor(color)
    }

    func cardTitleTextModifier(color: Color) -> some View
    {
        bold()
            .fixedSize(horizontal: false, vertical: true)
            .foregroundColor(color)
    }

    func cardDescriptionTextModifier(color: Color) -> some View
    {
        font(.system(size: SleepyFontsSizes.cardDescriptionFontSize, weight: .semibold, design: .default))
            .fixedSize(horizontal: false, vertical: true)
            .foregroundColor(color)
            .padding(.top, 8)
    }

    func cardBottomTextModifier(color: Color) -> some View
    {
        fontWeight(.semibold)
            .font(.system(size: 14))
            .fixedSize(horizontal: false, vertical: true)
            .foregroundColor(color)
            .padding(.top, 4)
    }

    // MARK: General card elements

    func generalCardElementValueModifier(color: Color) -> some View
    {
        bold()
            .foregroundColor(color)
    }

    func generalCardElementDescriptionModifier(color: Color) -> some View
    {
        bold()
            .font(.system(size: SleepyFontsSizes.generalCardElementDescriptionFontSize))
            .foregroundColor(color)
    }

    // MARK: Calendar

    func calendarMonthTitleModifier(color: Color) -> some View
    {
        foregroundColor(color)
            .font(.system(size: 24))
            .fontWeight(.bold)
    }

    func dayCircleInfoTextModifier(geometry: GeometryProxy) -> some View
    {
        font(.system(size: geometry.size.height > geometry.size.width
                ? geometry.size.width * 0.3
                : geometry.size.height * 0.3))
            .foregroundColor(.white)
            .lineLimit(1)
    }

    func dayNumberTextModifier() -> some View
    {
        font(.system(size: SleepyFontsSizes.calendarDayNumberFontSize))
            .fontWeight(.semibold)
            .opacity(0.3)
    }

    func weekDayTextModifier(width: CGFloat) -> some View
    {
        font(.system(size: SleepyFontsSizes.calendarWeekDayFontSize))
            .fontWeight(.semibold)
            .opacity(0.3)
            .frame(width: width)
    }

    func healthTypeSwitchTextModifier() -> some View
    {
        padding([.top, .bottom], 6)
            .padding([.leading, .trailing], 10)
            .font(.system(size: 14).weight(.semibold))
            .foregroundColor(.white)
    }

    func linkTextModifier() -> some View
    {
        font(.system(size: SleepyFontsSizes.generalCardElementDescriptionFontSize))
            .fontWeight(.semibold)
            .underline()
            .lineLimit(1)
            .opacity(0.3)
    }
}

public struct SectionNameTextView: View
{
    private let color: Color
    private let text: String

    public init(text: String, color: Color)
    {
        self.text = text
        self.color = color
    }

    public var body: some View
    {
        HStack
        {
            Text(text)
                .cardNameTextModifier(color: color)
            Spacer()
        }
        .padding(.leading)
    }
}

// Copyright (c) 2021 Sleepy.

import SwiftUI

struct CardBackground: ViewModifier {
	var color: Color

	func body(content: Content) -> some View {
		content
			.padding([.leading, .trailing, .top, .bottom])
			.background(self.color)
			.cornerRadius(12)
			.padding([.leading, .trailing, .bottom])
	}
}

struct RoundedGradientCard: ViewModifier {
	var color1: Color
	var color2: Color

	func body(content: Content) -> some View {
		content
			.padding([.leading, .trailing, .top, .bottom])
			.background(LinearGradient(gradient: Gradient(colors: [self.color1, self.color2]),
			                           startPoint: .bottomLeading,
			                           endPoint: .topTrailing).opacity(0.3))
			.cornerRadius(12)
			.padding([.leading, .trailing, .bottom])
	}
}

struct ButtonModifier: ViewModifier {
	var color: Color

	func body(content: Content) -> some View {
		content
			.foregroundColor(.white)
			.font(.headline)
			.padding()
			.frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
			.background(RoundedRectangle(cornerRadius: 15, style: .continuous)
				.fill(self.color))
			.padding([.leading, .trailing, .bottom])
	}
}

struct SkipButtonModifier: ViewModifier {
	var color: Color

	func body(content: Content) -> some View {
		content
			.foregroundColor(.white)
			.font(.headline)
			.padding()
			.frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
			.background(RoundedRectangle(cornerRadius: 15, style: .continuous)
				.fill(Color.gray))
			.padding(.bottom)
	}
}

struct UsefulInfoCardBackground: ViewModifier {
	var color: Color

	func body(content: Content) -> some View {
		content
			.background(self.color)
			.cornerRadius(12)
			.padding([.leading, .trailing, .bottom])
	}
}

public extension View {
	func roundedCardBackground(color: Color) -> some View {
		modifier(CardBackground(color: color))
	}

	func roundedGradientCard(color1: Color, color2: Color) -> some View {
		modifier(RoundedGradientCard(color1: color1, color2: color2))
	}

	func usefulInfoCardBackground(color: Color) -> some View {
		modifier(UsefulInfoCardBackground(color: color))
	}

	func customButton(color: Color) -> some View {
		modifier(ButtonModifier(color: color))
	}

	func skipCustomButton(color: Color) -> some View {
		modifier(SkipButtonModifier(color: color))
	}
}

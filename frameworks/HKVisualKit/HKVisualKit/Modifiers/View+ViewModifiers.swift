import SwiftUI

struct CardBackground: ViewModifier {
    var color: Color

    func body(content: Content) -> some View {
        content
            .padding([.leading, .trailing, .top, .bottom])
            .background(color)
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
            .background(LinearGradient(gradient: Gradient(colors: [color1, color2]),
                                       startPoint: .bottomLeading,
                                       endPoint: .topTrailing).opacity(0.3))
            .cornerRadius(12)
            .padding([.leading, .trailing, .bottom])

    }
}

public extension View {
    func roundedCardBackground(color: Color) -> some View {
        self.modifier(CardBackground(color: color))
    }

    func roundedGradientCard(color1: Color, color2: Color) -> some View {
        self.modifier(RoundedGradientCard(color1: color1, color2: color2))
    }
}

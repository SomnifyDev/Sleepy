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

public extension View {
    func roundedCardBackground(color: Color) -> some View {
        self.modifier(CardBackground(color: color))
    }
}

import SwiftUI

extension Image {

    public func summaryCardImage(color: Color, size: CGFloat, width: CGFloat) -> some View {
        self
            .foregroundColor(color)
            .font(.system(size: size, weight: .bold))
            .frame(width: width)
    }


}

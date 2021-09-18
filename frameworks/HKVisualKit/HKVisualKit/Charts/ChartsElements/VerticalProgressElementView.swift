import SwiftUI

/// Элемент для вертикального графика прогресса
/// - Parameters:
///  - percentage: процент сна за конкретный день, для которого нужно построить элемент
///  - color: цвет отображения
struct VerticalProgressElementView: View {

    private let cornerRadius: Double = 50
    private let percentage: Double
    private let foregroundElementColor: Color
    private let backgroundElementColor: Color
    private let height: CGFloat

    init(percentage: Double, foregroundElementColor: Color, backgroundElementColor: Color, height: CGFloat) {
        self.percentage = percentage
        self.foregroundElementColor = foregroundElementColor
        self.backgroundElementColor = backgroundElementColor
        self.height = height
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(backgroundElementColor)
                .cornerRadius(cornerRadius)

            Rectangle()
                .fill(foregroundElementColor)
                .frame(height: min(height * percentage, height))
                .cornerRadius(cornerRadius)
        }
        .frame(height: height)
    }
}

import SwiftUI

/// Элемент для вертикального графика прогресса
/// - Parameters:
///  - percentage: процент сна за конкретный день, для которого нужно построить элемент
///  - color: цвет отображения
struct VerticalProgressElementView: View {

    private let cornerRadius: Double = 50
    private let opacity: Double = 0.1
    private let percentage: Double
    private let color: Color

    init(percentage: Double, color: Color) {
        self.percentage = percentage
        self.color = color
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(Color(.black).opacity(opacity))
                    .cornerRadius(cornerRadius)

                Rectangle()
                    .fill(color)
                    .frame(height: geometry.size.height * percentage)
                    .cornerRadius(cornerRadius)
            }
        }
    }
}

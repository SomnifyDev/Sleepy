import SwiftUI

/// Стандартный элемент графика (фазы, сердце)
/// Параметры:
///     - width: ширина элемента
///     - height: высота элементе
///     - color: цвет отображения
struct StandardChartElementView: View {

    private let cornerRadius: Double = 50
    private let width: CGFloat
    private let height: CGFloat
    private let color: Color

    init(width: CGFloat, height: CGFloat, color: Color) {
        self.width = width
        self.height = height
        self.color = color
    }

    var body: some View {
        Rectangle()
            .foregroundColor(color)
            .frame(width: width, height: height)
            .cornerRadius(cornerRadius)
    }
}

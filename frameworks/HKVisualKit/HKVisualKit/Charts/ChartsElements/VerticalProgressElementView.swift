import SwiftUI

/// Элемент для графика банка сна
/// Параметры:
///     - sleepPercentage: процент сна за конкретный день, для которого нужно построить элемент
struct VerticalProgressElementView: View {

    private let standartHeight: Double = 100
    private let cornerRadius: Double = 50
    private let opacity: Double = 0.1
    private let percentage: Double
    private let color: Color

    init(percentage: Double, color: Color) {
        self.percentage = percentage
        self.color = color
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(Color(.black).opacity(opacity))
                .frame(height: standartHeight)
                .cornerRadius(cornerRadius)

            Rectangle()
                .fill(color)
                .frame(height: min(percentage, standartHeight))
                .cornerRadius(cornerRadius)
        }
    }
}

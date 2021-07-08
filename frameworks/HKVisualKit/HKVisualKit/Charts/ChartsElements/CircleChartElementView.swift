import SwiftUI

/// Кружочек сердцебиения (элемент графика сердцебиения с кружочками на разной высоте)
/// Параметры:
///     - max: максимальное значение среди данных
///     - min: минимальное значение среди данных
///     - mean: среднее значение данных
///     - current: значение, для которого нужно построить элемент
///     - color: цвет отображения
struct CircleChartElementView: View {

    private var topSpacerHeight: Double = 0
    private var bottomSpacerHeight: Double = 0
    private let circleColor: Color
    private let mean: Double

    init(max: Double, min: Double, mean: Double, current: Double, circleColor: Color) {
        self.mean = mean
        self.circleColor = circleColor

        if current > mean {
            topSpacerHeight = 0
            bottomSpacerHeight = 85 * (current - mean)/(max - mean)
        } else if current < mean {
            topSpacerHeight = 85 * abs(current - mean)/(max - mean)
            bottomSpacerHeight = 0
        }
    }

    var body: some View {
        VStack {
            Spacer(minLength: topSpacerHeight)
            Circle()
                .foregroundColor(circleColor)
            Spacer(minLength: bottomSpacerHeight)
        }
        .frame(width: 15, height: 100)
    }
}

struct CircleChartElementView_Previews: PreviewProvider {
    static var previews: some View {
        CircleChartElementView(max: 75, min: 45, mean: 60, current: 60, circleColor: .red)
    }
}

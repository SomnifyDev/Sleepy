import SwiftUI

/// График с кружочками (для сердца)
/// /// Параметры:
///     - points: значения для элементов графика
///     - color: цвет отображения
struct CirclesChartView: View {

    private let colorProvider: ColorSchemeProvider
    private let dragGestureData: [String]?
    private let points: [Double]
    private let chartColor: Color

    init(colorProvider: ColorSchemeProvider, points: [Double], dragGestureData: [String]?, chartColor: Color) {
        self.colorProvider = colorProvider
        self.points = points
        self.dragGestureData = dragGestureData
        self.chartColor = chartColor
    }

    var body: some View {
        GeometryReader { geometry in
            HStack (spacing: 3) {
                let min = points.min()!
                let max = points.max()!
                let mean = (max + min) / 2.0
                ForEach(0 ..< points.count, id: \.self) { index in
                    CircleChartElementView(max: max, min: min, mean: mean, current: points[index], circleColor: chartColor)
                }
            }
        }
    }
}

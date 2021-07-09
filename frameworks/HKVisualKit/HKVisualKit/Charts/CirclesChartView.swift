import SwiftUI

/// График с кружочками, двигающимися по высоте графика
/// - Parameters:
///  - points: значения для элементов графика
///  - dragGestureData: строковые элементы для отображения при dragGesture
///  - chartColor: цвет отображения
struct CirclesChartView: View {

    private let dragGestureData: String?
    private let points: [Double]
    private let chartColor: Color

    init(points: [Double], dragGestureData: String?, chartColor: Color) {
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
                    CircleChartElementView(maximal: max, minimal: min, mean: mean, current: points[index], circleColor: chartColor, height: geometry.size.height, width: abs((geometry.size.width - 3 * CGFloat(points.count - 1))) / CGFloat(points.count))
                }
            }
        }
    }
}

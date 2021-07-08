import SwiftUI

/// График с кружочками (для сердца)
/// /// Параметры:
///     - points: значения для элементов графика
///     - color: цвет отображения
struct CirclesChartView: View {

    private let colorProvider: ColorSchemeProvider
    private let data: [String: Double]
    private let points: [Double]
    private let color: Color

    init(colorProvider: ColorSchemeProvider, data: [String: Double], color: Color) {
        self.colorProvider = colorProvider
        self.data = data
        self.color = color
        self.points = data.map({$0.value})
    }

    var body: some View {
        GeometryReader { geometry in
            let circleWidth: CGFloat = 15
            let spacing = (geometry.size.width - circleWidth * CGFloat(points.count)) / CGFloat(points.count - 1)

            HStack (spacing: spacing) {
                let min = points.min()!
                let max = points.max()!
                let mean = (max + min) / 2.0
                
                ForEach(0 ..< points.count, id: \.self) { index in
                    CircleChartElementView(max: max, min: min, mean: mean, current: points[index], circleColor: .red)
                }
            }
        }
    }
}

struct CirclesChartView_Previews: PreviewProvider {
    static var previews: some View {
        CirclesChartView(colorProvider: ColorSchemeProvider(), data: [:], color: .red)
    }
}

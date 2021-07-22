import SwiftUI

/// Элемент графика с кружочками на разной высоте
/// - Parameters:
///  - maximal: максимальное значение среди данных
///  - minimal: минимальное значение среди данных
///  - mean: среднее значение данных
///  - current: значение, для которого нужно построить элемент
///  - circleColor: цвет отображения
///  - height: высота элемента
///  - width: ширина элемента
struct CircleChartElementView: View {
    private var yPosition: Double
    private let circleColor: Color
    private let height: CGFloat
    private let width: CGFloat

    init(maximal: Double, minimal: Double, mean: Double, current: Double, circleColor: Color, height: CGFloat, width: CGFloat) {
        self.circleColor = circleColor
        self.height = height
        self.width = width

        if current == maximal {
            yPosition = -(height / 2) + (width / 2)
        } else if current == minimal {
            yPosition = (height / 2) - (width / 2)
        } else {
            if current > mean {
                yPosition = -((height / 2) * ((current - minimal) / (maximal - minimal)) - (width / 2))
            } else if current == mean {
                yPosition = height / 2
            } else {
                yPosition = (height / 2 - width / 2) - ((height / 2) * ((current - minimal) / (maximal - minimal)))
            }
        }
    }

    var body: some View {
        VStack {
            Circle()
                .foregroundColor(circleColor)
                .frame(width: width, height: width)
                .offset(x: 0, y: yPosition)
        }
        .frame(width: width, height: height)
    }
}

struct CirclesChartElementView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            CircleChartElementView(maximal: 70, minimal: 55, mean: 62.5, current: 70, circleColor: .red, height: 300, width: 100)
        }
    }
}

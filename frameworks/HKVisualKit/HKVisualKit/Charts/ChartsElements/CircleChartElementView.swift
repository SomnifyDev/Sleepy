import SwiftUI

/// Элемент графика с кружочками на разной высоте
/// - Parameters:
///  - maximal: максимальное значение среди данных
///  - min: минимальное значение среди данных
///  - mean: среднее значение данных
///  - current: значение, для которого нужно построить элемент
///  - color: цвет отображения
struct CircleChartElementView: View {

    private var topSpacerHeight: Double = 0
    private var bottomSpacerHeight: Double = 0
    private let circleColor: Color
    private let mean: Double
    private let height: CGFloat
    private let width: CGFloat

    init(maximal: Double, minimal: Double, mean: Double, current: Double, circleColor: Color, height: CGFloat, width: CGFloat) {
        self.mean = mean
        self.circleColor = circleColor
        self.height = height
        self.width = width

        if current == maximal {
            topSpacerHeight = 0
            bottomSpacerHeight = height - min(height, width)
        } else if current == minimal {
            topSpacerHeight = height - min(height, width)
            bottomSpacerHeight = 0
        } else {
            if current > mean {
                topSpacerHeight = 0
                bottomSpacerHeight = (height - min(height, width)) * abs(current - mean)/(maximal - mean)
            } else if current < mean {
                topSpacerHeight = (height - min(height, width)) * abs(current - mean)/(maximal - mean)
                bottomSpacerHeight = 0
            }
        }
    }

    var body: some View {
        VStack {
            Spacer(minLength: topSpacerHeight)
            Circle()
                .foregroundColor(circleColor)
                .frame(width: width, height: height)
            Spacer(minLength: bottomSpacerHeight)
        }
        .frame(width: width, height: height)
    }
}

struct CirclesChartElementView_Previews: PreviewProvider {
    static var previews: some View {
        CircleChartElementView(maximal: 70, minimal: 55, mean: 62.5, current: 65, circleColor: .red, height: 100, width: 50)
    }
}

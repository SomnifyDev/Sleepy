import SwiftUI

/// График с кружочками, двигающимися по высоте графика
/// - Parameters:
///  - points: значения для элементов графика
///  - dragGestureData: строковые элементы для отображения при dragGesture
///  - chartColor: цвет отображения
public struct CirclesChartView: View {

    @State private var totalHeight = CGFloat.zero // variant for ScrollView/List
    // = CGFloat.infinity - variant for VStack
    private let dragGestureData: String?
    private let points: [Double]
    private let chartColor: Color
    private let chartHeight: CGFloat
    private let needOXLine: Bool
    private let needTimeLine: Bool
    private let startTime: String?
    private let endTime: String?
    private let colorProvider: ColorSchemeProvider

    public init(colorProvider: ColorSchemeProvider,
                points: [Double],
                dragGestureData: String?,
                chartColor: Color,
                chartHeight: CGFloat,
                needOXLine: Bool,
                needTimeLine: Bool,
                startTime: String?,
                endTime: String?) {
        self.colorProvider = colorProvider
        self.points = points
        self.dragGestureData = dragGestureData
        self.chartColor = chartColor
        self.chartHeight = chartHeight
        self.needOXLine = needOXLine
        self.needTimeLine = needTimeLine
        self.startTime = startTime
        self.endTime = endTime
    }

    public var body: some View {
        VStack {
            GeometryReader { geometry in
                VStack {
                    HStack (spacing: 2) {
                        let min = points.min()!
                        let max = points.max()!
                        let mean = (max + min) / 2.0
                        ForEach(0 ..< points.count, id: \.self) { index in
                            VStack {
                                CircleChartElementView(maximal: max,
                                                       minimal: min,
                                                       mean: mean,
                                                       current: points[index],
                                                       circleColor: chartColor,
                                                       height: chartHeight,
                                                       width: abs((geometry.size.width - 2 * CGFloat(points.count - 1))) / CGFloat(points.count))
                                if needOXLine {
                                    getOXLineElement()
                                }
                            }
                        }
                    }
                    if needTimeLine,
                       let startTime = startTime,
                       let endTime = endTime {
                        TimeLineView(colorProvider: colorProvider, startTime: startTime, endTime: endTime)
                    }
                }
                .background(viewHeightReader($totalHeight))
            }
        }
        .frame(height: totalHeight) // - variant for ScrollView/List
        //.frame(maxHeight: totalHeight) - variant for VStack
    }

    private func getOXLineElement() -> some View {
        let width: CGFloat = 2,
            height: CGFloat = 3,
            topPadding: CGFloat = 4,
            opacity: CGFloat = 0.1

        return Rectangle()
            .frame(width: width, height: height, alignment: .center)
            .opacity(opacity)
            .padding(.top, topPadding)
    }
    
    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}

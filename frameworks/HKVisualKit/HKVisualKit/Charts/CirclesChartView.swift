import SwiftUI

/// График с кружочками, двигающимися по высоте графика
/// - Parameters:
///  - points: значения для элементов графика
///  - dragGestureData: строковые элементы для отображения при dragGesture
///  - chartColor: цвет отображения
public struct CirclesChartView: View {

    @State private var selectedIndex = -1
    @State private var totalHeight = CGFloat.zero // variant for ScrollView/List
    // = CGFloat.infinity - variant for VStack
    private let points: [Double]
    private let chartColor: Color
    private let chartHeight: CGFloat
    private let needOXLine: Bool
    private let needTimeLine: Bool
    private let dateInterval: DateInterval?
    private let dragGestureEnabled: Bool
    private let colorProvider: ColorSchemeProvider

    private let chartSpacing: CGFloat = 2

    public init(colorProvider: ColorSchemeProvider,
                points: [Double],
                chartColor: Color,
                chartHeight: CGFloat,
                dateInterval: DateInterval?,
                needOXLine: Bool = true,
                needTimeLine: Bool = true,
                dragGestureEnabled: Bool = true) {
        self.colorProvider = colorProvider
        self.points = points
        self.chartColor = chartColor
        self.chartHeight = chartHeight
        self.needOXLine = needOXLine
        self.needTimeLine = needTimeLine
        self.dragGestureEnabled = dragGestureEnabled
        self.dateInterval = dateInterval
    }

    public var body: some View {
        VStack {
            GeometryReader { geometry in
                VStack {
                    HStack (spacing: chartSpacing) {
                        let min = points.min()!
                        let max = points.max()!
                        let mean = (max + min) / 2.0
                        ForEach(0 ..< points.count, id: \.self) { index in
                            VStack {
                                if selectedIndex == index {
                                    CircleChartElementView(maximal: max,
                                                           minimal: min,
                                                           mean: mean,
                                                           current: points[index],
                                                           circleColor: chartColor,
                                                           height: chartHeight,
                                                           width: abs((geometry.size.width - 2 * CGFloat(points.count - 1))) / CGFloat(points.count))
                                        .colorInvert()
                                } else {
                                    CircleChartElementView(maximal: max,
                                                           minimal: min,
                                                           mean: mean,
                                                           current: points[index],
                                                           circleColor: chartColor,
                                                           height: chartHeight,
                                                           width: abs((geometry.size.width - 2 * CGFloat(points.count - 1))) / CGFloat(points.count))
                                }
                                if needOXLine {
                                    getOXLineElement()
                                }
                            }
                        }
                    }
                    .allowsHitTesting(dragGestureEnabled)
                    .gesture(DragGesture(minimumDistance: 5, coordinateSpace: .global).onChanged { gesture in
                        let selected = Int(gesture.location.x / ( geometry.size.width / (CGFloat(points.count) - chartSpacing)))

                        if selected != selectedIndex && selected < points.count {
                            selectedIndex = selected
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.6)
                        }
                    }.onEnded { _ in
                        selectedIndex = -1
                    })

                    if needTimeLine,
                       let startTime = self.dateInterval?.start,
                       let endTime = self.dateInterval?.end {
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

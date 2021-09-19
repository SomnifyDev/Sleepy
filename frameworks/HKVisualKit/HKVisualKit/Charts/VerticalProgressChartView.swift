import SwiftUI

/// График вертикального прогресса
/// - Parameters:
///  - chartColor: цвет графика
///  - points: значения в процентах по выполнению какой-либо цели
///  - dragGestureData: строковые элементы для отображения при dragGesture
///  - needDragGesture: true, если нужен dragGesture  
public struct VerticalProgressChartView: View {

    @State private var totalHeight = CGFloat.zero // variant for ScrollView/List
    // = CGFloat.infinity - variant for VStack
    @State private var selectedIndex = -1

    private let foregroundElementColor: Color
    private let backgroundElementColor: Color
    private let points: [Double]
    private let chartHeight: CGFloat
    private let dragGestureEnabled: Bool

    private let chartSpacing: CGFloat = 10

    public init(foregroundElementColor: Color, backgroundElementColor: Color, chartHeight: CGFloat, points: [Double], dragGestureEnabled: Bool = true) {
        self.foregroundElementColor = foregroundElementColor
        self.backgroundElementColor = backgroundElementColor
        self.chartHeight = chartHeight
        self.points = points
        self.dragGestureEnabled = dragGestureEnabled
    }

    public var body: some View {
        VStack {
            GeometryReader { geometry in
                HStack (spacing: 10) {
                    ForEach(0 ..< points.count, id: \.self) { index in
                        if selectedIndex == index {
                            VerticalProgressElementView(percentage: points[index],
                                                        foregroundElementColor: foregroundElementColor,
                                                        backgroundElementColor: backgroundElementColor,
                                                        height: chartHeight)
                                .colorInvert()
                        } else {

                            VerticalProgressElementView(percentage: points[index],
                                                        foregroundElementColor: foregroundElementColor,
                                                        backgroundElementColor: backgroundElementColor,
                                                        height: chartHeight)
                        }
                    }
                }
                .background(viewHeightReader($totalHeight))
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
            }
        }
        .frame(height: totalHeight) // - variant for ScrollView/List
        //.frame(maxHeight: totalHeight) - variant for VStack
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

import SwiftUI

/// График вертикального прогресса
/// - Parameters:
///  - chartColor: цвет графика
///  - points: значения в процентах по выполнению какой-либо цели
///  - dragGestureData: строковые элементы для отображения при dragGesture
///  - needDragGesture: true, если нужен dragGesture  
public struct VerticalProgressChartView: View {

    private let foregroundElementColor: Color
    private let backgroundElementColor: Color
    private let dragGestureData: String?
    private let points: [Double]
    private let needDragGesture: Bool
    private let chartHeight: CGFloat

    public init(foregroundElementColor: Color, backgroundElementColor: Color, chartHeight: CGFloat, points: [Double], dragGestureData: String? = nil, needDragGesture: Bool) {
        self.foregroundElementColor = foregroundElementColor
        self.backgroundElementColor = backgroundElementColor
        self.chartHeight = chartHeight
        self.dragGestureData = dragGestureData
        self.points = points
        self.needDragGesture = needDragGesture
    }

    public var body: some View {
        HStack (spacing: 10) {
            ForEach(0 ..< points.count, id: \.self) { index in
                VerticalProgressElementView(percentage: points[index],
                                            foregroundElementColor: foregroundElementColor,
                                            backgroundElementColor: backgroundElementColor,
                                            height: chartHeight)
            }
        }
        .gesture(getDrugGesture())
    }

    private func getDrugGesture() -> some Gesture {
        return DragGesture(minimumDistance: 3, coordinateSpace: .local)
            .onChanged { gesture in
                if needDragGesture {
                    // TODO: drag gesture
                }
            }
    }
}

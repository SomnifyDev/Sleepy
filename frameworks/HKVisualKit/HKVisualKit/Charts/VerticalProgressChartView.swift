import SwiftUI

/// График вертикального прогресса
/// Параметры:
///     - points: значения в процентах по выполнению какой-либо цели
struct VerticalProgressChartView: View {

    private let chartColor: Color
    private let dragGestureData: [String]?
    private let points: [Double]
    private let needDragGesture: Bool

    init(chartColor: Color, points: [Double], dragGestureData: [String]? = nil, needDragGesture: Bool) {
        self.chartColor = chartColor
        self.dragGestureData = dragGestureData
        self.points = points
        self.needDragGesture = needDragGesture
    }

    var body: some View {
        GeometryReader { geometry in
            HStack (spacing: 3) {
                ForEach(0 ..< points.count, id: \.self) { index in
                    VerticalProgressElementView(percentage: points[index], color: .green)
                }
            }
            .gesture(getDrugGesture())
        }
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

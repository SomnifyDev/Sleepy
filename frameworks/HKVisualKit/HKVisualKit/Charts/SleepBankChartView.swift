import SwiftUI

/// График банка сна
/// Параметры:
///     - points: значения в процентах по каждому из 14 дней для построения графика
struct SleepBankChartView: View {

    @State private var elemWidth: CGFloat = 0
    private let colorProvider: ColorSchemeProvider
    private let standardWidth: CGFloat = 14
    private let chartSpacing: CGFloat = 3
    private let data: [String: Double]
    private let points: [Double]
    private let needDragGesture: Bool

    init(colorProvider: ColorSchemeProvider, data: [String: Double], needDragGesture: Bool) {
        self.colorProvider = colorProvider
        self.data = data
        self.points = data.map({$0.value})
        self.needDragGesture = needDragGesture
    }

    var body: some View {
        GeometryReader { geometry in
            HStack (spacing: 3) {
                ForEach(0 ..< points.count, id: \.self) { index in
                    SleepBankElementView(sleepPercentage: points[index], color: .green)
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

struct SleepBankChartView_Previews: PreviewProvider {
    static var previews: some View {
        SleepBankChartView(colorProvider: ColorSchemeProvider(), data: [:], needDragGesture: false)
    }
}

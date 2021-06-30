import SwiftUI

/// Стандартный график (для фаз, сердца)
/// Параметры:
///     - points: значения для элементов графика
///     - color: цвет отображения
struct StandardChartView: View {

    @State var elemWidth: CGFloat

    private let colorProvider: ColorSchemeProvider
    private let points: [Double]
    private let chartColor: Color
    private let needOXLine: Bool
    private let chartType: StandardChartType
    private let needDragGesture: Bool

    private let maxHeightOfElement: CGFloat = 80
    private let standardWidth: CGFloat = 14
    private let chartSpacing: CGFloat = 3
    private let chartWidth: CGFloat

    init(colorProvider: ColorSchemeProvider, points: [Double], chartColor: Color, needOXLine: Bool, chartType: StandardChartType, needDragGesture: Bool) {
        self.colorProvider = colorProvider
        self.points = points
        self.chartColor = chartColor
        self.needOXLine = needOXLine
        self.chartType = chartType
        self.needDragGesture = needDragGesture
        self.chartWidth = CGFloat(points.count) * standardWidth + chartSpacing * CGFloat(points.count - 1)
        self.elemWidth = standardWidth
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                HStack(alignment: .bottom, spacing: chartSpacing) {
                    ForEach(0 ..< points.count, id: \.self) { index in
                        let height = maxHeightOfElement * (points[index] / points.max()!)
                        VStack {
                            getChartElement(for: chartType, width: elemWidth, height: height, value: points[index])
                            if needOXLine {
                                getOXLineElement()
                            }
                        }
                    }
                }
                .gesture(getDrugGesture())
            }
            .frame(width: geometry.size.width)
            .onAppear {
                if chartWidth > geometry.size.width {
                    self.elemWidth = abs((geometry.size.width - chartSpacing * CGFloat(points.count - 1))) / CGFloat(points.count)
                }
            }
        }
    }

    private func getChartElement(for chartType: StandardChartType, width: CGFloat, height: CGFloat, value: Double) -> some View {
        switch chartType {
        case .phasesChart:
            return StandardChartElementView(width: elemWidth, height: height, color: getPhaseColor(for: value))
        case .defaultChart:
            return StandardChartElementView(width: elemWidth, height: height, color: chartColor)
        }
    }

    private func getPhaseColor(for value: Double) -> Color {
        return value < 0.55 ? colorProvider.sleepyColorScheme.deepSleepColor : value > 1 ? colorProvider.sleepyColorScheme.awakeColor : colorProvider.sleepyColorScheme.lightSleepColor
    }

    private func getDrugGesture() -> some Gesture {
        return DragGesture(minimumDistance: 3, coordinateSpace: .local)
            .onChanged { gesture in
                if needDragGesture {
                    // TODO drag gesture. Пока убил кучу времени - не знаю, как его сделать правильно
                }
            }
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        StandardChartView(colorProvider: ColorSchemeProvider(), points: [12, 32, 23, 21, 54, 32, 33], chartColor: .green, needOXLine: true, chartType: .defaultChart, needDragGesture: true)
    }
}

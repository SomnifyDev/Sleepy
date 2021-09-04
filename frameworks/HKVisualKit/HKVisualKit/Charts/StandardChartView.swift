import SwiftUI

/// Стандартный график (для фаз, сердца)
/// - Parameters:
///  - colorProvider: ColorProvider
///  - points: значения для элементов графика
///  - chartColor: цвет отображения
///  - needOXLine: true, если снизу графика нужна линия OX
///  - chartType: тип графика
///  - needDragGesture: true, если нужен dragGesture
public struct StandardChartView: View {

    @State private var selectedIndex = -1
    @State private var elemWidth: CGFloat = 14
    private let chartHeight: CGFloat
    private let colorProvider: ColorSchemeProvider
    private let chartType: StandardChartType
    private let points: [Double]
    private let chartColor: Color?
    private let dateInterval: DateInterval?
    private let needOXLine: Bool
    private let needTimeLine: Bool
    private let dragGestureEnabled: Bool

    private let standardWidth: CGFloat = 14
    private let chartSpacing: CGFloat = 3

    public init(colorProvider: ColorSchemeProvider,
                chartType: StandardChartType,
                chartHeight: CGFloat,
                points: [Double],
                chartColor: Color?,
                dateInterval: DateInterval?,
                needOXLine: Bool = true,
                needTimeLine: Bool = true,
                dragGestureEnabled: Bool = true) {
        self.colorProvider = colorProvider
        self.points = points
        self.chartHeight = chartHeight
        self.chartColor = chartColor
        self.needOXLine = needOXLine
        self.chartType = chartType
        self.dragGestureEnabled = dragGestureEnabled
        self.needTimeLine = needTimeLine
        self.dateInterval = dateInterval
    }

    public var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                HStack(alignment: .bottom, spacing: chartSpacing) {
                    ForEach(0 ..< points.count, id: \.self) { index in
                        if let max = points.max() {
                            let height = chartHeight * (points[index] / max)
                            VStack {
                                if selectedIndex == index {
                                    getChartElement(for: chartType, width: elemWidth, height: height, value: points[index])
                                        .colorInvert()
                                } else {
                                    getChartElement(for: chartType, width: elemWidth, height: height, value: points[index])
                                }

                                if needOXLine {
                                    getOXLineElement()
                                }
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
                   let startTime = dateInterval?.start,
                   let endTime = dateInterval?.start {
                    TimeLineView(colorProvider: colorProvider, startTime: startTime, endTime: endTime)
                }
            }
            .frame(width: geometry.size.width)
            .onAppear {
                let chartWidth = CGFloat(points.count) * standardWidth + chartSpacing * CGFloat(points.count - 1)
                if chartWidth > geometry.size.width {
                    self.elemWidth = abs((geometry.size.width - chartSpacing * CGFloat(points.count - 1))) / CGFloat(points.count)
                }
            }
        }
        .frame(height: chartHeight + (needOXLine ? 15 : 0) + (needTimeLine ? 15 : 0))
    }

    private func getChartElement(for chartType: StandardChartType, width: CGFloat, height: CGFloat, value: Double) -> some View {
        switch chartType {
        case .phasesChart:
            return StandardChartElementView(width: elemWidth, height: height, color: getPhaseColor(for: value))
        case .defaultChart:
            return StandardChartElementView(width: elemWidth, height: height, color: chartColor ?? .clear)
        }
    }

    private func getPhaseColor(for value: Double) -> Color {
        return value < 0.55
        ? colorProvider.sleepyColorScheme.getColor(of: .phases(.deepSleepColor))
        : value >= 1
        ? colorProvider.sleepyColorScheme.getColor(of: .phases(.wakeUpColor))
        : colorProvider.sleepyColorScheme.getColor(of: .phases(.lightSleepColor))
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

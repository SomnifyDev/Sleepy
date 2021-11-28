// Copyright (c) 2021 Sleepy.

import SwiftUI

private enum Constants {
	static let descriptionHeight: CGFloat = 13
	static let standardWidth: CGFloat = 14
	static let tapDescriptionHeight: CGFloat = 16
	static let stackSpacing: CGFloat = 4
}

public enum StandardChartType {
	case phasesChart
	case defaultChart(barType: BarType)
	case verticalProgress(foregroundElementColor: Color, backgroundElementColor: Color, max: Double)
}

/// Стандартный график (для фаз, сердца)
/// - Parameters:
///  - colorProvider: ColorProvider
///  - points: значения для элементов графика
///  - chartColor: цвет отображения
///  - needOXLine: true, если снизу графика нужна линия OX
///  - chartType: тип графика
///  - needDragGesture: true, если нужен dragGesture
public struct StandardChartView: View {
	@State private var totalHeight = CGFloat.zero // variant for ScrollView/List
	// = CGFloat.infinity - variant for VStack

	@State private var selectedIndex = -1
	@State private var elemWidth: CGFloat = 14
	@State private var chartSpacing: CGFloat = 3
	private let chartHeight: CGFloat
	private let colorProvider: ColorSchemeProvider
	private let chartType: StandardChartType
	private let points: [Double]
	private let dateInterval: DateInterval?
	private let needOXLine: Bool
	private let needTimeLine: Bool
	private let dragGestureEnabled: Bool

	public init(colorProvider: ColorSchemeProvider,
	            chartType: StandardChartType,
	            chartHeight: CGFloat,
	            points: [Double],
	            dateInterval: DateInterval?,
	            needOXLine: Bool = true,
	            needTimeLine: Bool = true,
	            dragGestureEnabled: Bool = true)
	{
		self.colorProvider = colorProvider
		self.points = points
		self.chartHeight = chartHeight
		self.needOXLine = needOXLine
		self.chartType = chartType
		self.dragGestureEnabled = dragGestureEnabled
		self.needTimeLine = needTimeLine
		self.dateInterval = dateInterval
	}

	public var body: some View {
		VStack {
			GeometryReader { geometry in
				VStack(alignment: .center, spacing: Constants.stackSpacing) {
					if self.dragGestureEnabled {
						Text(self.selectedIndex >= 0 ? self.getTapDescription(for: self.selectedIndex) : "")
							.frame(height: Constants.tapDescriptionHeight)
					}

					HStack(alignment: .bottom, spacing: self.chartSpacing) {
						ForEach(0 ..< self.points.count, id: \.self) { index in

							VStack {
								if selectedIndex == index {
									getChartElement(for: chartType, width: elemWidth, value: points[index])
										.colorInvert()
								} else {
									getChartElement(for: chartType, width: elemWidth, value: points[index])
								}

								if needOXLine {
									getOXLineElement()
								}
							}

							switch self.chartType {
							case .verticalProgress:
								if index != self.points.count - 1 {
									Spacer()
								}
							default:
								EmptyView()
							}
						}
					}
					.frame(height: chartHeight + Constants.tapDescriptionHeight + (needOXLine ? 2 * Constants.stackSpacing : 0))
					.allowsHitTesting(dragGestureEnabled)
					.gesture(DragGesture(minimumDistance: 5, coordinateSpace: .global).onChanged { gesture in
						let selected = Int(gesture.location.x / (geometry.size.width / (CGFloat(points.count) - self.chartSpacing)))

						if selected != selectedIndex, selected < points.count {
							selectedIndex = selected
							UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.6)
						}
					}.onEnded { _ in
						selectedIndex = -1
					})

					if needTimeLine,
					   let startTime = dateInterval?.start,
					   let endTime = dateInterval?.end
					{
						TimeLineView(colorProvider: colorProvider, startTime: startTime, endTime: endTime)
					}
				}
				.background(viewHeightReader($totalHeight))
				.frame(width: geometry.size.width)
				.onAppear {
					let chartWidth = CGFloat(points.count) * Constants.standardWidth + self.chartSpacing * CGFloat(points.count - 1)
					if chartWidth > geometry.size.width {
						self.elemWidth = abs(geometry.size.width - self.chartSpacing * CGFloat(points.count - 1)) / CGFloat(points.count)
					}

					switch self.chartType {
					case .verticalProgress:
						self.chartSpacing = 0
					default:
						self.chartSpacing = 3
					}
				}
			}
		}.frame(height: totalHeight) // - variant for ScrollView/List
	}

	private func getChartElement(for chartType: StandardChartType, width _: CGFloat, value: Double) -> some View {
		let minimum = self.points.min() ?? 0
		let maximum = self.points.max() ?? 0

		let height = max(chartHeight * 0.2, chartHeight * ((value - minimum) / (maximum - minimum)))

		switch chartType {
		case .phasesChart:
			return StandardChartElementView(width: self.elemWidth, height: height, type: .rectangle(color: self.getPhaseColor(for: value)))
		case let .defaultChart(barType):
			return StandardChartElementView(width: self.elemWidth, height: height, type: barType)
		case let .verticalProgress(foregroundElementColor, backgroundElementColor, max):
			return StandardChartElementView(width: self.elemWidth, height: self.chartHeight, type: .filled(foregroundElementColor: foregroundElementColor, backgroundElementColor: backgroundElementColor, percentage: value / max))
		}
	}

	private func getPhaseColor(for value: Double) -> Color {
		return value < 0.55
			? self.colorProvider.sleepyColorScheme.getColor(of: .phases(.deepSleepColor))
			: value >= 1
			? self.colorProvider.sleepyColorScheme.getColor(of: .phases(.wakeUpColor))
			: self.colorProvider.sleepyColorScheme.getColor(of: .phases(.lightSleepColor))
	}

	private func getTapDescription(for index: Int) -> String {
		guard let dateIntervalSeconds = self.dateInterval?.duration,
		      let sampleDate = self.dateInterval?.start.addingTimeInterval(TimeInterval(Int(dateIntervalSeconds) / self.points.count * index)) else { return "" }
		let value = self.points[index]

		var finalString = ""
		switch self.chartType {
		case .phasesChart:
			finalString = (value < 0.55
				? "Deep sleep phase"
				: (value >= 1
					? "Probably woke up"
					: "Light sleep phase"))
		default:
			finalString = String(format: "%.0f", self.points[self.selectedIndex])
		}
		return finalString + ", \(sampleDate.getFormattedDate(format: "HH:mm"))"
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

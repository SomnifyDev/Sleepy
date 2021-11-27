// Copyright (c) 2021 Sleepy.

import SwiftUI

/// Элемент стандартного графика
/// - Parameters:
///  - width: ширина элемента
///  - height: высота элементе
///  - color: цвет отображения
struct StandardChartElementView: View {
	private let cornerRadius: Double = 50
	private let width: CGFloat
	private let height: CGFloat
	private let type: BarType

	init(width: CGFloat, height: CGFloat, type: BarType) {
		self.width = width
		self.height = height
		self.type = type
	}

	var body: some View {
		VStack {
			switch type {
			case let .rectangle(color):
				Rectangle()
					.foregroundColor(color)
					.cornerRadius(cornerRadius)

			case let .circle(color):
				ZStack(alignment: .top) {
					Rectangle()
						.foregroundColor(Color.clear)
					Circle()
						.foregroundColor(color)
						.frame(width: width, height: width)
				}

			case let .filled(foregroundElementColor, backgroundElementColor, percentage):
				ZStack(alignment: .bottom) {
					Rectangle()
						.fill(backgroundElementColor)
						.cornerRadius(cornerRadius)

					Rectangle()
						.fill(foregroundElementColor)
						.frame(height: min(height * percentage, height))
						.cornerRadius(cornerRadius)
				}
			}
		}.frame(width: width, height: height)
	}
}

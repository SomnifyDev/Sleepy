// Copyright (c) 2021 Sleepy.

import SwiftUI

public struct HorizontalStatisticCellView: View {
	private var data: [StatisticsCellData]
	private var colorScheme: SleepyColorScheme

	public init(data: [StatisticsCellData], colorScheme: SleepyColorScheme) {
		self.data = data
		self.colorScheme = colorScheme
	}

	public var body: some View {
		VStack(spacing: -8) {
			ForEach(data, id: \.self) { cellInfo in
				HStack {
					Text(cellInfo.title)
						.regularTextModifier(color: colorScheme.getColor(of: .textsColors(.standartText)))

					Spacer()

					Text(cellInfo.value)
						.semiboldTextModifier(color: colorScheme.getColor(of: .textsColors(.standartText)))
				}
			}
			.roundedCardBackground(color: colorScheme.getColor(of: .card(.cardBackgroundColor)))
		}
	}
}

public struct StatisticsCellData: Hashable {
	public let title: String
	public let value: String

	public init(title: String, value: String) {
		self.title = title
		self.value = value
	}
}

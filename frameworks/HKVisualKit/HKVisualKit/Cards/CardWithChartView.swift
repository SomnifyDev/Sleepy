// Copyright (c) 2021 Sleepy.

import SwiftUI

public struct CardWithChartView<T: View, U: View>: View {
	@State private var totalHeight = CGFloat.zero // variant for ScrollView/List
	// = CGFloat.infinity - variant for VStack

	private let colorProvider: ColorSchemeProvider
	private let systemImageName: String
	private let titleText: String
	private let mainTitleText: String?
	private let titleColor: Color
	private let showChevron: Bool
	private let chartView: T
	private let bottomView: U

	public init(colorProvider: ColorSchemeProvider, systemImageName: String, titleText: String, mainTitleText: String?, titleColor: Color, showChevron: Bool, chartView: T, bottomView: U) {
		self.colorProvider = colorProvider
		self.systemImageName = systemImageName
		self.titleText = titleText
		self.mainTitleText = mainTitleText
		self.titleColor = titleColor
		self.showChevron = showChevron
		self.chartView = chartView
		self.bottomView = bottomView
	}

	/// Use for shimmers only
	public init(colorProvider: ColorSchemeProvider, color: Color, chartType: StandardChartType) {
		self.colorProvider = colorProvider
		self.systemImageName = "person"
		self.titleText = "tfklw"
		self.mainTitleText = "some long description in order to fill blur card with"
		self.titleColor = color
		self.showChevron = false
		self.chartView = StandardChartView(colorProvider: colorProvider,
		                                   chartType: chartType,
		                                   chartHeight: 75,
		                                   points: [13, 23, 10, 15, 30, 23, 25, 26, 30, 13, 23, 10, 15, 30, 23, 25, 26, 30, 13, 23, 10, 15, 30, 23, 25, 26, 30],
		                                   dateInterval: DateInterval(start: Date(), end: Date()),
		                                   dragGestureEnabled: false) as! T
		self.bottomView = EmptyView() as! U
	}

	public var body: some View {
		VStack {
			GeometryReader { _ in
				VStack(alignment: .leading) {
					CardTitleView(titleText: self.titleText,
					              mainText: self.mainTitleText,
					              leftIcon: Image(systemName: self.systemImageName),
					              rightIcon: showChevron ? Image(systemName: "chevron.right") : nil,
					              titleColor: self.titleColor,
					              mainTextColor: self.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)),
					              colorProvider: self.colorProvider)

					chartView
						.padding(.top, 8)

					bottomView
				}
				.background(viewHeightReader($totalHeight))
			}
		}.frame(height: totalHeight) // - variant for ScrollView/List
		// .frame(maxHeight: totalHeight) - variant for VStack
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

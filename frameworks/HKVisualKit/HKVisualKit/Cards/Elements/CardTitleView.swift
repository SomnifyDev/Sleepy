// Copyright (c) 2021 Sleepy.

import SwiftUI

public struct CardTitleView: View {
	@State private var totalHeight = CGFloat.zero // variant for ScrollView/List
	// = CGFloat.infinity - variant for VStack

	private let titleText: String
	private let mainText: String?
	private let leftIcon: Image
	private let rightIcon: Image?
	private let navigationText: String?
	private let titleColor: Color
	private let mainTextColor: Color?
	private let showSeparator: Bool
	private let colorProvider: ColorSchemeProvider
	var onCloseTapAction: (() -> Void)?

	public init(titleText: String,
	            mainText: String? = nil,
	            leftIcon: Image,
	            rightIcon: Image? = nil,
	            navigationText: String? = nil,
	            titleColor: Color,
	            mainTextColor: Color? = nil,
	            showSeparator: Bool = true,
	            colorProvider: ColorSchemeProvider,
	            onCloseTapAction: (() -> Void)? = nil)
	{
		self.titleText = titleText
		self.mainText = mainText
		self.leftIcon = leftIcon
		self.rightIcon = rightIcon
		self.navigationText = navigationText
		self.titleColor = titleColor
		self.mainTextColor = mainTextColor
		self.showSeparator = showSeparator
		self.colorProvider = colorProvider
		self.onCloseTapAction = onCloseTapAction
	}

	public var body: some View {
		VStack {
			GeometryReader { _ in
				VStack(alignment: .leading, spacing: 4) {
					HStack {
						leftIcon
							.foregroundColor(titleColor)

						Text(titleText)
							.cardTitleTextModifier(color: titleColor)

						Spacer()

						if let navigationText = navigationText {
							Text(navigationText)
								.cardTitleTextModifier(color: titleColor)
								.lineLimit(1)
						}

						if let rightIcon = rightIcon {
							rightIcon
								.foregroundColor(titleColor)
								.onTapGesture {
									if rightIcon == Image(systemName: "xmark.circle") {
										self.onCloseTapAction?()
									}
								}
						}
					}

					if let mainText = mainText,
					   let mainTextColor = mainTextColor
					{
						Text(mainText)
							.cardDescriptionTextModifier(color: mainTextColor)
					}

					if showSeparator {
						Divider()
							.padding(.top, 4)
					}
				}.background(viewHeightReader($totalHeight))
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

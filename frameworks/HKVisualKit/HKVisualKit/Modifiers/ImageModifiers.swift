// Copyright (c) 2021 Sleepy.

import SwiftUI

public extension Image {
	func summaryCardImage(color: Color, size: CGFloat, width: CGFloat) -> some View {
		foregroundColor(color)
			.font(.system(size: size, weight: .bold))
			.frame(width: width)
	}
}

// Copyright (c) 2021 Sleepy.

import SwiftUI

struct NavItemView: View {
	private let imageName: String
	private let title: String
	private let titleColor: Color
	private let mainInfo: String
	private let bottomTitle: String

	init(
		imageName: String,
		title: String,
		titleColor: Color,
		mainInfo: String,
		bottomTitle: String
	) {
		self.imageName = imageName
		self.title = title
		self.titleColor = titleColor
		self.mainInfo = mainInfo
		self.bottomTitle = bottomTitle
	}

	var body: some View {
		HStack {
			VStack(alignment: .leading, spacing: 2) {
				HStack {
					Image(systemName: imageName)
						.foregroundColor(titleColor)
						.font(.system(size: 12))
					Text(title)
						.foregroundColor(titleColor)
						.font(.system(size: 12))
				}
				Text(mainInfo)
					.font(.title2)
				Text(bottomTitle)
					.font(.system(size: 14))
					.opacity(0.6)
			}
			.padding()
			Spacer()
			Image(systemName: "chevron.forward")
				.foregroundColor(.white)
				.opacity(0.5)
				.padding(.trailing)
		}
	}
}

struct NavItemView_Previews: PreviewProvider {
	static var previews: some View {
		NavItemView(
			imageName: "zzz",
			title: "Title",
			titleColor: .blue,
			mainInfo: "Main info",
			bottomTitle: "Bottom title"
		)
	}
}

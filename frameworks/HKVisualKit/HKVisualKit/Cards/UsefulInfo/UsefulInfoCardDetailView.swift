// Copyright (c) 2021 Sleepy.

import SwiftUI

public struct UsefulInfoCardDetailView: View {
	@Binding var showSleepImportanceView: Bool
	private let navigationBarTitle: String
	private let mainImageName: String
	private let mainTextTitle: String
	private let mainTextParagraphs: [String]

	init(showSleepImportanceView: Binding<Bool>, navigationBarTitle: String, mainImageName: String, mainTextTitle: String, mainTextParagraphs: [String]) {
		_showSleepImportanceView = showSleepImportanceView
		self.navigationBarTitle = navigationBarTitle
		self.mainImageName = mainImageName
		self.mainTextTitle = mainTextTitle
		self.mainTextParagraphs = mainTextParagraphs
	}

	public var body: some View {
		GeometryReader { g in
			NavigationView {
				ScrollView {
					VStack(alignment: .leading) {
						Image(mainImageName)
							.resizable()
							.frame(width: g.size.width, height: 250)
						Text(mainTextTitle)
							.font(.title)
							.bold()

						ForEach(mainTextParagraphs, id: \.self) { paragraph in
							Text(paragraph)
								.padding(.top)
						}

						Spacer()
					}
					.padding([.top, .trailing, .leading])
				}
				.navigationBarTitleDisplayMode(.inline)
				.navigationTitle(navigationBarTitle)
				.navigationBarItems(trailing:
					Button(action: {
						self.showSleepImportanceView = false
					}, label: {
						Text("Done")
							.fontWeight(.regular)
					}))
			}
		}
	}
}

struct UsefulInfoCardDetailView_Previews: PreviewProvider {
	static var previews: some View {
		UsefulInfoCardDetailView(showSleepImportanceView: .constant(false),
		                         navigationBarTitle: "Navigation title",
		                         mainImageName: "sleep1",
		                         mainTextTitle: "mainTextTitle",
		                         mainTextParagraphs: ["mainTextParagraphs1", "mainTextParagraphs2"])
	}
}

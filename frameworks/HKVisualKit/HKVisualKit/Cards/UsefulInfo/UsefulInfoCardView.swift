// Copyright (c) 2021 Sleepy.

import SwiftUI

public struct UsefulInfoCardView<Content>: View where Content: View {
	@State private var totalHeight = CGFloat.zero
	@Binding var showModalView: Bool
	private let destinationView: Content
	private let imageName: String
	private let title: String
	private let description: String

	public init(imageName: String, title: String, description: String, destinationView: Content, showModalView: Binding<Bool>) {
		self.imageName = imageName
		self.title = title
		self.description = description
		self.destinationView = destinationView
		_showModalView = showModalView
	}

	public var body: some View {
		Button(action: {
			self.showModalView.toggle()
		}, label: {
			VStack {
				GeometryReader { geometry in
					VStack {
						Image(imageName)
							.resizable()
							.frame(width: geometry.size.width, height: 235)

						VStack(spacing: 16) {
							HStack {
								Text(title)
									.fontWeight(.bold)
									.font(.title2)
								Spacer()
							}

							HStack {
								Text(description)
									.fixedSize(horizontal: false, vertical: true)
									.font(.none)
								Spacer()
							}
						}
						.padding()

						Spacer()
					}
					.background(viewHeightReader($totalHeight))
					.cornerRadius(10)
				}
			}
		})
		.frame(height: totalHeight)
		.buttonStyle(PlainButtonStyle())
		.sheet(isPresented: $showModalView, content: {
			destinationView
		})
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

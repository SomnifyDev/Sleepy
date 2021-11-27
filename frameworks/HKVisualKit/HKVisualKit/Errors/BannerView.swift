// Copyright (c) 2021 Sleepy.

import SwiftUI

public struct BannerView: View {
	// MARK: Enums

	public enum AdviceType: String {
		case wearMore
		case soundRecording
		case some
	}

	public enum BannerViewType: Equatable {
		case emptyData(type: HealthData)
		case brokenData(type: HealthData)
		case restrictedData(type: HealthData)
		case advice(type: AdviceType, imageSystemName: String? = nil)

		public static func == (lhs: BannerViewType, rhs: BannerViewType) -> Bool {
			switch (lhs, rhs) {
			case (.brokenData, .brokenData):
				return true
			case (.emptyData, .emptyData):
				return true
			case (.restrictedData, .restrictedData):
				return true
			case (.advice, .advice):
				return true
			default:
				return false
			}
		}
	}

	// MARK: Private properties

	@State private var viewDidClose = false
	@State private var totalHeight = CGFloat.zero // variant for ScrollView/List
	// = CGFloat.infinity - variant for VStack

	private let bannerViewType: BannerViewType
	private let colorProvider: ColorSchemeProvider

	private var iconName: String = ""
	private var titleText: String = ""
	private var dataText: String = ""

	// MARK: Init

	public init(bannerViewType: BannerViewType, colorProvider: ColorSchemeProvider) {
		self.bannerViewType = bannerViewType
		self.colorProvider = colorProvider

		self.titleText = self.getTitleText()
		self.dataText = self.getDataText()
		self.iconName = self.getIconName()

		switch bannerViewType {
		case let .advice(type, _):
			let typeString = type.rawValue
			if self.keyExists(key: typeString) {
				_viewDidClose = State(initialValue: true)
			}
		default:
			break
		}
	}

	// MARK: Body

	public var body: some View {
		if !viewDidClose {
			VStack {
				GeometryReader { geometry in
					VStack(spacing: 8) {
						CardTitleView(titleText: self.titleText,
						              mainText: self.dataText,
						              leftIcon: Image(systemName: self.iconName),
						              rightIcon: Image(systemName: "xmark.circle"),
						              titleColor: bannerViewType == .advice(type: .some, imageSystemName: "")
						              	? self.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.adviceText))
						              	: self.colorProvider.sleepyColorScheme.getColor(of: .heart(.heartColor)),
						              mainTextColor: self.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.secondaryText)),
						              showSeparator: bannerViewType == .advice(type: .some, imageSystemName: ""),
						              colorProvider: self.colorProvider,
						              onCloseTapAction: {
						              	viewDidClose = true
						              	UserDefaults.standard.set(true, forKey: getBannerUserDefaultsKey())
						              })

						if bannerViewType == .advice(type: .some, imageSystemName: ""),
						   let imageSystemName = self.getImageSystemName()
						{
							Image(imageSystemName)
								.resizable()
								.aspectRatio(contentMode: .fit)
								.frame(height: 80)
								.padding([.leading, .trailing, .top, .bottom], 8)
								.background(Color.gray.opacity(0.08))
								.cornerRadius(12)
						}

						CardBottomSimpleDescriptionView(descriptionText: Text("Read more"), colorProvider: colorProvider, showChevron: true)
					}
					.frame(width: geometry.size.width)
					.background(viewHeightReader($totalHeight))
				}
			}
			.frame(height: totalHeight) // - variant for ScrollView/List
			// .frame(maxHeight: totalHeight) - variant for VStack
		}
	}

	// MARK: Private Methods

	private func keyExists(key: String) -> Bool {
		return UserDefaults.standard.object(forKey: key) != nil
	}

	private func getBannerUserDefaultsKey() -> String {
		switch self.bannerViewType {
		case let .advice(type, _):
			return type.rawValue
		default:
			return ""
		}
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

	private func getTitleText() -> String {
		switch self.bannerViewType {
		case .emptyData(type: _),
		     .brokenData(type: _),
		     .restrictedData(type: _):
			return "Data empty or restricted"
		case .advice(type: _, _):
			return "Advice"
		}
	}

	private func getImageSystemName() -> String? {
		switch self.bannerViewType {
		case .emptyData(type: _),
		     .brokenData(type: _),
		     .restrictedData(type: _):
			return ""
		case .advice(type: _, let imageSystemName):
			return imageSystemName
		}
	}

	private func getDataText() -> String {
		switch self.bannerViewType {
		case let .emptyData(type: type):
			return String(format: "No data of type %@ was recieved", type.rawValue)
		case let .brokenData(type: type):
			return String(format: "There was not enought data to display your %@ charts. Try to sleep with Apple Watch More", type.rawValue)
		case let .restrictedData(type: type):
			return "Sleepy was restricted from reading your \(type.rawValue) data. Fix that in your settings"
		case let .advice(type: type, _):
			switch type {
			case .wearMore:
				return "Try to sleep with your watch on your wrist to get phase, heart, and energy analysis"
			case .soundRecording:
				return "Record your sleep sounds by pressing ‘record’ button below  and get sound-recognision after you end recording"
			case .some:
				return ""
			}
		}
	}

	private func getIconName() -> String {
		switch self.bannerViewType {
		case .emptyData(type: _), .brokenData(type: _):
			return "exclamationmark.square.fill"
		case .restrictedData(type: _):
			return "eye.slash.fill"
		case .advice(type: _):
			return "questionmark.square.dashed"
		}
	}
}

public struct ErrorView_Previews: PreviewProvider {
	public static var previews: some View {
		BannerView(bannerViewType: .brokenData(type: .heart),
		           colorProvider: ColorSchemeProvider())
	}
}

// Copyright (c) 2021 Sleepy.

import SwiftUI

public struct MotivationCellView: View {
	@Environment(\.openURL) var openURL

	private var type: HealthData
	private var colorProvider: ColorSchemeProvider

	// TODO: перенести это в отдельный файл когда надо будет нагенерить больше мотивации
	private let array = [
		MotivationAdvice(title: "Quality of sleep",
		                 description: "Research shows that poor sleep has immediate negative effects on your hormones, exercise performance, and brain function.",
		                 link: "https://www.healthline.com/nutrition/17-tips-to-sleep-better#_noHeaderPrefixedContent",
		                 type: .asleep),

		MotivationAdvice(title: "What your sleep data means",
		                 description: "A normal resting heart rate ranges from 60 to 100 beats per minute, according to Harvard Health.",
		                 link: "https://www.cnet.com/health/sleep/sleeping-heart-rate-breathing-rate-and-hrv-what-your-sleep-data-means/",
		                 type: .heart),

		MotivationAdvice(title: "How Your Body Use Calories While You Sleep",
		                 description: "Energy use is particularly high during REM (rapid eye movement) sleep.",
		                 link: "https://www.alaskasleep.com/blog/how-your-body-use-calories-while-you-sleep",
		                 type: .energy),
	]

	public init(type: HealthData, colorProvider: ColorSchemeProvider) {
		self.type = type
		self.colorProvider = colorProvider
	}

	public var body: some View {
		ZStack {
			let motivation = array.filter { $0.type == type }.randomElement()
			if let motivation = motivation {
				VStack {
					CardTitleView(titleText: motivation.title,
					              mainText: motivation.description,
					              leftIcon: Image(systemName: "zzz"),
					              rightIcon: Image(systemName: "chevron.right"),
					              titleColor: self.getTypeColor(for: type),
					              mainTextColor: colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)),
					              showSeparator: true,
					              colorProvider: self.colorProvider)
					HStack {
						Text(motivation.link)
							.linkTextModifier()
							.padding(.trailing, 8)
						Spacer()
						Text("Read more")
							.linkTextModifier()
							.padding(.trailing, 8)
					}
				}
				.onTapGesture {
					openURL(URL(string: motivation.link)!)
				}
			}
		}
		.frame(minWidth: 0, maxWidth: .infinity)
		.roundedCardBackground(color: colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
	}

	private func getTypeColor(for type: HealthData) -> Color {
		switch type {
		case .heart:
			return self.colorProvider.sleepyColorScheme.getColor(of: .heart(.heartColor))
		case .energy:
			return self.colorProvider.sleepyColorScheme.getColor(of: .energy(.energyColor))
		case .asleep:
			return self.colorProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor))
		case .inbed:
			return self.colorProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor))
		case .respiratory:
			return Color(.systemBlue)
		}
	}
}

struct MotivationAdvice {
	let title: String
	let description: String
	let link: String
	let type: HealthData
}

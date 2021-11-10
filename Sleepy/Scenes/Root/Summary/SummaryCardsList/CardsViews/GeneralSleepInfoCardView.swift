// Copyright (c) 2021 Sleepy.

import HKVisualKit
import SwiftUI

public struct GeneralSleepInfoCardView: View {
	@State private var totalHeight = CGFloat.zero // variant for ScrollView/List
	// = CGFloat.infinity - variant for VStack

	private let colorProvider: ColorSchemeProvider
	private let viewModel: SummaryGeneralDataViewModel

	init(viewModel: SummaryGeneralDataViewModel, colorProvider: ColorSchemeProvider) {
		self.viewModel = viewModel
		self.colorProvider = colorProvider
	}

	public var body: some View {
		VStack {
			GeometryReader { _ in
				VStack {
					CardTitleView(titleText: "Sleep: general".localized,
					              mainText: "Here is some info about your last sleep session".localized,
					              leftIcon: Image(systemName: "zzz"),
					              rightIcon: Image(systemName: "chevron.right"),
					              titleColor: colorProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor)),
					              mainTextColor: colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)),
					              colorProvider: self.colorProvider)

					HStack {
						VStack(alignment: .leading, spacing: 22) {
							HStack(alignment: .center) {
								Image(systemName: "bed.double")
									.summaryCardImage(
										color: colorProvider.sleepyColorScheme.getColor(of: .summaryCardColors(.fallAsleepDurationColor)),
										size: 23,
										width: 30
									)

								VStack(alignment: .leading) {
									Text(viewModel.sleepInterval.start.getFormattedDate(format: "HH:mm"))
										.boldTextModifier(
											color: colorProvider.sleepyColorScheme.getColor(of: .summaryCardColors(.fallAsleepDurationColor))
										)

									Text("Drop off".localized)
										.boldTextModifier(
											color: colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)),
											size: 14
										)
								}
							}

							HStack(alignment: .center) {
								Image(systemName: "timer")
									.summaryCardImage(
										color: colorProvider.sleepyColorScheme.getColor(of: .summaryCardColors(.sleepDurationColor)),
										size: 27.5,
										width: 30
									)

								VStack(alignment: .leading) {
									Text(viewModel.sleepInterval.end.hoursMinutes(from: viewModel.sleepInterval.start))
										.boldTextModifier(
											color: colorProvider.sleepyColorScheme.getColor(of: .summaryCardColors(.sleepDurationColor))
										)

									Text("Sleep duration".localized)
										.boldTextModifier(
											color: colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)),
											size: 14
										)
								}
							}
						}

						Spacer()

						VStack(alignment: .leading, spacing: 22) {
							HStack(alignment: .center) {
								Image(systemName: "sunrise.fill")
									.summaryCardImage(
										color: colorProvider.sleepyColorScheme.getColor(of: .summaryCardColors(.awakeColor)),
										size: 25,
										width: 30
									)

								VStack(alignment: .leading) {
									Text(self.viewModel.sleepInterval.end.getFormattedDate(format: "HH:mm"))
										.boldTextModifier(
											color: colorProvider.sleepyColorScheme.getColor(of: .summaryCardColors(.awakeColor))
										)

									Text("Awake".localized)
										.boldTextModifier(
											color: colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)),
											size: 14
										)
								}
							}

							HStack(alignment: .center) {
								Image(systemName: "moon")
									.summaryCardImage(
										color: colorProvider.sleepyColorScheme.getColor(of: .summaryCardColors(.moonColor)),
										size: 27.5,
										width: 30
									)

								VStack(alignment: .leading) {
									Text(self.viewModel.sleepInterval.start.hoursMinutes(from: viewModel.inbedInterval.start))
										.boldTextModifier(
											color: colorProvider.sleepyColorScheme.getColor(of: .summaryCardColors(.moonColor))
										)

									Text("Falling asleep".localized)
										.boldTextModifier(
											color: colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)),
											size: 14
										)
								}
							}
						}
					}
					.padding(.top, 8)
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

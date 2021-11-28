// Copyright (c) 2021 Sleepy.

import FirebaseAnalytics
import HKCoreSleep
import HKStatistics
import SwiftUI
import UIComponents
import XUI

struct HeartCardDetailView: View {
	@Store var viewModel: CardDetailsViewCoordinator
	@EnvironmentObject var cardService: CardService
	@State private var showAdvice = false
	@State private var activeSheet: AdviceType!

	var body: some View {
		GeometryReader { _ in
			ZStack {
				viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.appBackgroundColor))
					.edgesIgnoringSafeArea(.all)

				ScrollView(.vertical, showsIndicators: false) {
					VStack(alignment: .center) {
						if let heartViewModel = cardService.heartViewModel,
						   let generalViewModel = cardService.generalViewModel
						{
							// MARK: Chart

							StandardChartView(colorProvider: viewModel.colorProvider,
							                  chartType: .defaultChart(
							                  	barType: .circle(
							                  		color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .heart(.heartColor))
							                  	)
							                  ),
							                  chartHeight: 75,
							                  points: heartViewModel.heartRateData,
							                  dateInterval: generalViewModel.sleepInterval)
								.roundedCardBackground(
									color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor))
								)
								.padding(.top)

							// MARK: Statistics

							SectionNameTextView(text: "Summary",
							                    color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))

							HorizontalStatisticCellView(data: [
								StatisticsCellData(title: "Average pulse",
								                   value: heartViewModel.averageHeartRate),
								StatisticsCellData(title: "Max pulse",
								                   value: heartViewModel.maxHeartRate),
								StatisticsCellData(title: "Min pulse",
								                   value: heartViewModel.minHeartRate),
							],
							colorScheme: viewModel.colorProvider.sleepyColorScheme)
						}

						// MARK: Advices

						SectionNameTextView(text: "What else?",
						                    color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))

						UsefulInfoCardView(imageName: AdviceType.heartAdvice.rawValue,
						                   title: "Heart and sleep",
						                   description: "Learn more about the importance of sleep for heart health.",
						                   destinationView: AdviceView(sheetType: .heartAdvice,
						                                               showAdvice: $showAdvice),
						                   showModalView: $showAdvice)
							.usefulInfoCardBackground(
								color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor))
							)
					}
				}
				.navigationTitle("Heart")
				.onAppear(perform: self.sendAnalytics)
			}
		}
	}

	private func sendAnalytics() {
		FirebaseAnalytics.Analytics.logEvent("HeartCard_viewed", parameters: [
			"contentShown": self.cardService.generalViewModel != nil && self.cardService.heartViewModel != nil,
		])
	}
}

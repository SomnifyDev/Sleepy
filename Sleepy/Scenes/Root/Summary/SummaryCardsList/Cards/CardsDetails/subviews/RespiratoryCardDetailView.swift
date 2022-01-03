// Copyright (c) 2021 Sleepy.

import FirebaseAnalytics
import HKCoreSleep
import HKStatistics
import SwiftUI
import UIComponents
import XUI

struct RespiratoryCardDetailView: View {
	@Store var viewModel: CardDetailsViewCoordinator
	@EnvironmentObject var cardService: CardService

	var body: some View {
		GeometryReader { _ in
			ZStack {
				viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.appBackgroundColor))
					.edgesIgnoringSafeArea(.all)

				ScrollView(.vertical, showsIndicators: false) {
					VStack(alignment: .center) {
						if let respiratoryViewModel = cardService.respiratoryViewModel,
						   let generalViewModel = cardService.generalViewModel
						{
							// MARK: Chart

							StandardChartView(colorProvider: viewModel.colorProvider,
							                  chartType: .defaultChart(
							                  	barType: .rectangle(
							                  		color: Color(.systemBlue)
							                  	)
							                  ),
							                  chartHeight: 75,
							                  points: respiratoryViewModel.respiratoryRateData,
							                  dateInterval: generalViewModel.sleepInterval)
								.roundedCardBackground(
									color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor))
								)
								.padding(.top)

							// MARK: Statistics

							SectionNameTextView(text: "Summary",
							                    color: viewModel.ColorsRepository.Text.standard)

							StatisticsCellCollectionView(data: [
								StatisticsCellViewModel(title: "Max. respiratory rate",
								                   value: respiratoryViewModel.maxRespiratoryRate),
								StatisticsCellViewModel(title: "Mean. respiratory rate",
								                   value: respiratoryViewModel.averageRespiratoryRate),
								StatisticsCellViewModel(title: "Min. respiratory rate",
								                   value: respiratoryViewModel.minRespiratoryRate),
							],
							colorScheme: viewModel.colorProvider.sleepyColorScheme)
						}
					}
				}
				.navigationTitle("Respiratory rate")
			}
		}
	}

	// MARK: Private methods

	private func sendAnalytics() {
		FirebaseAnalytics.Analytics.logEvent("RespiratoryCard_viewed", parameters: [
			"contentShown": self.cardService.generalViewModel != nil && self.cardService.respiratoryViewModel != nil,
		])
	}
}

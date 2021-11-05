// Copyright (c) 2021 Sleepy.

import FirebaseAnalytics
import HKCoreSleep
import HKVisualKit
import SwiftUI
import XUI

struct HistoryListView: View {
	@Store var viewModel: HistoryCoordinator

	var body: some View {
		GeometryReader { _ in
			ZStack {
				viewModel.colorSchemeProvider.sleepyColorScheme.getColor(of: .general(.appBackgroundColor))
					.edgesIgnoringSafeArea(.all)

				ScrollView(.vertical, showsIndicators: false) {
					CalendarView(viewModel: viewModel)
						.roundedCardBackground(color: viewModel.colorSchemeProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))

					if viewModel.calendarType == .asleep {
						if let asleepHistoryStatsViewModel = viewModel.asleepHistoryStatsViewModel {
							SleepHistoryStatsView(viewModel: asleepHistoryStatsViewModel,
							                      colorProvider: viewModel.colorSchemeProvider)
						} else {
							MotivationCellView(type: .asleep, colorProvider: self.viewModel.colorSchemeProvider)

							BannerView(bannerViewType: .brokenData(type: .asleep),
							           colorProvider: viewModel.colorSchemeProvider)
								.roundedCardBackground(color: viewModel.colorSchemeProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))

							SleepHistoryStatsView(colorProvider: self.viewModel.colorSchemeProvider)
								.blur(radius: 4)
						}
					} else if viewModel.calendarType == .inbed {
						if let inbedHistoryStatsViewModel = viewModel.inbedHistoryStatsViewModel {
							SleepHistoryStatsView(viewModel: inbedHistoryStatsViewModel,
							                      colorProvider: viewModel.colorSchemeProvider)
						} else {
							MotivationCellView(type: .asleep, colorProvider: self.viewModel.colorSchemeProvider)

							BannerView(bannerViewType: .brokenData(type: .inbed),
							           colorProvider: viewModel.colorSchemeProvider)
								.roundedCardBackground(color: viewModel.colorSchemeProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))

							SleepHistoryStatsView(colorProvider: self.viewModel.colorSchemeProvider)
								.blur(radius: 4)
						}
					} else if viewModel.calendarType == .heart {
						if let heartHistoryStatsViewModel = viewModel.heartHistoryStatsViewModel {
							HeartHistoryStatsView(viewModel: heartHistoryStatsViewModel,
							                      colorProvider: viewModel.colorSchemeProvider)
						} else {
							MotivationCellView(type: .heart, colorProvider: self.viewModel.colorSchemeProvider)

							BannerView(bannerViewType: .brokenData(type: .heart),
							           colorProvider: viewModel.colorSchemeProvider)
								.roundedCardBackground(color: viewModel.colorSchemeProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))

							HeartHistoryStatsView(colorProvider: self.viewModel.colorSchemeProvider)
								.blur(radius: 4)
						}
					} else if viewModel.calendarType == .energy {
						if let energyHistoryStatsViewModel = viewModel.energyHistoryStatsViewModel {
							EnergyHistoryStatsView(viewModel: energyHistoryStatsViewModel,
							                       colorProvider: viewModel.colorSchemeProvider)
						} else {
							MotivationCellView(type: .energy, colorProvider: self.viewModel.colorSchemeProvider)

							BannerView(bannerViewType: .brokenData(type: .energy),
							           colorProvider: viewModel.colorSchemeProvider)
								.roundedCardBackground(color: viewModel.colorSchemeProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))

							EnergyHistoryStatsView(colorProvider: self.viewModel.colorSchemeProvider)
								.blur(radius: 4)
						}
					} else if viewModel.calendarType == .respiratory {
						if let respiratoryHistoryStatsViewModel = viewModel.respiratoryHistoryStatsViewModel {
							RespiratoryHistoryStatsView(viewModel: respiratoryHistoryStatsViewModel,
							                            colorProvider: viewModel.colorSchemeProvider)
						} else {
							MotivationCellView(type: .respiratory, colorProvider: self.viewModel.colorSchemeProvider)

							BannerView(bannerViewType: .brokenData(type: .respiratory),
							           colorProvider: viewModel.colorSchemeProvider)
								.roundedCardBackground(color: viewModel.colorSchemeProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))

							RespiratoryHistoryStatsView(colorProvider: self.viewModel.colorSchemeProvider)
								.blur(radius: 4)
						}
					} else {
						Text("Loading".localized)
					}
				}
			}
			.onAppear(perform: viewModel.extractContextStatistics)
			.onChange(of: viewModel.calendarType) { _ in
				viewModel.extractContextStatistics()
			}
		}
		.navigationTitle("Sleep history".localized)
		.onAppear(perform: self.sendAnalytics)
	}

	private func sendAnalytics() {
		FirebaseAnalytics.Analytics.logEvent("History_viewed", parameters: nil)
	}
}

// Copyright (c) 2021 Sleepy.

import FirebaseAnalytics
import HKCoreSleep
import SwiftUI
import UIComponents
import XUI

struct HistoryListView: View {
	@Store var viewModel: HistoryCoordinator
    let interactor: HistoryInteractor
    
	var body: some View {
		GeometryReader { _ in
			ZStack {
                ColorsRepository.General.appBackground
					.edgesIgnoringSafeArea(.all)

				ScrollView(.vertical, showsIndicators: false) {
					CalendarView(viewModel: viewModel)
                        .roundedCardBackground(color: ColorsRepository.Card.cardBackground)

					if viewModel.calendarType == .asleep {
						if let asleepHistoryStatsViewModel = viewModel.asleepHistoryStatsViewModel {
							SleepHistoryStatsView(viewModel: asleepHistoryStatsViewModel)
						} else {
							MotivationCellView(type: .asleep)

//							BannerView(bannerViewType: .brokenData(type: .asleep))
//								.roundedCardBackground(color: ColorsRepository.Card.cardBackground)

							SleepHistoryStatsView()
								.blur(radius: 4)
						}
					} else if viewModel.calendarType == .inbed {
						if let inbedHistoryStatsViewModel = viewModel.inbedHistoryStatsViewModel {
							SleepHistoryStatsView(viewModel: inbedHistoryStatsViewModel,
							                      colorProvider: viewModel.colorSchemeProvider)
						} else {
							MotivationCellView(type: .asleep)

//							BannerView(bannerViewType: .brokenData(type: .inbed))
//								.roundedCardBackground(color: ColorsRepository.Card.cardBackground)

							SleepHistoryStatsView()
								.blur(radius: 4)
						}
					} else if viewModel.calendarType == .heart {
						if let heartHistoryStatisticsViewModel = viewModel.heartHistoryStatisticsViewModel {
							HeartHistoryStatisticsView(viewModel: heartHistoryStatisticsViewModel)
						} else {
							MotivationCellView(type: .heart)

//							BannerView(bannerViewType: .brokenData(type: .heart),
//							           colorProvider: viewModel.colorSchemeProvider)
//								.roundedCardBackground(color: ColorsRepository.Card.cardBackground)

							HeartHistoryStatisticsView()
								.blur(radius: 4)
						}
					} else if viewModel.calendarType == .energy {
						if let energyHistoryStatsViewModel = viewModel.energyHistoryStatsViewModel {
							EnergyHistoryStatsView(viewModel: energyHistoryStatsViewModel)
						} else {
							MotivationCellView(type: .energy)

//							BannerView(bannerViewType: .brokenData(type: .energy),
//							           colorProvider: viewModel.colorSchemeProvider)
//								.roundedCardBackground(color: ColorsRepository.Card.cardBackground)

							EnergyHistoryStatsView(colorProvider: self.viewModel.colorSchemeProvider)
								.blur(radius: 4)
						}
					} else if viewModel.calendarType == .respiratory {
						if let respiratoryHistoryStatsViewModel = viewModel.respiratoryHistoryStatsViewModel {
							RespiratoryHistoryStatsView(viewModel: respiratoryHistoryStatsViewModel)
						} else {
							MotivationCellView(type: .respiratory)

//							BannerView(bannerViewType: .brokenData(type: .respiratory),
//							           colorProvider: viewModel.colorSchemeProvider)
//								.roundedCardBackground(color: ColorsRepository.Card.cardBackground)

							RespiratoryHistoryStatsView()
								.blur(radius: 4)
						}
					} else {
						Text("Loading")
					}
				}
			}
			.onAppear(perform: viewModel.extractContextStatistics)
			.onChange(of: viewModel.calendarType) { _ in
				viewModel.extractContextStatistics()
			}
		}
		.navigationTitle("Sleep history")
		.onAppear(perform: self.sendAnalytics)
	}

	private func sendAnalytics() {
		FirebaseAnalytics.Analytics.logEvent("History_viewed", parameters: nil)
	}
}

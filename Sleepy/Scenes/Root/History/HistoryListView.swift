// Copyright (c) 2022 Sleepy.

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
                    CalendarView(viewModel: viewModel, interactor: self.interactor)
                        .roundedCardBackground(color: ColorsRepository.Card.cardBackground)

                    if viewModel.calendarType == .asleep {
                        if let asleepHistoryStatsDisplayItem = viewModel.asleepHistoryStatsDisplayItem {
                            SleepHistoryStatsView(viewModel: self.viewModel, displayItem: asleepHistoryStatsDisplayItem)
                        } else {
                            SleepHistoryStatsView(viewModel: self.viewModel)
                                .blur(radius: 4)
                        }
                    } else if viewModel.calendarType == .inbed {
                        if let inbedHistoryStatsDisplayItem = viewModel.inbedHistoryStatsDisplayItem {
                            SleepHistoryStatsView(viewModel: self.viewModel, displayItem: inbedHistoryStatsDisplayItem)
                        } else {
                            SleepHistoryStatsView(viewModel: self.viewModel)
                                .blur(radius: 4)
                        }
                    } else if viewModel.calendarType == .heart {
                        if let heartHistoryStatisticsDisplayItem = viewModel.heartHistoryStatisticsDisplayItem
                        {
                            HeartHistoryStatisticsView(viewModel: self.viewModel, displayItem: heartHistoryStatisticsDisplayItem)
                        } else {
                            HeartHistoryStatisticsView(viewModel: self.viewModel)
                                .blur(radius: 4)
                        }
                    } else if viewModel.calendarType == .energy {
                        if let energyHistoryStatsDisplayItem = viewModel.energyHistoryStatsDisplayItem {
                            EnergyHistoryStatsView(viewModel: energyHistoryStatsDisplayItem)
                        } else {
                            EnergyHistoryStatsView()
                                .blur(radius: 4)
                        }
                    } else if viewModel.calendarType == .respiratory {
                        if let respiratoryHistoryStatsDisplayItem = viewModel.respiratoryHistoryStatsDisplayItem
                        {
                            RespiratoryHistoryStatsView(viewModel: respiratoryHistoryStatsDisplayItem)
                        } else {
                            RespiratoryHistoryStatsView()
                                .blur(radius: 4)
                        }
                    } else {
                        Text("Loading")
                    }
                }
            }
            .onAppear {
                self.loadData()
            }
            .onChange(of: viewModel.calendarType) { _ in
                self.loadData()
            }
        }
        .navigationTitle("Sleep history")
        .onAppear(perform: self.sendAnalytics)
    }

    private func loadData() {
        self.interactor.extractCalendarData()
        self.interactor.extractContextStatistics()
    }

    private func sendAnalytics() {
        FirebaseAnalytics.Analytics.logEvent("History_viewed", parameters: nil)
    }
}

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
                        if let asleepHistoryStatsViewModel = viewModel.asleepHistoryStatsViewModel {
                            SleepHistoryStatsView(viewModel: asleepHistoryStatsViewModel)
                        } else {
                            SleepHistoryStatsView()
                                .blur(radius: 4)
                        }
                    } else if viewModel.calendarType == .inbed {
                        if let inbedHistoryStatsViewModel = viewModel.inbedHistoryStatsViewModel {
                            SleepHistoryStatsView(viewModel: inbedHistoryStatsViewModel)
                        } else {
                            SleepHistoryStatsView()
                                .blur(radius: 4)
                        }
                    } else if viewModel.calendarType == .heart {
                        if let heartHistoryStatisticsViewModel = viewModel.heartHistoryStatisticsViewModel
                        {
                            HeartHistoryStatisticsView(viewModel: heartHistoryStatisticsViewModel)
                        } else {
                            HeartHistoryStatisticsView()
                                .blur(radius: 4)
                        }
                    } else if viewModel.calendarType == .energy {
                        if let energyHistoryStatsViewModel = viewModel.energyHistoryStatsViewModel {
                            EnergyHistoryStatsView(viewModel: energyHistoryStatsViewModel)
                        } else {
                            EnergyHistoryStatsView()
                                .blur(radius: 4)
                        }
                    } else if viewModel.calendarType == .respiratory {
                        if let respiratoryHistoryStatsViewModel = viewModel.respiratoryHistoryStatsViewModel
                        {
                            RespiratoryHistoryStatsView(viewModel: respiratoryHistoryStatsViewModel)
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

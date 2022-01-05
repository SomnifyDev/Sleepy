// Copyright (c) 2021 Sleepy.

import SwiftUI
import UIComponents
import XUI

struct SummaryCardsListView: View {

    @Store var viewModel: SummaryCardsListCoordinator

    @EnvironmentObject var cardService: CardService

    var body: some View {
        ZStack {
            ColorsRepository.General.appBackground
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(alignment: .center) {

                    if viewModel.somethingBroken {
                        BannerView(with: viewModel.somethingBrokenBannerViewModel) {
                            CardTitleView(with: viewModel.somethingBrokenBannerViewModel.cardTitleViewModel)
                        }
                        .roundedCardBackground(color: ColorsRepository.Card.cardBackground)
                    }

                    // MARK: - General card

                    if let generalViewModel = cardService.generalViewModel {
                        SectionNameTextView(
                            text: "Sleep information",
                            color: ColorsRepository.Text.standard
                        )
                            .padding(.top)
                        GeneralSleepInfoCardView(viewModel: generalViewModel)
                            .buttonStyle(PlainButtonStyle())
                            .roundedCardBackground(color: ColorsRepository.Card.cardBackground)
                            .onNavigation { viewModel.open(.general) }
                    }

                    // MARK: - Phases card

                    if let phasesViewModel = cardService.phasesViewModel,
                       let generalViewModel = cardService.generalViewModel {
                        SectionNameTextView(
                            text: "Sleep session",
                            color: ColorsRepository.Text.standard
                        )
                        CardWithContentView(with: viewModel.phasesCardTitleViewModel) {
                            VStack {
                                StandardChartView(
                                    chartType: .phasesChart,
                                    chartHeight: 75,
                                    points: phasesViewModel.phasesData,
                                    dateInterval: generalViewModel.sleepInterval
                                )
                                CardBottomSimpleDescriptionView(
                                    with: String(
                                        format: "Duration of light phase was %@, while the duration of deep sleep was %@",
                                        phasesViewModel.timeInLightPhase,
                                        phasesViewModel.timeInDeepPhase
                                    )
                                )
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .roundedCardBackground(color: ColorsRepository.Card.cardBackground)
                        .onNavigation { viewModel.open(.phases) }
                    }

                    // MARK: - Heart card

                    if let heartViewModel = cardService.heartViewModel,
                       let generalViewModel = cardService.generalViewModel {
                        SectionNameTextView(
                            text: "Heart rate",
                            color: ColorsRepository.Text.standard
                        )
                        CardWithContentView(with: viewModel.heartCardTitleViewModel) {
                            VStack {
                                StandardChartView(
                                    chartType: .defaultChart(
                                        barType: .circular(color: ColorsRepository.Heart.heart)
                                    ),
                                    chartHeight: 75,
                                    points: heartViewModel.heartRateData,
                                    dateInterval: generalViewModel.sleepInterval
                                )
                                CardBottomSimpleDescriptionView(
                                    with: String(
                                        format: "The maximal heartbeat was %@ bpm while the minimal was %@",
                                        heartViewModel.minHeartRate,
                                        heartViewModel.maxHeartRate
                                    )
                                )
                            }
                        }
                        .roundedCardBackground(color: ColorsRepository.Card.cardBackground)
                        .onNavigation { viewModel.open(.heart) }
                        .buttonStyle(PlainButtonStyle())
                    }

                    // MARK: - Respiratory card

                    if let respiratoryViewModel = cardService.respiratoryViewModel,
                       let generalViewModel = cardService.generalViewModel {
                        SectionNameTextView(
                            text: "Respiratory rate",
                            color: ColorsRepository.Text.standard
                        )
                        CardWithContentView(with: viewModel.respiratoryCardTitleViewModel) {
                            VStack {
                                StandardChartView(
                                    chartType: .defaultChart(
                                        barType: .rectangular(
                                            color: Color.blue
                                        )
                                    ),
                                    chartHeight: 75,
                                    points: respiratoryViewModel.respiratoryRateData,
                                    dateInterval: generalViewModel.sleepInterval
                                )
                                CardBottomSimpleDescriptionView(
                                    with: String(
                                        format: "The maximal respiratory rate was %@ while the minimal was %@",
                                        respiratoryViewModel.minRespiratoryRate,
                                        respiratoryViewModel.maxRespiratoryRate
                                    )
                                )
                            }
                        }
                        .roundedCardBackground(color: ColorsRepository.Card.cardBackground)
                        .onNavigation { viewModel.open(.breath) }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .navigationTitle("\("Summary"), \((cardService.generalViewModel?.sleepInterval.end ?? Date()).getFormattedDate(format: "MMM d"))")
        .onAppear { viewModel.sendAnalytics(cardService: cardService) }
    }
}

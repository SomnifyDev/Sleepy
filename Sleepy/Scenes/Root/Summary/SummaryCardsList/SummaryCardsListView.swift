// Copyright (c) 2021 Sleepy.

import SwiftUI
import UIComponents
import XUI

struct SummaryCardsListView: View {

    @Store var viewModel: SummaryCardsListCoordinator

    @EnvironmentObject var cardService: CardService


    @State private var showSleepImprovement = false
    @State private var imagesIndex = 0
    private let tutorialImages = ["tutorial3", "tutorial4"]

    var body: some View {
        ZStack {
            ColorsRepository.General.appBackground
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(alignment: .center) {

                    // MARK: Errors

                    if cardService.somethingBroken {
                        BannerView(with: viewModel.somethingBrokenBannerViewModel) {
                            CardBottomSimpleDescriptionView(with: viewModel.somethingBrokenBannerViewModel.cardTitleViewModel.description ?? "")
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

                    // MARK: Errors

                    if cardService.respiratoryViewModel == nil,
                       cardService.heartViewModel == nil,
                       cardService.phasesViewModel == nil {
                        SectionNameTextView(
                            text: "Cards preview",
                            color: ColorsRepository.Text.standard
                        )

                        PaginationView(index: $imagesIndex.animation(), maxIndex: tutorialImages.count - 1) {
                            ForEach(self.tutorialImages, id: \.self) { imageName in
                                Image(imageName)
                                    .resizable()
                                    .aspectRatio(1.21, contentMode: .fit)
                                    .cornerRadius(12)
                            }
                        }
                        .aspectRatio(1.21, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .padding([.leading, .trailing])
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

                    SectionNameTextView(text: "What else?",
                                        color: ColorsRepository.Text.standard)
                        .padding(.top)

                    ArticleCardView(
                        with: ArticleCardViewModel(
                            title: "How to improve your sleep?",
                            description: "Learn about the factors that affect the quality of your sleep.",
                            coverImage: Image("sleepImprovementAdvice")
                        ),
                        destinationView: AdviceView(
                            sheetType: .sleepImprovementAdvice,
                            showAdvice: $showSleepImprovement
                        )
                    )
                        .usefulInfoCardBackground(color: ColorsRepository.Card.cardBackground)
                }
            }
        }
        .navigationTitle("\("Summary"), \((cardService.generalViewModel?.sleepInterval.end ?? Date()).getFormattedDate(format: "MMM d"))")
        .onAppear { viewModel.sendAnalytics(cardService: cardService) }
    }
}

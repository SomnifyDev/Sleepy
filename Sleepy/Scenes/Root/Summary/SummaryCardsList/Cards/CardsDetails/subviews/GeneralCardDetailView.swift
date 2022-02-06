// Copyright (c) 2022 Sleepy.

import FirebaseAnalytics
import HKCoreSleep
import HKStatistics
import SettingsKit
import SwiftUI
import UIComponents
import XUI

struct GeneralCardDetailView: View {
    @EnvironmentObject var cardService: CardService
    @Store var viewModel: CardDetailsViewCoordinator
    @State private var showSleepImportance = false
    @State private var showSleepImprovement = false
    @State private var activeSheet: AdviceType!

    var body: some View {
        ZStack {
            ColorsRepository.General.appBackground
                .edgesIgnoringSafeArea(.all)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .center) {
                    // MARK: Bank of sleep

                    if let bankOfSleepViewModel = cardService.bankOfSleepViewModel {
                        SectionNameTextView(
                            text: "Bank",
                            color: ColorsRepository.Text.standard
                        )
                            .padding(.top)

                        CardWithContentView(
                            with: CardTitleViewModel(
                                leadIcon: Image(systemName: "banknote.fill"),
                                title: "Sleep: bank",
                                description: String(format: "Total backlog from your goal during last 2 weeks is %@", bankOfSleepViewModel.backlog),
                                trailIcon: nil,
                                trailText: nil,
                                titleColor: ColorsRepository.Phase.deepSleep,
                                descriptionColor: ColorsRepository.Text.standard,
                                shouldShowSeparator: true
                            )
                        ) {
                            VStack(spacing: 16) {
                                StandardChartView(
                                    chartType: .verticalProgress(
                                        foregroundElementColor: ColorsRepository.General.mainSleepy,
                                        backgroundElementColor: ColorsRepository.Chart.verticalProgressChartElement,
                                        max: bankOfSleepViewModel.bankOfSleepData.map { $0.value }.max()!
                                    ),
                                    points: bankOfSleepViewModel.bankOfSleepData,
                                    chartHeight: 100,
                                    timeLineType: .none
                                )

                                CardBottomSimpleDescriptionView(
                                    with: "Sleep for \(bankOfSleepViewModel.timeToCloseDebt) every day to pay off the debt."
                                )
                            }
                        }
                        .roundedCardBackground(color: ColorsRepository.Card.cardBackground)
                    }

                    // MARK: Statistics

                    if let generalViewModel = cardService.generalViewModel {
                        SectionNameTextView(
                            text: "Summary for today",
                            color: ColorsRepository.Text.standard
                        )

                        StatisticsCellCollectionView(
                            with: StatisticsCellCollectionViewModel(
                                with: getStatisticCells(generalViewModel: generalViewModel)
                            )
                        )

                        SectionNameTextView(
                            text: "Statistics",
                            color: ColorsRepository.Text.standard
                        )

                        ProgressChartView(
                            with: ProgressChartViewModel(
                                cardTitleViewModel: CardTitleViewModel(
                                    leadIcon: Image(systemName: "zzz"),
                                    title: "Sleep: goal",
                                    description: String(
                                        format: "Your sleep duration was %@, it is %u%% of your goal",
                                        generalViewModel.sleepInterval.end.hoursMinutes(from: generalViewModel.sleepInterval.start),
                                        getGoalPercentage(viewModel: generalViewModel)
                                    ),
                                    trailIcon: nil,
                                    trailText: nil,
                                    titleColor: ColorsRepository.General.mainSleepy,
                                    descriptionColor: ColorsRepository.Text.standard,
                                    shouldShowSeparator: true
                                ),
                                description: getAnalysisString(viewModel: generalViewModel),
                                beforeProgressViewModel: ProgressElementViewModel(
                                    title: "Your sleep goal",
                                    payloadText: Date.minutesToClearString(minutes: generalViewModel.sleepGoal),
                                    value: generalViewModel.sleepGoal
                                ),
                                currentProgressViewModel: ProgressElementViewModel(
                                    title: "Sleep duration today",
                                    payloadText: Date.minutesToClearString(minutes: Int(generalViewModel.sleepInterval.duration) / 60),
                                    value: Int(generalViewModel.sleepInterval.duration) / 60
                                )
                            )
                        )
                            .roundedCardBackground(color: ColorsRepository.Card.cardBackground)
                    }

                    SectionNameTextView(
                        text: "What else?",
                        color: ColorsRepository.Text.standard
                    )

                    // MARK: Advices

                    ArticleCardView(
                        with: ArticleCardViewModel(
                            title: "Why is sleep so important?",
                            description: "Learn more about the role of sleep in your life.",
                            coverImage: Image("sleepImportanceAdvice")
                        ),
                        shouldOpenDestinationView: $showSleepImportance,
                        destinationView: AdviceView(
                            sheetType: .sleepImportanceAdvice,
                            showAdvice: $showSleepImportance
                        )
                    )
                        .usefulInfoCardBackground(color: ColorsRepository.Card.cardBackground)

                    ArticleCardView(
                        with: ArticleCardViewModel(
                            title: "How to improve your sleep?",
                            description: "Learn about the factors that affect the quality of your sleep.",
                            coverImage: Image("sleepImprovementAdvice")
                        ),
                        shouldOpenDestinationView: $showSleepImprovement,
                        destinationView: AdviceView(
                            sheetType: .sleepImprovementAdvice,
                            showAdvice: $showSleepImprovement
                        )
                    )
                        .usefulInfoCardBackground(color: ColorsRepository.Card.cardBackground)
                }
            }
            .navigationTitle("\(Date().getFormattedDate(format: "E, MMMM d"))")
            .onAppear(perform: self.sendAnalytics)
        }
    }

    // MARK: Private methods

    private func getStatisticCells(generalViewModel: SummaryGeneralDataViewModel) -> [StatisticsCellViewModel]
    {
        return [
            StatisticsCellViewModel(
                title: "Fall asleep",
                value: generalViewModel.sleepInterval.start.hoursMinutes(from: generalViewModel.inbedInterval.start)
            ),
            StatisticsCellViewModel(
                title: "Wake up",
                value: generalViewModel.sleepInterval.end.getFormattedDate(format: "HH:mm")
            ),
            StatisticsCellViewModel(
                title: "Time asleep",
                value: generalViewModel.sleepInterval.end.hoursMinutes(from: generalViewModel.sleepInterval.start)
            ),
            StatisticsCellViewModel(
                title: "Time in bed",
                value: generalViewModel.inbedInterval.end.hoursMinutes(from: generalViewModel.inbedInterval.start)
            ),
        ]
    }

    private func getAnalysisString(viewModel: SummaryGeneralDataViewModel) -> String {
        let sleepDuration = viewModel.sleepInterval.duration / 60.0
        let sleepGoalPercentage = Int((Double(sleepDuration) / Double(viewModel.sleepGoal)) * 100)
        if sleepGoalPercentage < 80 {
            return "Pay more attention to your sleep to be more healthy and productive every day!"
        } else if sleepGoalPercentage >= 80 && sleepGoalPercentage < 100 {
            return "You can do better! For a reminder, sleep is the key to longevity and youth!"
        } else {
            return "Amazing result for today. Keep it up and stay healthy!"
        }
    }

    private func getGoalPercentage(viewModel: SummaryGeneralDataViewModel) -> Int {
        let sleepDuration = viewModel.sleepInterval.duration / 60.0
        let sleepGoal = Double(viewModel.sleepGoal)
        return Int((sleepDuration / sleepGoal) * 100)
    }

    private func sendAnalytics() {
        FirebaseAnalytics.Analytics.logEvent("GeneralCard_viewed", parameters: [
            "bankOfSleepShown": self.cardService.bankOfSleepViewModel != nil,
            "generalShown": self.cardService.generalViewModel != nil,
        ])
    }
}

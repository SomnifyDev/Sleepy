// Copyright (c) 2021 Sleepy.

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
		GeometryReader { _ in
			ZStack {
				viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.appBackgroundColor))
					.edgesIgnoringSafeArea(.all)

				ScrollView(.vertical, showsIndicators: false) {
					VStack(alignment: .center) {
						// MARK: Bank of sleep

						if let bankOfSleepViewModel = cardService.bankOfSleepViewModel {
							SectionNameTextView(text: "Bank",
							                    color: viewModel.ColorsRepository.Text.standard)
								.padding(.top)

							CardWithChartView(colorProvider: viewModel.colorProvider,
							                  systemImageName: "banknote.fill",
							                  titleText: "Sleep: bank",
							                  mainTitleText: String(format: "Total backlog from your goal during last 2 weeks is %@", bankOfSleepViewModel.backlog),
							                  titleColor: viewModel.colorProvider.sleepyColorScheme.getColor(of: .phases(.deepSleepColor)),
							                  showChevron: false,
							                  chartView: StandardChartView(colorProvider: viewModel.colorProvider,
							                                               chartType: .verticalProgress(foregroundElementColor: viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor)),
							                                                                            backgroundElementColor:
							                                                                            viewModel.colorProvider.sleepyColorScheme.getColor(of: .chartColors(.verticalProgressChartElement)),
							                                                                            max: bankOfSleepViewModel.bankOfSleepData.max()!),
							                                               chartHeight: 100,
							                                               points: bankOfSleepViewModel.bankOfSleepData,
							                                               dateInterval: nil,
							                                               needOXLine: false,
							                                               needTimeLine: false,
							                                               dragGestureEnabled: false),
							                  bottomView: CardBottomSimpleDescriptionView(descriptionText:
							                  	Text("Sleep for ")
							                  		+ Text("\(bankOfSleepViewModel.timeToCloseDebt)")
							                  		.foregroundColor(viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor)))
							                  		.bold()
							                  		+ Text(" every day to pay off the debt."),
							                  	colorProvider: viewModel.colorProvider, showChevron: false))
								.roundedCardBackground(
									color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor))
								)
						}

						// MARK: Statistics

						if let generalViewModel = cardService.generalViewModel {
							SectionNameTextView(text: "Summary",
							                    color: viewModel.ColorsRepository.Text.standard)

							StatisticsCellCollectionView(data: getStatisticCells(generalViewModel: generalViewModel),
							                            colorScheme: viewModel.colorProvider.sleepyColorScheme)

							SectionNameTextView(text: "Statistics",
							                    color: viewModel.ColorsRepository.Text.standard)

							ProgressChartView(titleText: "Sleep: goal",
							                  mainText:
							                  String(format: "Your sleep duration was %@, it is %u%% of your goal",
							                         generalViewModel.sleepInterval.end.hoursMinutes(from: generalViewModel.sleepInterval.start),
							                         getGoalPercentage(viewModel: generalViewModel)),
							                  systemImage: "zzz",
							                  colorProvider: viewModel.colorProvider,
							                  currentProgress: ProgressItem(title: "Your sleep goal",
							                                                text: Date.minutesToClearString(
							                                                	minutes: generalViewModel.sleepGoal
							                                                ),
							                                                value: generalViewModel.sleepGoal),
							                  beforeProgress: ProgressItem(title: "Sleep duration today",
							                                               text: Date.minutesToClearString(
							                                               	minutes: Int(generalViewModel.sleepInterval.duration) / 60),
							                                               value: Int(generalViewModel.sleepInterval.duration) / 60),
							                  analysisString: getAnalysisString(
							                  	viewModel: generalViewModel
							                  ),
							                  mainColor: viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor)),
							                  mainTextColor: viewModel.ColorsRepository.Text.standard)
								.roundedCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
						}

						SectionNameTextView(text: "What else?",
						                    color: viewModel.ColorsRepository.Text.standard)

						// MARK: Advices

						UsefulInfoCardView(imageName: AdviceType.sleepImportanceAdvice.rawValue,
						                   title: "Why is sleep so important?",
						                   description: "Learn more about the role of sleep in your life.",
						                   destinationView: AdviceView(sheetType: .sleepImportanceAdvice,
						                                               showAdvice: $showSleepImprovement),
						                   showModalView: $showSleepImprovement)
							.usefulInfoCardBackground(
								color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor))
							)

						UsefulInfoCardView(imageName: AdviceType.sleepImprovementAdvice.rawValue,
						                   title: "How to improve your sleep?",
						                   description: "Learn about the factors that affect the quality of your sleep.",
						                   destinationView: AdviceView(sheetType: .sleepImprovementAdvice,
						                                               showAdvice: $showSleepImportance),
						                   showModalView: $showSleepImportance)
							.usefulInfoCardBackground(
								color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor))
							)
					}
				}
			}
			.navigationTitle("\(Date().getFormattedDate(format: "E, MMMM d"))")
			.onAppear(perform: self.sendAnalytics)
		}
	}

	// MARK: Private methods

	private func getStatisticCells(generalViewModel: SummaryGeneralDataViewModel) -> [StatisticsCellViewModel] {
		return [
			StatisticsCellViewModel(title: "Sleep start",
			                   value: generalViewModel.sleepInterval.start.getFormattedDate(format: "HH:mm")),
			StatisticsCellViewModel(title: "Wake up",
			                   value: generalViewModel.sleepInterval.end.getFormattedDate(format: "HH:mm")),
			StatisticsCellViewModel(title: "Fall asleep",
			                   value: generalViewModel.sleepInterval.start.hoursMinutes(from: generalViewModel.inbedInterval.start)),
			StatisticsCellViewModel(title: "Time asleep",
			                   value: generalViewModel.sleepInterval.end.hoursMinutes(from: generalViewModel.sleepInterval.start)),
			StatisticsCellViewModel(title: "Time in bed",
			                   value: generalViewModel.inbedInterval.end.hoursMinutes(from: generalViewModel.inbedInterval.start)),
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

import SwiftUI
import HKStatistics
import HKVisualKit
import HKCoreSleep
import XUI

struct GeneralCardDetailView: View {
    
    @EnvironmentObject var cardService: CardService
    @Store var viewModel: CardDetailsViewCoordinator

    var body: some View {
        // NavigationView
        GeometryReader { geometry in
            ZStack {

                viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.appBackgroundColor))
                    .edgesIgnoringSafeArea(.all)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .center) {

                        if let bankOfSleepViewModel = cardService.bankOfSleepViewModel {
                            CardNameTextView(text: "Bank",
                                             color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))
                                .padding(.top)

                            CardWithChartView(colorProvider: viewModel.colorProvider,
                                              systemImageName: "banknote.fill",
                                              titleText: "Sleep: bank",
                                              mainTitleText: "Total backlog from your goal during last 2 weeks is \(bankOfSleepViewModel.backlog).",
                                              titleColor: viewModel.colorProvider.sleepyColorScheme.getColor(of: .phases(.deepSleepColor)),
                                              showChevron: false,
                                              chartView: VerticalProgressChartView(foregroundElementColor: viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor)),
                                                                                   backgroundElementColor: viewModel.colorProvider.sleepyColorScheme.getColor(of: .chartColors(.verticalProgressChartElement)),
                                                                                   chartHeight: 100,
                                                                                   points: bankOfSleepViewModel.bankOfSleepData,
                                                                                   dragGestureEnabled: false),
                                              bottomView: CardBottomSimpleDescriptionView(descriptionText:
                                                                                            Text("Sleep for ")
                                                                                          + Text("\(bankOfSleepViewModel.timeToCloseDebt)")
                                                                                            .foregroundColor(viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor)))
                                                                                            .bold()
                                                                                          + Text(" every day to pay off the debt."),
                                                                                          colorProvider: viewModel.colorProvider))
                                .roundedCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
                        }

                        if let generalViewModel = cardService.generalViewModel {
                            CardNameTextView(text: "Summary".localized,
                                             color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))

                            HorizontalStatisticCellView(data: [StatisticsCellData(title: "Sleep start".localized, value: generalViewModel.sleepInterval.start.getFormattedDate(format: "HH:mm")),
                                                               StatisticsCellData(title: "Wake up".localized, value: generalViewModel.sleepInterval.end.getFormattedDate(format: "HH:mm")),
                                                               StatisticsCellData(title: "Fall asleep".localized, value: generalViewModel.sleepInterval.start.hoursMinutes(from: generalViewModel.inbedInterval.start)),
                                                               StatisticsCellData(title: "Time asleep".localized, value: generalViewModel.sleepInterval.end.hoursMinutes(from: generalViewModel.sleepInterval.start)),
                                                               StatisticsCellData(title: "Time in bed".localized,
                                                                                  value: generalViewModel.inbedInterval.start.hoursMinutes(from: generalViewModel.inbedInterval.start))
                                                              ],
                                                        colorScheme: viewModel.colorProvider.sleepyColorScheme)

                            CardNameTextView(text: "Statistics".localized,
                                             color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))

                            ProgressChartView(titleText: "Sleep: goal".localized,
                                              mainText: String(format: "Your sleep duration was %@, it is %d of your goal".localized,
                                                               generalViewModel.sleepInterval.end.hoursMinutes(from: generalViewModel.sleepInterval.start),  ((generalViewModel.sleepInterval.duration / 60.0) - Double(generalViewModel.sleepGoal)) / 100.0),
                                              systemImage: "zzz",
                                              colorProvider: viewModel.colorProvider,
                                              currentProgress: ProgressItem(title: "Your sleep goal".localized,
                                                                            text: Date.minutesToClearString(minutes: generalViewModel.sleepGoal),
                                                                            value: generalViewModel.sleepGoal),
                                              beforeProgress: ProgressItem(title: "Sleep duration today".localized,
                                                                           text: Date.minutesToClearString(minutes: Int(generalViewModel.sleepInterval.duration) / 60),
                                                                           value: Int(generalViewModel.sleepInterval.duration) / 60),
                                              analysisString: getAnalysisString(),
                                              mainColor: viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor)),
                                              mainTextColor: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))
                                .roundedCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
                        }

                        CardNameTextView(text: "What else?".localized,
                                         color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))

                        UsefulInfoCardView(imageName: "sleep1", title: "title", description: "description")
                            .usefulInfoCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))

                        UsefulInfoCardView(imageName: "sleep2", title: "title", description: "description")
                            .usefulInfoCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
                    }
                }
            }
            .navigationTitle("\(Date().getFormattedDate(format: "E, MMMM d"))")
        }
    }

    // MARK: Addittional methods

    private func getAnalysisString() -> String {
        return ""
        let provider = viewModel.statisticsProvider
        guard let sleepGoal = provider.getTodayFallingAsleepDuration(),
              let sleepDuration = viewModel.statisticsProvider.getData(for: .asleep) else { return "" }
        let sleepGoalPercentage = Int((Double(sleepDuration) / Double(sleepGoal)) * 100)
        if sleepGoalPercentage < 80 {
            return "Pay more attention to your sleep to be more healthy and productive every day!".localized
        } else if sleepGoalPercentage >= 80 && sleepGoalPercentage < 100 {
            return "You can do better! For a reminder, sleep is the key to longevity and youth!".localized
        } else {
            return "Amazing result for today. Keep it up and stay healthy!".localized
        }
    }
    
}

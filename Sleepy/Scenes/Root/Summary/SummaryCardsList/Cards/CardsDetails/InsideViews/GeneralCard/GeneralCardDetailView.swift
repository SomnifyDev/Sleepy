import SwiftUI
import HKStatistics
import HKVisualKit
import HKCoreSleep
import XUI
import SettingsKit

struct GeneralCardDetailView: View {
    
    @EnvironmentObject var cardService: CardService
    @Store var viewModel: CardDetailsViewCoordinator
    @State private var showAdvice = false
    @State private var activeSheet: AdviceType?

    var body: some View {
        GeometryReader { geometry in
            ZStack {

                viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.appBackgroundColor))
                    .edgesIgnoringSafeArea(.all)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .center) {

                        // MARK: Bank of sleep

                        if let bankOfSleepViewModel = cardService.bankOfSleepViewModel {
                            CardNameTextView(text: "Bank",
                                             color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))
                                .padding(.top)

                            CardWithChartView(colorProvider: viewModel.colorProvider,
                                              systemImageName: "banknote.fill",
                                              titleText: "Sleep: bank".localized,
                                              mainTitleText: String(format: "Total backlog from your goal during last 2 weeks is %@".localized, bankOfSleepViewModel.backlog),
                                              titleColor: viewModel.colorProvider.sleepyColorScheme.getColor(of: .phases(.deepSleepColor)),
                                              showChevron: false,
                                              chartView: VerticalProgressChartView(
                                                foregroundElementColor: viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor)),
                                                backgroundElementColor: viewModel.colorProvider.sleepyColorScheme.getColor(of: .chartColors(.verticalProgressChartElement)),
                                                chartHeight: 100,
                                                points: bankOfSleepViewModel.bankOfSleepData,
                                                dragGestureEnabled: false),
                                              bottomView: CardBottomSimpleDescriptionView(descriptionText:
                                                                                            Text("Sleep for ".localized)
                                                                                          + Text("\(bankOfSleepViewModel.timeToCloseDebt)")
                                                                                            .foregroundColor(viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor)))
                                                                                            .bold()
                                                                                          + Text(" every day to pay off the debt.".localized),
                                                                                          colorProvider: viewModel.colorProvider))
                                .roundedCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
                        }

                        // MARK: Main statistics block

                        if let generalViewModel = cardService.generalViewModel {
                            CardNameTextView(text: "Summary".localized,
                                             color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))

                            HorizontalStatisticCellView(data: getStatisticCells(generalViewModel: generalViewModel),
                                                        colorScheme: viewModel.colorProvider.sleepyColorScheme)

                            CardNameTextView(text: "Statistics".localized,
                                             color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))

                            ProgressChartView(titleText: "Sleep: goal".localized,
                                              mainText:
                                                String(format: "Your sleep duration was %@, it is %u%% of your goal".localized,
                                                       generalViewModel.sleepInterval.end.hoursMinutes(from: generalViewModel.sleepInterval.start),
                                                       getGoalPercentage(viewModel: generalViewModel)),
                                              systemImage: "zzz",
                                              colorProvider: viewModel.colorProvider,
                                              currentProgress: ProgressItem(title: "Your sleep goal".localized,
                                                                            text: Date.minutesToClearString(minutes: generalViewModel.sleepGoal),
                                                                            value: generalViewModel.sleepGoal),
                                              beforeProgress: ProgressItem(title: "Sleep duration today".localized,
                                                                           text: Date.minutesToClearString(minutes: Int(generalViewModel.sleepInterval.duration) / 60),
                                                                           value: Int(generalViewModel.sleepInterval.duration) / 60),
                                              analysisString: getAnalysisString(viewModel: generalViewModel),
                                              mainColor: viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor)),
                                              mainTextColor: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))
                                .roundedCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
                        }

                        CardNameTextView(text: "What else?".localized,
                                         color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))

                        // MARK: Advices

                        UsefulInfoCardView(imageName: "sleep1", title: "Why sleep is so important?".localized, description: "Learn more about the role of sleep in your life.".localized)
                            .usefulInfoCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
                            .onTapGesture {
                                showAdvice = true
                                activeSheet = .sleepImportance
                            }

                        UsefulInfoCardView(imageName: "sleep2", title: "How to improve your sleep?".localized, description: "Learn about the factors that affect the quality of your sleep.".localized)
                            .usefulInfoCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
                            .onTapGesture {
                                showAdvice = true
                                activeSheet = .sleepImprovement
                            }
                    }
                }.sheet(isPresented: $showAdvice, onDismiss: nil, content: {
                    if let activeSheet = activeSheet {
                        AdviceView(sheetType: activeSheet)
                    }
                })
            }
            .navigationTitle("\(Date().getFormattedDate(format: "E, MMMM d"))")
        }
    }

    // MARK: Getting data methods

    private func getStatisticCells(generalViewModel: SummaryGeneralDataViewModel) -> [StatisticsCellData] {
        return [
            StatisticsCellData(title: "Sleep start".localized,
                               value: generalViewModel.sleepInterval.start.getFormattedDate(format: "HH:mm")),
            StatisticsCellData(title: "Wake up".localized,
                               value: generalViewModel.sleepInterval.end.getFormattedDate(format: "HH:mm")),
            StatisticsCellData(title: "Fall asleep".localized,
                               value: generalViewModel.sleepInterval.start.hoursMinutes(from: generalViewModel.inbedInterval.start)),
            StatisticsCellData(title: "Time asleep".localized,
                               value: generalViewModel.sleepInterval.end.hoursMinutes(from: generalViewModel.sleepInterval.start)),
            StatisticsCellData(title: "Time in bed".localized,
                               value: generalViewModel.inbedInterval.end.hoursMinutes(from: generalViewModel.inbedInterval.start))
        ]
    }

    // MARK: Addittional methods

    private func getAnalysisString(viewModel: SummaryGeneralDataViewModel) -> String {
        let sleepDuration = viewModel.sleepInterval.duration / 60.0
        let sleepGoalPercentage = Int((Double(sleepDuration) / Double(viewModel.sleepGoal)) * 100)
        if sleepGoalPercentage < 80 {
            return "Pay more attention to your sleep to be more healthy and productive every day!".localized
        } else if sleepGoalPercentage >= 80 && sleepGoalPercentage < 100 {
            return "You can do better! For a reminder, sleep is the key to longevity and youth!".localized
        } else {
            return "Amazing result for today. Keep it up and stay healthy!".localized
        }
    }

    private func getGoalPercentage(viewModel: SummaryGeneralDataViewModel) -> Int {
        let sleepDuration = viewModel.sleepInterval.duration / 60.0
        let sleepGoal = Double(viewModel.sleepGoal)
        return Int((sleepDuration / sleepGoal) * 100)
    }
    
}

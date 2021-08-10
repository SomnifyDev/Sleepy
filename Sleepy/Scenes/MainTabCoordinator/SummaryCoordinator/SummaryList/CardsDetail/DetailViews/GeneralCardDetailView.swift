import SwiftUI
import HKStatistics
import HKVisualKit
import HKCoreSleep
import XUI

struct GeneralCardDetailView: View {

    // MARK: Stored Propertie

    @Store var viewModel: CardDetailViewCoordinator

    // MARK: State properties

    @State var generalViewModel: SummaryGeneralDataViewModel?
    @State var bankOfSleepViewModel: BankOfSleepDataViewModel?

    // MARK: Body

    var body: some View {
        GeometryReader { geometry in
            ZStack {

                viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.appBackgroundColor))
                    .edgesIgnoringSafeArea(.all)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .center) {

                        if let bankOfSleepViewModel = bankOfSleepViewModel {
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

                        if let generalViewModel = generalViewModel {
                            CardNameTextView(text: "Summary",
                                             color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))

                            HorizontalStatisticCellView(data: [StatisticsCellData(title: "Sleep start", value: generalViewModel.sleepStart),
                                                               StatisticsCellData(title: "Wake up", value: generalViewModel.sleepEnd),
                                                               StatisticsCellData(title: "Falling asleep", value: generalViewModel.fallAsleepDuration),
                                                               StatisticsCellData(title: "Time asleep", value: generalViewModel.sleepDuration),
                                                               StatisticsCellData(title: "Time in bed", value: generalViewModel.inBedDuration)],
                                                        colorScheme: viewModel.colorProvider.sleepyColorScheme)

                            CardNameTextView(text: "Statistics",
                                             color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))

                            ProgressChartView(titleText: "Sleep: goal",
                                              mainText: "Your sleep duration was \(generalViewModel.sleepDuration). It is \(getGoalPercentage())% of your goal.",
                                              systemImage: "zzz",
                                              colorProvider: viewModel.colorProvider,
                                              currentProgress: ProgressItem(title: "Your sleep goal",
                                                                            text: Date.minutesToClearString(minutes: getSleepGoal()),
                                                                            value: getSleepGoal()),
                                              beforeProgress: ProgressItem(title: "Today sleep duration",
                                                                           text: generalViewModel.sleepDuration,
                                                                           value: viewModel.statisticsProvider.getData(for: .asleep)),
                                              analysisString: getAnalysisString(),
                                              mainColor: viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor)))
                                .roundedCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
                        }

                        CardNameTextView(text: "What else?",
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
        .onAppear {
            getSleepData()
            getbankOfSleepInfo()
        }
    }

    // MARK: Sleep data

    private func getSleepData() {
        let provider = viewModel.statisticsProvider
        let sleepDuration = provider.getData(for: .asleep)
        let inBedDuration = provider.getData(for: .inBed)

        generalViewModel = SummaryGeneralDataViewModel(sleepStart: provider.getTodaySleepIntervalBoundary(boundary: .start),
                                                       sleepEnd: provider.getTodaySleepIntervalBoundary(boundary: .end),
                                                       sleepDuration: Date.minutesToClearString(minutes: sleepDuration),
                                                       inBedDuration: Date.minutesToClearString(minutes: inBedDuration),
                                                       fallAsleepDuration: provider.getTodayFallingAsleepDuration())
    }

    private func getbankOfSleepInfo() {
        let provider = viewModel.statisticsProvider
        let sleepGoal = getSleepGoal()
        guard
            let twoWeeksBackDate = Calendar.current.date(byAdding: .day, value: -14, to: Date())
        else {
            return
        }
        provider.getDataByInterval(healthType: .asleep, for: DateInterval(start: twoWeeksBackDate, end: Date()), bundlePrefixes: ["com.sinapsis", "com.benmustafa"]) { data in
            if data.count == 14 {

                let bankOfSleepData = data.map({$0 / Double(sleepGoal)})

                let backlogValue = Int(data.reduce(0.0) { $1 < Double(sleepGoal) ? $0 + (Double(sleepGoal) - $1) : $0 + 0 })
                let backlogString = Date.minutesToClearString(minutes: backlogValue)

                let timeToCloseDebtValue = backlogValue / 14 + sleepGoal
                let timeToCloseDebtString = Date.minutesToClearString(minutes: timeToCloseDebtValue)

                self.bankOfSleepViewModel = BankOfSleepDataViewModel(bankOfSleepData: bankOfSleepData,
                                                                     backlog: backlogString,
                                                                     timeToCloseDebt: timeToCloseDebtString)
            }
        }
    }

    private func getGoalPercentage() -> Int {
        let sleepGoal = getSleepGoal()
        return Int((Double(viewModel.statisticsProvider.getData(for: .asleep)) / Double(sleepGoal)) * 100)
    }

    // MARK: Addittional methods

    private func getAnalysisString() -> String {
        let sleepGoalPercentage = getGoalPercentage()
        if sleepGoalPercentage < 80 {
            return "Not the best result for today. Pay more attention to your sleep to be more healthy and productive every day!"
        } else if sleepGoalPercentage >= 80 && sleepGoalPercentage < 100 {
            return "Not bad result, but you can do it better for sure. For a reminder, sleep is the key to longevity and youth!"
        } else {
            return "Amazing result for today. Keep up the good work and stay healthy!"
        }
    }

    private func getSleepGoal() -> Int {
        guard
            let sleepGoal = viewModel.settingsProvider.getSetting(type: .sleepGoal) as? Int
        else {
            assertionFailure("Invalid setting type returned")
            return 0
        }
        return sleepGoal
    }
    
}

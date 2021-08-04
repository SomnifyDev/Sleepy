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
                                              currentWeeksProgress: ProgressItem(title: "Sleep goal", text: "8h 0min", value: 1),
                                              beforeWeeksProgress: ProgressItem(title: "Today sleep duration", text: "8h 0min", value: 1),
                                              analysisString: "Amazing result for today!", // я просто устал, потом придумаю анализ какой-нибудь сюда
                                              mainColor: .blue)
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
                                                       sleepDuration: "\(sleepDuration / 60)h \(sleepDuration - (sleepDuration / 60) * 60)min",
                                                       inBedDuration: "\(inBedDuration / 60)h \(inBedDuration - (inBedDuration / 60) * 60)min",
                                                       fallAsleepDuration: provider.getTodayFallingAsleepDuration())
    }

    private func getbankOfSleepInfo() {
        let provider = viewModel.statisticsProvider
        guard
            let twoWeeksBackDate = Calendar.current.date(byAdding: .day, value: -14, to: Date())
        else {
            return
        }
        provider.getDataByInterval(healthType: .asleep, for: DateInterval(start: twoWeeksBackDate, end: Date()), bundlePrefixes: ["com.sinapsis", "com.benmustafa"]) { data in
            if data.count == 14 {

                // TODO: 480.0 заменить на нормальную цель сна пользователя

                let bankOfSleepData = data.map({$0 / 480.0})

                let backlogValue = Int(data.reduce(0.0) { $1 < 480 ? $0 + (480 - $1) : $0 + 0 })
                let backlogString = "\(backlogValue / 60)h \(backlogValue - (backlogValue / 60) * 60)min"

                let timeToCloseDebtValue = backlogValue / 14 + 480
                let timeToCloseDebtString = "\(timeToCloseDebtValue / 60)h \(timeToCloseDebtValue - (timeToCloseDebtValue / 60) * 60)min"

                self.bankOfSleepViewModel = BankOfSleepDataViewModel(bankOfSleepData: bankOfSleepData,
                                                                     backlog: backlogString,
                                                                     timeToCloseDebt: timeToCloseDebtString)
            }
        }
    }

    private func getGoalPercentage() -> Int {

        // TODO: 480.0 заменить на нормальную цель сна пользователя

        return Int((Double(viewModel.statisticsProvider.getData(for: .asleep)) / 480.0) * 100)
    }
    
}

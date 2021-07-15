import SwiftUI
import XUI
import HKVisualKit

struct FeedListView: View {

    // MARK: Stored Properties

    @Store var viewModel: FeedListCoordinator

    // MARK: Views

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.appBackgroundColor))
                    .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(alignment: .center) {
                        CardNameTextView(text: "Sleep information",
                                         color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))
                            .padding(.top)

                        SummaryInfoCardView(colorProvider: viewModel.colorProvider, sleepStartTime: "23:00", sleepDuration: "7h 54m", awakeTime: "6:54", fallingAsleepDuration: "10m")
                            .roundedCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))

                        CardNameTextView(text: "Sleep session",
                                             color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))

                        CardWithChartView(colorProvider: viewModel.colorProvider,
                                          systemImageName: "sleep",
                                          titleText: "Sleep: phases",
                                          mainTitleText: "Here is the info about phases of your last sleep.",
                                          titleColor: viewModel.colorProvider.sleepyColorScheme.getColor(of: .phases(.deepSleepColor)),
                                          chartView: StandardChartView(colorProvider: viewModel.colorProvider,
                                                                       chartType: .phasesChart,
                                                                       chartHeight: 100,
                                                                       points: [0.75, 1, 0.3, 0.45, 0.2, 0.35, 0.45, 0.25, 0.65, 0.8, 0.85, 0.9, 0.45, 0.1, 0.65, 0.45, 0.2, 0.35, 0.5, 0.2, 0.6, 0.8, 1],
                                                                       dragGestureData: "",
                                                                       chartColor: .blue,
                                                                       needOXLine: true,
                                                                       needTimeLine: true,
                                                                       startTime: "23:00",
                                                                       endTime: "6:54",
                                                                       needDragGesture: false),
                                          bottomView: CardBottomSimpleDescriptionView(colorProvider: viewModel.colorProvider,
                                                                                      descriptionText:
                                                                                        Text("The duration of light phase was ")
                                                                                      + Text("3h 45min").foregroundColor(viewModel.colorProvider.sleepyColorScheme.getColor(of: .phases(.lightSleepColor))).bold()
                                                                                      + Text(", while the duration of deep phase was ")
                                                                                      + Text("2h 12min").foregroundColor(viewModel.colorProvider.sleepyColorScheme.getColor(of: .phases(.deepSleepColor))).bold()
                                                                                      + Text(".")))
                            .roundedCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))

                        CardNameTextView(text: "Heart rate",
                                             color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))

                        CardWithChartView(colorProvider: viewModel.colorProvider,
                                          systemImageName: "suit.heart.fill",
                                          titleText: "Sleep: heart rate",
                                          mainTitleText: "Here is the info about heart rate of your last sleep.",
                                          titleColor: viewModel.colorProvider.sleepyColorScheme.getColor(of: .heart(.heartColor)),
                                          chartView: StandardChartView(colorProvider: viewModel.colorProvider,
                                                                       chartType: .defaultChart,
                                                                       chartHeight: 100,
                                                                       points: [67, 44, 55, 42, 71, 61, 47, 51, 65, 68, 43 ,50 ,53 ,57 ,45 ,56, 70 ,60 ,66 ,49],
                                                                       dragGestureData: "",
                                                                       chartColor: viewModel.colorProvider.sleepyColorScheme.getColor(of: .heart(.heartColor)),
                                                                       needOXLine: true,
                                                                       needTimeLine: true,
                                                                       startTime: "23:00",
                                                                       endTime: "6:54",
                                                                       needDragGesture: false),
                                          bottomView: CardBottomSimpleDescriptionView(colorProvider: viewModel.colorProvider,
                                                                                      descriptionText:
                                                                                        Text("The maximal heartbeat was ")
                                                                                      + Text("71 bpm").foregroundColor(viewModel.colorProvider.sleepyColorScheme.getColor(of: .heart(.heartColor))).bold()
                                                                                      + Text(", while the minimal was ")
                                                                                      + Text("42 bpm").foregroundColor(viewModel.colorProvider.sleepyColorScheme.getColor(of: .heart(.heartColor))).bold()
                                                                                      + Text(".")))
                            .roundedCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
                    }
                }
            }
        }
        .navigationTitle("Summary, \(Date().getFormattedDate(format: "MMM d"))")
//        List(viewModel.cards ?? []) { card in
//            HStack {
//                containedView(card: card)
//            }
//            .onNavigation {
//                viewModel.open(card)
//            }
//        }
    }

    // MARK: Internal methods

    func containedView(card: CardType) -> AnyView {
        switch card {

        case .heart:
            return AnyView(HeartCardView().frame(height: 250))

        case .general:
            return AnyView(GeneralCardView().frame(height: 50))

        case .phases:
            return AnyView(PhasesCardView().frame(height: 150))

        }
    }

}

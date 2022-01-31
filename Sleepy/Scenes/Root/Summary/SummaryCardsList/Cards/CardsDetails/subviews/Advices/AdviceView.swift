// Copyright (c) 2022 Sleepy.

import FirebaseAnalytics
import SwiftUI

enum AdviceType: String {
    case sleepImportanceAdvice
    case sleepImprovementAdvice
    case phasesAdvice
    case heartAdvice
}

struct AdviceView: View {
    @Binding private var showAdvice: Bool
    @State private var viewModel: AdviceViewModel
    private let sheetType: AdviceType

    init(sheetType: AdviceType, showAdvice: Binding<Bool>) {
        self.sheetType = sheetType
        _showAdvice = showAdvice
        self.viewModel = AdviceViewModel(
            navigationTitle: "",
            image: Image(systemName: "zzz"),
            mainTitle: "",
            firstText: "",
            secondaryTitle: "",
            secondText: ""
        )
    }

    var body: some View {
        NavigationView {
            GeometryReader { g in
                ScrollView {
                    VStack(alignment: .leading) {
                        viewModel.image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: g.size.width, height: 300)

                        Text(viewModel.mainTitle)
                            .font(.title)
                            .bold()
                            .padding([.trailing, .leading])

                        Text(viewModel.firstText)
                            .padding([.trailing, .leading])
                            .padding(.top, 8)

                        Text(viewModel.secondaryTitle)
                            .font(.title)
                            .bold()
                            .padding([.top, .trailing, .leading])

                        Text(viewModel.secondText)
                            .padding([.trailing, .leading])
                            .padding(.top, 8)

                        Spacer()
                    }
                }
            }
            .onAppear {
                self.viewModel = AdviceViewModel(
                    navigationTitle: getNavigationTitle(),
                    image: Image(sheetType.rawValue),
                    mainTitle: getMainTitle(),
                    firstText: getFirstText(),
                    secondaryTitle: getSecondaryTitle(),
                    secondText: getSecondText()
                )
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(self.viewModel.navigationTitle)
            .navigationBarItems(trailing: Button(action: {
                showAdvice = false
            }, label: {
                Text("Done")
                    .fontWeight(.bold)

            }))
            .onAppear(perform: self.sendAnalytics)
        }
    }

    private func sendAnalytics() {
        FirebaseAnalytics.Analytics.logEvent("Advice_viewed", parameters: [
            "type": self.sheetType.rawValue,
        ])
    }

    // MARK: Configuration methods

    private func getNavigationTitle() -> String {
        switch self.sheetType {
        case .sleepImportanceAdvice:
            return "Sleep importance".localized
        case .sleepImprovementAdvice:
            return "Sleep improvement".localized
        case .phasesAdvice:
            return "Phases and stages".localized
        case .heartAdvice:
            return "Heart and sleep".localized
        }
    }

    private func getMainTitle() -> String {
        switch self.sheetType {
        case .sleepImportanceAdvice:
            return "Why is sleep so important?".localized
        case .sleepImprovementAdvice:
            return "How to improve your sleep?".localized
        case .phasesAdvice:
            return "Sleep phases and stages".localized
        case .heartAdvice:
            return "Learn more about the importance of sleep for heart health.".localized
        }
    }

    private func getFirstText() -> String {
        switch self.sheetType {
        case .sleepImportanceAdvice:
            return "SleepImportanceFirstText".localized
        case .sleepImprovementAdvice:
            return "SleepImprovementFirstText".localized
        case .phasesAdvice:
            return "PhasesFirstText".localized
        case .heartAdvice:
            return "FirstTextHeartAdvice".localized
        }
    }

    private func getSecondaryTitle() -> String {
        switch self.sheetType {
        case .sleepImportanceAdvice:
            return "How does sleep make us function better?".localized
        case .sleepImprovementAdvice:
            return "Take some tips to sleep better".localized
        case .phasesAdvice:
            return ""
        case .heartAdvice:
            return "Take care of your sleep".localized
        }
    }

    private func getSecondText() -> String {
        switch self.sheetType {
        case .sleepImportanceAdvice:
            return "SleepImportanceSecondText".localized
        case .sleepImprovementAdvice:
            return "SleepImprovementSecondText".localized
        case .phasesAdvice:
            return ""
        case .heartAdvice:
            return "SecondTextHeartAdvice".localized
        }
    }
}

//
//  AdviceView.swift
//  Sleepy
//
//  Created by Анас Бен Мустафа on 9/22/21.
//

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
        print("initing")
        self.sheetType = sheetType
        _showAdvice = showAdvice
        viewModel = AdviceViewModel(navigationTitle: "getNavigationTitle()",
                                    imageName: sheetType.rawValue,
                                    mainTitle: "getMainTitle()",
                                    firstText: "getFirstText()",
                                    secondaryTitle: "getSecondaryTitle()",
                                    secondText: "getSecondText()")
    }

    var body: some View {
        GeometryReader { g in
            ScrollView {
                VStack (alignment: .leading) {
                    Image(viewModel.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: g.size.width, height: 300)

                    Text(viewModel.mainTitle)
                        .font(.title)
                        .bold()
                        .padding([.top, .trailing, .leading])

                    Text(viewModel.firstText)
                        .padding([.top, .trailing, .leading])

                    Text(viewModel.secondaryTitle)
                        .font(.title)
                        .bold()
                        .padding([.top, .trailing, .leading])

                    Text(viewModel.secondText)
                        .padding([.trailing, .leading])
                        .navigationBarItems(trailing: Button(action: {
                            showAdvice = false
                        }, label: {
                            Text("Done".localized)
                                .fontWeight(.regular)
                        }))
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationTitle(viewModel.navigationTitle)

                    Spacer()
                }
            }
//            .onAppear {
//                viewModel = AdviceViewModel(navigationTitle: getNavigationTitle(),
//                                            imageName: sheetType.rawValue,
//                                            mainTitle: getMainTitle(),
//                                            firstText: getFirstText(),
//                                            secondaryTitle: getSecondaryTitle(),
//                                            secondText: getSecondText())
//            }
        }
    }

    // MARK: Configuration methods

    private func getNavigationTitle() -> String {
        switch sheetType {
        case .sleepImportanceAdvice:
            return "Sleep importance"
        case .sleepImprovementAdvice:
            return "Sleep improvement"
        case .phasesAdvice:
            return "Phases and stages"
        case .heartAdvice:
            return "Heart and sleep"
        }
    }

    private func getMainTitle() -> String {
        switch sheetType {
        case .sleepImportanceAdvice:
            return "Why sleep is so important?".localized
        case .sleepImprovementAdvice:
            return "How to improve your sleep?".localized
        case .phasesAdvice:
            return "Sleep phases and stages".localized
        case .heartAdvice:
            return "Learn more about the importance of sleep for heart health.".localized
        }
    }

    private func getFirstText() -> String {
        return ""
        //        switch sheetType {
        //        case .sleepImportanceAdvice:
        //            <#code#>
        //        case .sleepImprovementAdvice:
        //            <#code#>
        //        case .phasesAdvice:
        //            <#code#>
        //        case .heartAdvice:
        //            <#code#>
        //        }
    }

    private func getSecondaryTitle() -> String {
        return ""
        //        switch sheetType {
        //        case .sleepImportanceAdvice:
        //            <#code#>
        //        case .sleepImprovementAdvice:
        //            <#code#>
        //        case .phasesAdvice:
        //            <#code#>
        //        case .heartAdvice:
        //            <#code#>
        //        }
    }

    private func getSecondText() -> String {
        return ""
        //        switch sheetType {
        //        case .sleepImportanceAdvice:
        //            <#code#>
        //        case .sleepImprovementAdvice:
        //            <#code#>
        //        case .phasesAdvice:
        //            <#code#>
        //        case .heartAdvice:
        //            <#code#>
        //        }
    }

}

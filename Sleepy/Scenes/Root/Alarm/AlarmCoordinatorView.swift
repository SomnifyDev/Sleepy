// Copyright (c) 2021 Sleepy.

import Foundation
import HKVisualKit
import SwiftUI
import XUI

struct AlarmCoordinatorView: View {
    @Store var viewModel: AlarmCoordinator

    private enum Constant {
        static let smallTopPadding: CGFloat = 4
        static let appleWatchImageheight: CGFloat = 400
    }

    var body: some View {
        GeometryReader { g in
            NavigationView {
                ZStack {
                    viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.appBackgroundColor))
                        .edgesIgnoringSafeArea(.all)
                    ScrollView {
                        VStack(alignment: .leading) {
                            Image("night")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(.top)

                            SectionNameTextView(
                                text: "What is a smart alarm?",
                                color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText))
                            )
                                .padding(.top)

                            Text("What is a smart alarm description")
                                .padding([.trailing, .leading, .bottom])
                                .padding(.top, Constant.smallTopPadding)

                            SectionNameTextView(
                                text: "Improve your sleep with smart alarm",
                                color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText))
                            )

                            Text("Improve your sleep with smart alarm description")
                                .padding([.trailing, .leading, .bottom])
                                .padding(.top, Constant.smallTopPadding)

                            SectionNameTextView(
                                text: "How to use smart alarm in Sleepy?",
                                color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText))
                            )

                            Text("How to use smart alarm in Sleepy description")
                                .padding([.trailing, .leading])
                                .padding(.top, Constant.smallTopPadding)

                            HStack(alignment: .center) {
                                Image("alarmMain")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(
                                        width: g.size.width / 2,
                                        height: Constant.appleWatchImageheight,
                                        alignment: .center
                                    )

                                Image("alarmInside")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(
                                        width: g.size.width / 2,
                                        height: Constant.appleWatchImageheight,
                                        alignment: .center
                                    )
                            }
                        }
                    }
                    .navigationBarTitle(
                        "Smart alarm",
                        displayMode: .large
                    )
                }
            }
        }
    }
}

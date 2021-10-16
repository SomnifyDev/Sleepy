//
//  AlarmCoordinatorView.swift
//  Sleepy
//
//  Created by Анас Бен Мустафа on 6/14/21.
//

import Foundation
import SwiftUI
import XUI
import HKVisualKit

struct AlarmCoordinatorView: View {
    
    @Store var viewModel: AlarmCoordinator

    private enum Constant {
        static let smallTopPadding: CGFloat = 4
        static let appleWatchImageheight: CGFloat = 400
    }
    
    var body: some View {
        GeometryReader { g in
            NavigationView {
                ScrollView {
                    VStack (alignment: .leading) {
                        Image("night")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.top)

                        SectionNameTextView(
                            text: "What is a smart alarm?".localized,
                            color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText))
                        )
                            .padding(.top)

                        Text("What is a smart alarm description".localized)
                            .padding([.trailing, .leading, .bottom])
                            .padding(.top, Constant.smallTopPadding)

                        SectionNameTextView(
                            text: "Improve your sleep with smart alarm".localized,
                            color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText))
                        )

                        Text("Improve your sleep with smart alarm description".localized)
                            .padding([.trailing, .leading, .bottom])
                            .padding(.top, Constant.smallTopPadding)

                        SectionNameTextView(
                            text: "How to use smart alarm in Sleepy?".localized,
                            color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText))
                        )

                        Text("How to use smart alarm in Sleepy description".localized)
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
                    "Smart alarm".localized,
                    displayMode: .large
                )
            }
        }
    }

}

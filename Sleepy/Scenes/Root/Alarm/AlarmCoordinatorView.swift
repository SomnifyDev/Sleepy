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

// Че такое умный будильник
// Почему стоит его использовать
// Как его использовать?

struct AlarmCoordinatorView: View {
    
    //    @Store var viewModel: AlarmCoordinator

    // TODO: Localize
    // TODO: ColorProvider

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
                            text: "What is a smart alarm?",
                            color: .black
                        )
                            .padding(.top)

                        Text("A smart alarm is a function integrated into the Sleepy Apple Watch App that will prompt you to wake up during the REM-sleep phase.")
                            .padding([.trailing, .leading, .bottom])
                            .padding(.top, Constant.smallTopPadding)

                        SectionNameTextView(
                            text: "Improve your sleep with smart alarm",
                            color: .black
                        )

                        Text("The main goal of a smart alarm is to wake you up in a REM-phase of sleep. Smart alarm feature will monitor when you are in a REM-phase during the indicated time period and will go off at the end of the REM phase. This makes waking up considerably less stressful for your body.")
                            .padding([.trailing, .leading, .bottom])
                            .padding(.top, Constant.smallTopPadding)

                        SectionNameTextView(
                            text: "How to use smart alarm in Sleepy?",
                            color: .black
                        )

                        Text("To set smart alarm, open your Apple Watch Sleepy App and select the desired wake up time.")
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

struct AlarmCoordinatorView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmCoordinatorView()
    }
}

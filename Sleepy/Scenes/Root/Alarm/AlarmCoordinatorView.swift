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
    
    var body: some View {
        GeometryReader { g in
            NavigationView {
                ScrollView {
                    VStack (alignment: .leading) {

                        SectionNameTextView(
                            text: "What is a smart alarm?",
                            color: .black
                        )
                            .padding(.top)

                        Image("night")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: g.size.width, height: 250)

                        Text("A smart alarm is a function integrated into the Sleepy that will prompt you to wake up during the REM-sleep phase.")
                            .padding()

                        SectionNameTextView(
                            text: "Improve your sleep with smart alarm",
                            color: .black
                        )

                        Text("The main goal of a smart alarm is to wake you up in a REM-phase of sleep. Smart alarm feature will monitor when you are in a REM-phase during the indicated time period and will go off at the end of the REM phase. This makes waking up considerably less stressful for your body. ")
                            .padding([.trailing, .leading, .bottom])
                            .padding(.top, 4)

                        SectionNameTextView(
                            text: "How to use smart alarm in Sleepy?",
                            color: .black
                        )

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

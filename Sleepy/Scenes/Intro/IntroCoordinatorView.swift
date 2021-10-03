//
//  IntroCoordinatorView.swift
//  IntroCoordinatorView
//
//  Created by Никита Казанцев on 25.09.2021.
//

import SwiftUI

import SwiftUI
import XUI
import FirebaseAnalytics

struct IntroCoordinatorView: View {

    @Store var viewModel: IntroCoordinator
    @Binding var shouldShowIntro: Bool
    var body: some View {
        MainIntroView(colorScheme: viewModel.colorSchemeProvider.sleepyColorScheme, shouldShowIntro: self.$shouldShowIntro)
//        TabView(selection: $viewModel.tab) {
//            MainIntroView().tag(PageTab.first)
//            FeaturesIntroView().tag(PageTab.features)
//                    }
//        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
//        .indexViewStyle(.page(backgroundDisplayMode: PageIndexViewStyle.BackgroundDisplayMode.always))
//        TabView {
//            EmptyView()
//                .background(Color.green)
//
//            EmptyView()
//                .background(Color.yellow)
//
//            EmptyView()
//                .background(Color.red)
//        }
//        .tabViewStyle(PageTabViewStyle())
//        .onAppear(perform: self.sendAnalytics)
    }

    private func sendAnalytics() {
        FirebaseAnalytics.Analytics.logEvent("IntroView_viewed", parameters: nil)
    }

}

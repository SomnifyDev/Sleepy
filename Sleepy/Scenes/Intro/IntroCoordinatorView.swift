//
//  IntroCoordinatorView.swift
//  IntroCoordinatorView
//
//  Created by Никита Казанцев on 25.09.2021.
//

import SwiftUI

import FirebaseAnalytics
import SwiftUI
import XUI

struct IntroCoordinatorView: View {
    @Store var viewModel: IntroCoordinator
    @Binding var shouldShowIntro: Bool
    var body: some View {
        MainIntroView(colorScheme: viewModel.colorSchemeProvider.sleepyColorScheme, shouldShowIntro: self.$shouldShowIntro)
    }

    private func sendAnalytics() {
        FirebaseAnalytics.Analytics.logEvent("IntroView_viewed", parameters: nil)
    }
}

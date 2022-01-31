// Copyright (c) 2022 Sleepy.

// swiftformat:disable all
import FirebaseAnalytics
import SwiftUI
import XUI

struct CardDetailsView: View {
    @Store var viewModel: CardDetailsViewCoordinator

    var body: some View {
        HStack {
            switch viewModel.card {
            case .heart:
                HeartCardDetailView(viewModel: self.viewModel)
            case .general:
                GeneralCardDetailView(viewModel: self.viewModel)
            case .phases:
                PhasesCardDetailView(viewModel: self.viewModel)
            case .breath:
                RespiratoryCardDetailView(viewModel: self.viewModel)
            }
        }.onAppear(perform: self.viewModel.sendAnalytics)
    }
}

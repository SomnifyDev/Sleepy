// Copyright (c) 2021 Sleepy.

// swiftformat:disable all
import FirebaseAnalytics
import SwiftUI
import XUI

struct CardDetailsView: View {
    @Store var coordinator: CardDetailsViewCoordinator

    var body: some View {
        HStack {
            switch coordinator.card {
            case .heart:
                HeartCardDetailView(viewModel: self.coordinator)
            case .general:
                GeneralCardDetailView(viewModel: self.coordinator)
            case .phases:
                PhasesCardDetailView(viewModel: self.coordinator)
            case .breath:
                RespiratoryCardDetailView(viewModel: self.coordinator)
            }
        }.onAppear(perform: self.sendAnalytics)
    }

    private func sendAnalytics() {
        FirebaseAnalytics.Analytics.logEvent("CardDetails_viewed", parameters: ["cardType": self.coordinator.card.rawValue])
    }
}

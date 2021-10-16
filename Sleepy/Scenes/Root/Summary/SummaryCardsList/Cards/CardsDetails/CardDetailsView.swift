import SwiftUI
import XUI
import FirebaseAnalytics

struct CardDetailsView: View {
    
    @Store var coordinator: CardDetailsViewCoordinator

    var body: some View {
        HStack {
            if coordinator.card == .heart {
                HeartCardDetailView(viewModel: self.coordinator)
            } else if coordinator.card == .general {
                GeneralCardDetailView(viewModel: self.coordinator)
            } else if coordinator.card == .phases {
                PhasesCardDetailView(viewModel: self.coordinator)
            }
        }.onAppear(perform: self.sendAnalytics)
    }

    private func sendAnalytics() {
        FirebaseAnalytics.Analytics.logEvent("CardDetails_viewed", parameters: [
            "cardType": coordinator.card.rawValue
        ])
    }

}

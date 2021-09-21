import SwiftUI
import XUI

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
        }
    }

}

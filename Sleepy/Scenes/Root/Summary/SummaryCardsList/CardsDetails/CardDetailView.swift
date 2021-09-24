import SwiftUI
import XUI

<<<<<<< HEAD:Sleepy/Scenes/Root/Summary/SummaryCardsList/Cards/CardsDetails/CardDetailsView.swift
struct CardDetailsView: View {
    
    @Store var coordinator: CardDetailsViewCoordinator
=======
struct CardDetailView: View {
    
    @Store var coordinator: CardDetailViewCoordinator
>>>>>>> master:Sleepy/Scenes/Root/Summary/SummaryCardsList/CardsDetails/CardDetailView.swift

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

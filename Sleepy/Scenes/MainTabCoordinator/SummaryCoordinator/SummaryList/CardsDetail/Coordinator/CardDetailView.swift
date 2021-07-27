import SwiftUI
import XUI

struct CardDetailView: View {

    // MARK: Stored Properties
    
    @Store var viewModel: CardDetailViewCoordinator

    // MARK: Views

    var body: some View {
        HStack {
            if viewModel.card == .heart {
                HeartCardDetailView()
            } else if viewModel.card == .general {
                GeneralCardDetailView()
            } else if viewModel.card == .phases {
                PhasesCardDetailView()
            }
        }
    }

}

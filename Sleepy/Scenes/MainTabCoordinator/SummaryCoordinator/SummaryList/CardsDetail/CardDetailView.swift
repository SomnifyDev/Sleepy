import SwiftUI
import XUI

struct CardDetailView: View {

    // MARK: Stored Properties
    
    @Store var viewModel: CardDetailViewCoordinator

    // MARK: Views

    var body: some View {
        HStack {
            if viewModel.card == .heart {
                HeartCardDetailView(viewModel: viewModel)
            } else if viewModel.card == .general {
                GeneralCardDetailView(viewModel: viewModel)
            } else if viewModel.card == .phases {
                PhasesCardDetailView(viewModel: viewModel)
            }
        }
    }

}

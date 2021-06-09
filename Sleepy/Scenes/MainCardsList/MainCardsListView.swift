import SwiftUI
import XUI

struct MainCardsListView: View {

    // MARK: Stored Properties

    @Store var viewModel: FeedListCoordinator

    // MARK: Views

    var body: some View {
        List(viewModel.cards) { card in
            HStack {

                containedView(card: card)
            }
            .onNavigation { viewModel.open(card) }
        }
        .navigationTitle(viewModel.title)
    }

    func containedView(card: Card) -> AnyView {
        switch card.type {
        case .heart:
            return AnyView(HeartCardView().frame(height: 250))
        case .general:
            return AnyView(GeneralCardView().frame(height: 50))
        case .phases:
            return AnyView(PhasesCardView().frame(height: 150))
        }
    }

}

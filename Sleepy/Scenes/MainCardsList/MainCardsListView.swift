import SwiftUI
import XUI

struct MainCardsListView: View {

    // MARK: Stored Properties

    @Store var viewModel: MainCardsListViewModel

    // MARK: Views

    var body: some View {
        List(viewModel.cards) { card in
            HStack {

                Text(card.title)
                    .font(.headline)
                Spacer()
            }
            .onNavigation { viewModel.open(card) }
        }
        .navigationTitle(viewModel.title)
    }

}

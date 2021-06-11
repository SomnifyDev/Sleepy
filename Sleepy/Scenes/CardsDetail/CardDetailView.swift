import SwiftUI
import XUI

struct CardDetailView: View {

    // MARK: Stored Properties

    @Store var viewModel: CardDetailViewRouter

    // MARK: Views

    var body: some View {
        HStack {
            if (viewModel.card == .heart) {
                Text("heart detail view")
            } else if (viewModel.card == .general) {
                Text("general detail view")
            } else if (viewModel.card == .phases) {
                Text("phases details view")
            }
        }
    }

}

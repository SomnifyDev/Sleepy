import SwiftUI
import XUI

struct CardDetailView: View {

    // MARK: Stored Properties

    @Store var viewModel: CardViewModel

    // MARK: Views

    var body: some View {
        HStack {
            Text(viewModel.card.title)
        }
    }

}

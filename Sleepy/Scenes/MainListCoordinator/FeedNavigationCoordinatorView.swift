import SwiftUI
import XUI

struct FeedNavigationCoordinatorView: View {

    // MARK: Stored Properties

    @Store var coordinator: FeedNavigationCoordinator

    // MARK: Views

    var body: some View {
        NavigationView {
            MainCardsListView(viewModel: coordinator.viewModel)
                .navigation(model: $coordinator.detailViewModel) { viewModel in
                    CardDetailView(viewModel: viewModel)
                }
        }
    }

}

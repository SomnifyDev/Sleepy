import SwiftUI
import XUI

struct MainListCoordinatorView: View {

    // MARK: Stored Properties

    @Store var coordinator: MainListCoordinator

    // MARK: Views

    var body: some View {
        NavigationView {
            MainCardsListView(viewModel: coordinator.viewModel)
                .navigation(model: $coordinator.detailViewModel) { viewModel in
                    CardView(viewModel: viewModel)
                }
        }
    }

}

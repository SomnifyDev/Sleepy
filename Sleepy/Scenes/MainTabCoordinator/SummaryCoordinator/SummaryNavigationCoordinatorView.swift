import SwiftUI
import XUI

struct SummaryNavigationCoordinatorView: View {

    // MARK: Stored Properties

    @Store var coordinator: SummaryNavigationCoordinator

    // MARK: Views

    var body: some View {
        NavigationView {
            SummaryListView(viewModel: coordinator.viewModel)
                .navigation(model: $coordinator.detailViewModel) { viewModel in
                    CardDetailView(viewModel: viewModel)
                }
        }
    }

}

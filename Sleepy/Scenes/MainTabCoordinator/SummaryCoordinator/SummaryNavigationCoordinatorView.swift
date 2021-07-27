import SwiftUI
import XUI

struct SummaryNavigationCoordinatorView: View {

    // MARK: Stored Properties

    @Store var viewModel: SummaryNavigationCoordinator

    // MARK: Views

    var body: some View {
        NavigationView {
            SummaryListView(viewModel: viewModel.summaryListCoordinator)
                .navigation(model: $viewModel.cardDetailViewCoordinator) { viewModel in
                    CardDetailView(viewModel: viewModel)
                }
        }
    }

}

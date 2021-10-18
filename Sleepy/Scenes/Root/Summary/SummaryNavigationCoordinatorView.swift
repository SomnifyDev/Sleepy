import SwiftUI
import XUI

struct SummaryNavigationCoordinatorView: View {
    @Store var viewModel: SummaryNavigationCoordinator

    var body: some View {
        NavigationView {
            SummaryCardsListView(viewModel: viewModel.summaryListCoordinator)
                .navigation(model: $viewModel.cardDetailViewCoordinator) { viewModel in
                    CardDetailsView(coordinator: viewModel)
                }
        }
    }
}

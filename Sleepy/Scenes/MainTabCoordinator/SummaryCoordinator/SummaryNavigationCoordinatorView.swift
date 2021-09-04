import SwiftUI
import XUI

struct SummaryNavigationCoordinatorView: View {

    @Store var viewModel: SummaryNavigationCoordinator

    

    var body: some View {
        NavigationView {
            SummaryListView(viewModel: viewModel.summaryListCoordinator)
                .navigation(model: $viewModel.cardDetailViewCoordinator) { viewModel in
                    CardDetailView(coordinator: viewModel)
                }
        }
    }

}

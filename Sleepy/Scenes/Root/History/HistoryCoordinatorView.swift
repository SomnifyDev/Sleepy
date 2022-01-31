// Copyright (c) 2022 Sleepy.

import SwiftUI
import UIComponents
import XUI

struct HistoryCoordinatorView: View {
    @Store var viewModel: HistoryCoordinator

    var body: some View {
        NavigationView {
            HistoryListView(viewModel: viewModel, interactor: .init(viewModel: _viewModel))
        }
        .navigationTitle("History")
    }
}

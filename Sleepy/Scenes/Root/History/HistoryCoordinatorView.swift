// Copyright (c) 2021 Sleepy.

import HKVisualKit
import SwiftUI
import XUI

struct HistoryCoordinatorView: View
{
    @Store var viewModel: HistoryCoordinator

    var body: some View
    {
        NavigationView
        {
            HistoryListView(viewModel: viewModel)
        }
        .navigationTitle("History")
    }
}

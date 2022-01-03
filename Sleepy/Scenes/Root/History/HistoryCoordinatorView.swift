// Copyright (c) 2021 Sleepy.

import SwiftUI
import UIComponents
import XUI

struct HistoryCoordinatorView: View {
	@Store var viewModel: HistoryCoordinator
    let interactor: HistoryInteractor

	var body: some View {
		NavigationView {
			HistoryListView(viewModel: viewModel, interactor: interactor)
		}
		.navigationTitle("History")
	}
}

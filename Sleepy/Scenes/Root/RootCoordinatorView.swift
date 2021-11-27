// Copyright (c) 2021 Sleepy.

import SwiftUI
import XUI

struct RootCoordinatorView: View {
	@Store var viewModel: RootCoordinator

	var body: some View {
		TabView(selection: $viewModel.tab) {
			SummaryNavigationCoordinatorView(viewModel: viewModel.summaryCoordinator)
				.tabItem { Label("summary", systemImage: "bed.double.fill") }
				.tag(TabType.summary)

			HistoryCoordinatorView(viewModel: viewModel.historyCoordinator)
				.tabItem { Label("history", systemImage: "calendar") }
				.tag(TabType.history)

			SoundsCoordinatorView(viewModel: viewModel.soundsCoordinator)
				.tabItem { Label("sounds", systemImage: "waveform.and.mic") }
				.tag(TabType.soundRecognision)

			AlarmCoordinatorView(viewModel: viewModel.alarmCoordinator)
				.tabItem { Label("alarm", systemImage: "alarm.fill") }
				.tag(TabType.alarm)

			SettingsCoordinatorView(viewModel: viewModel.settingsCoordinator)
				.tabItem { Label("settings", systemImage: "gear") }
				.tag(TabType.settings)
		}.onAppear(perform: self.viewModel.sendAnalytics)
	}
}

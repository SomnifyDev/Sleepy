import SwiftUI
import XUI

struct RootCoordinatorView: View {
    
    // MARK: Stored Properties
    
    @Store var viewModel: RootCoordinator

    // MARK: Views
    
    var body: some View {
        TabView(selection: $viewModel.tab) {
            SummaryNavigationCoordinatorView(viewModel: viewModel.summaryCoordinator)
                .tabItem { Label("summary".localized, systemImage: "bed.double.fill") }
                .tag(TabBarTab.summary)
            
            HistoryCoordinatorView(coordinator: viewModel.historyCoordinator)
                .tabItem { Label("history".localized, systemImage: "calendar") }
                .tag(TabBarTab.history)
            
            AlarmCoordinatorView(coordinator: viewModel.alarmCoordinator)
                .tabItem { Label("alarm".localized, systemImage: "alarm.fill") }
                .tag(TabBarTab.alarm)


            SoundsCoordinatorView(viewModel: viewModel.soundsCoordinator)
                .tabItem { Label("sounds".localized, systemImage: "mic") }
                .tag(TabBarTab.soundRecognision)

            SettingsCoordinatorView(viewModel: viewModel.settingsCoordinator)
                .tabItem { Label("settings".localized, systemImage: "gear") }
                .tag(TabBarTab.settings)
        }
    }
    
}

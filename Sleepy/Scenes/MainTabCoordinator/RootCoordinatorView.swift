import SwiftUI
import XUI

struct RootCoordinatorView: View {
    
    // MARK: Stored Properties
    
    @Store var viewModel: RootCoordinator

    // MARK: Views
    
    var body: some View {
        TabView(selection: $viewModel.tab) {
            SummaryNavigationCoordinatorView(viewModel: viewModel.summaryCoordinator)
                .tabItem { Label("summary", systemImage: "hare.fill") }
                .tag(TabBarTab.summary)
            
            HistoryCoordinatorView(coordinator: viewModel.historyCoordinator)
                .tabItem { Label("history", systemImage: "hare.fill") }
                .tag(TabBarTab.history)
            
            AlarmCoordinatorView(coordinator: viewModel.alarmCoordinator)
                .tabItem { Label("alarm", systemImage: "hare.fill") }
                .tag(TabBarTab.alarm)
            
            SettingsCoordinatorView(viewModel: viewModel.settingsCoordinator)
                .tabItem { Label("settings", systemImage: "hare.fill") }
                .tag(TabBarTab.settings)
        }
    }
    
}

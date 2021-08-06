import SwiftUI
import XUI

struct RootCoordinatorView: View {
    
    // MARK: Stored Properties
    
    @Store var viewModel: RootCoordinator

    // MARK: Views
    
    var body: some View {
        TabView(selection: $viewModel.tab) {
            SummaryNavigationCoordinatorView(viewModel: viewModel.summaryCoordinator)
                .tabItem { Label("summary", systemImage: "bed.double.fill") }
                .tag(TabBarTab.summary)
            
            HistoryCoordinatorView(coordinator: viewModel.historyCoordinator)
                .tabItem { Label("history", systemImage: "calendar") }
                .tag(TabBarTab.history)
            
            AlarmCoordinatorView(coordinator: viewModel.alarmCoordinator)
                .tabItem { Label("alarm", systemImage: "alarm.fill") }
                .tag(TabBarTab.alarm)
            
            SettingsCoordinatorView(viewModel: viewModel.settingsCoordinator)
                .tabItem { Label("settings", systemImage: "gear") }
                .tag(TabBarTab.settings)
        }
    }
    
}
